/****** Object:  StoredProcedure [STG_TD].[SP_Delete_StaingData]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TD].[SP_Delete_StaingData] @TableName [nvarchar](255) AS

declare @sql nvarchar(4000)

set @sql='Truncate table '+@TableName

exec (@sql)
GO
