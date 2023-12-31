/****** Object:  StoredProcedure [DATA_OPS].[SP_Pipeline_LOG_Start]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_Pipeline_LOG_Start] @Process_ID [NVARCHAR](100),@Pipeline_ID [NVARCHAR](100) AS
BEGIN
	DELETE FROM DATA_OPS.Fact_Pipeline_ProcessLog
	WHERE Pipeline_ID=@Pipeline_ID AND BizDate=CONVERT(DATE,DATEADD(HOUR,8,GETDATE()))

    INSERT INTO DATA_OPS.Fact_Pipeline_ProcessLog(
        Process_ID,
        Pipeline_ID,
        BizDate,
        Process_StartTime,
        Process_EndTime,
        Process_Status,
        Monitor_Flag,
        Create_Time
    )
    SELECT @Process_ID,@Pipeline_ID,CONVERT(DATE,DATEADD(HOUR,8,GETDATE())),DATEADD(HOUR,8,GETDATE()),NULL,1,0,DATEADD(HOUR,8,GETDATE())
END

GO
