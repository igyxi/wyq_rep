/****** Object:  StoredProcedure [LOG].[usp_Insert_Start_log]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [LOG].[usp_Insert_Start_log] @JobID [Nvarchar](255),@JobName [nvarchar](100),@mainTableName [nvarchar](100) AS
BEGIN
    insert into [LOG].[ADF_Transaction_log](
	[JobID],
	[JobName],
	[MainTableName],
	[StartTime],
	JobStatus)
	select @JobID,@JobName,@mainTableName,getdate(),'Running'
END
GO
