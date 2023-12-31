/****** Object:  StoredProcedure [DATA_OPS].[SP_Pipeline_LOG_End]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_Pipeline_LOG_End] @Process_ID [Nvarchar](255),@Pipeline_ID [nvarchar](100),@Process_Status [int] AS
BEGIN

    UPDATE DATA_OPS.Fact_Pipeline_ProcessLog SET
        Process_EndTime=DATEADD(HOUR,8,GETDATE()),
        Process_Status=@Process_Status,
		Process_ID=@Process_ID
    WHERE BizDate=CONVERT(date,DATEADD(HOUR,8,GETDATE())) AND Pipeline_ID=@Pipeline_ID

END
GO
