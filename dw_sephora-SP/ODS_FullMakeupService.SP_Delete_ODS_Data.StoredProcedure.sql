/****** Object:  StoredProcedure [ODS_FullMakeupService].[SP_Delete_ODS_Data]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_FullMakeupService].[SP_Delete_ODS_Data] @TableName [NVARCHAR](255) AS
BEGIN
    
	declare @sql nvarchar(4000)

	set @sql='Truncate table '+@TableName

	exec (@sql)
	

END
GO
