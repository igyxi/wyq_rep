/****** Object:  StoredProcedure [LOG].[usp_OnError_log]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [LOG].[usp_OnError_log] @JobID [Nvarchar](255),@OnError [nvarchar](3000) AS
BEGIN
    update [LOG].[ADF_Transaction_log]
	set [EndTime]=getdate(),
	OnError=@OnError,
	JobStatus='Falied'
	where JobID=@JobID
END
GO
