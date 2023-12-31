/****** Object:  StoredProcedure [Management].[SP_Log_Trigger]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Management].[SP_Log_Trigger] @PipelineID [NVARCHAR](512),@PipelineName [NVARCHAR](512),@status [int] AS
BEGIN
    delete from [Management].[Trigger_Logging] where start_time < DATEADD(day, -7, GETDATE());
    IF @status = 0
    BEGIN
        insert into [Management].[Trigger_Logging] select @PipelineID, @PipelineName, 0, DATEADD(HOUR, 8, GETDATE()), null
        
    END
    ELSE IF @status <> 0
    BEGIN
        update [Management].[Trigger_Logging] set [status] = @status, [end_time] = DATEADD(HOUR, 8, GETDATE()) where id = @PipelineID
    END
END
GO
