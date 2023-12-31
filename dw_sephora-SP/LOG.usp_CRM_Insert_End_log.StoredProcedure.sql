/****** Object:  StoredProcedure [LOG].[usp_CRM_Insert_End_log]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [LOG].[usp_CRM_Insert_End_log] @path_string [nvarchar](500),@rowcount [bigint] AS
BEGIN
UPDATE [STG_CRM].[Data_Transmission_Log]
SET EndTime = (convert(datetime,SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))),
 Upload_QTY = @rowcount
WHERE File_Path = @path_string
 AND StartTime = (SELECT TOP 1 StartTime
     FROM [STG_CRM].[Data_Transmission_Log]
     WHERE File_Path = @path_string
     ORDER BY [StartTime] DESC)
END
GO
