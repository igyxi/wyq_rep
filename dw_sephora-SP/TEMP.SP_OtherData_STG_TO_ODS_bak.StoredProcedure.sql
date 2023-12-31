/****** Object:  StoredProcedure [TEMP].[SP_OtherData_STG_TO_ODS_bak]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_OtherData_STG_TO_ODS_bak] @StartDate [datetime],@EndDate [datetime],@TableName [varchar](255),@TimeColumn [varchar](255) AS

declare @sql varchar(4000)

set @sql= '
delete
from ODS_TD.'+@TableName+'
where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

exec(@sql)

-------------------------------------------------------------------------------------------------------
--OMS
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_OMS_Order'
begin
	set @sql='
	SELECT sales_order_number
		  ,channel_cd
		  ,is_placed_flag
		  ,place_time
		  ,place_date
		  ,order_time
		  ,order_date
		  ,payed_amount
		  ,user_id
			,member_new_status 
      ,member_daily_new_status
      ,member_monthly_new_status 
		  ,idfa
		  ,android_id
		  ,oaid
		  ,trigger_time
	  FROM STG_TD.Tb_OMS_Order
	  where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
		and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

		exec(@sql)

end

-------------------------------------------------------------------------------------------------------
--DeviceID
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_DeviceID'
begin
	set @sql='
	SELECT DeviceId
		  ,OS
		  ,[Date]
		  ,trigger_time
	  FROM STG_TD.Tb_DeviceID
	  where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
		and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end
GO
