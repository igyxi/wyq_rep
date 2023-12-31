/****** Object:  StoredProcedure [STG_TD].[SP_Get_ErrorData]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TD].[SP_Get_ErrorData] @TableName [varchar](255),@TimeColumn [varchar](255) AS

  declare @sql varchar(4000)

  --将错误数据写入error表
  set @sql = '
  insert into STG_TD.'+@TableName+'_Error
  select *
  from STG_TD.'+@TableName+'
  where isdate('+@TimeColumn+')=0
  '
  exec (@sql)

  --删除staging中错误数据
  set @sql = '
  delete
  from STG_TD.'+@TableName+'
  where isdate('+@TimeColumn+')=0
  '
  exec (@sql)
GO
