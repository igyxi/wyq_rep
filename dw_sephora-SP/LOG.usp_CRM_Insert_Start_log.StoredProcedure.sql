/****** Object:  StoredProcedure [LOG].[usp_CRM_Insert_Start_log]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [LOG].[usp_CRM_Insert_Start_log] @filePath [nvarchar](500) AS
BEGIN
INSERT [STG_CRM].[Data_Transmission_Log]
(
[File_Path]
,[StartTime]
,[EndTime]
,[Upload_QTY]
)
SELECT 
@filePath AS [File_Path],
convert(datetime,SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')) AS [StartTime],
NULL AS [EndTime],
NULL AS [Upload_QTY]
END
GO
