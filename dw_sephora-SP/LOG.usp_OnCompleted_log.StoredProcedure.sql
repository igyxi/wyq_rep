/****** Object:  StoredProcedure [LOG].[usp_OnCompleted_log]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [LOG].[usp_OnCompleted_log] @JobID [Nvarchar](255),@RowCounts [bigint] AS
BEGIN
    update [LOG].[ADF_Transaction_log]
	set [EndTime]=getdate(),
	RowCounts=@RowCounts,
	JobStatus='Succeeded'
	where JobID=@JobID

END
GO
