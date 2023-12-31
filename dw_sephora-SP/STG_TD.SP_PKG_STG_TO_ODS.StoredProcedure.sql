/****** Object:  StoredProcedure [STG_TD].[SP_PKG_STG_TO_ODS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TD].[SP_PKG_STG_TO_ODS] @StartDate [datetime],@EndDate [datetime],@TableName [varchar](255),@TimeColumn [varchar](255) AS


declare @sql varchar(4000)

set @sql= '
delete
from ODS_TD.'+@TableName+'
where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

exec(@sql)
if @TableName='Tb_PKG_PayOrder'
begin
	set @sql='
	select 
		convert(datetime,pay_time) pay_time
        ,store_name
      ,pkg_key
      ,td_subid
      ,tdid
      ,oaid
      ,advertiser_id
      ,android_id
      ,imei
      ,account_id
      ,order_id
      ,pay_amount
      ,items
      ,pay_ip
      ,currency_type
      ,paytype
      ,first_pay
      ,device_type
      ,os
      ,creative_id
      ,keyword_id
      ,campaign_name
      ,track_id
      ,attribute_type
      ,adcampaign
      ,adgroup
      ,adcreative
      ,file_path
      ,LEFT(trigger_time,10) as trigger_time
	from STG_TD.Tb_PKG_PayOrder
	where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end
-------------------------------------------------------------------------------------------------------
--Tb_PKG_Install
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_PKG_Install'
begin
	set @sql='
	select 
		convert(datetime,active_time)active_time
     ,store_name
      ,pkg_key
      ,td_subid
      ,tdid
      ,oaid
      ,advertiser_id
      ,android_id
      ,imei
      ,active_ip
      ,active_type
      ,device_type
      ,os
      ,clickTime
      ,clickIp
      ,assistant_click_1_campaign_name
      ,assistant_click_2_campaign_name
      ,assistant_click_3_campaign_name
      ,creative_id
      ,keyword_id
      ,campaign_name
      ,track_id
      ,attribute_type
      ,adcampaign
      ,adgroup
      ,adcreative
      ,custom
      ,file_path
      ,LEFT(trigger_time,10) as trigger_time
	from STG_TD.Tb_PKG_Install
	where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end
-------------------------------------------------------------------------------------------------------
--Tb_PKG_Order
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_PKG_Order'
begin
	set @sql='
	 select 
	  convert(datetime,order_time) order_time
		   ,store_name
		  ,pkg_key
		  ,td_subid
		  ,tdid
		  ,oaid
		  ,advertiser_id
		  ,android_id
		  ,imei
		  ,account_id
		  ,order_id
		  ,order_amount
		  ,items
		  ,currency_type
		  ,order_ip
		  ,device_type
		  ,os
		  ,creative_id
		  ,keyword_id
		  ,campaign_name
		  ,track_id
		  ,attribute_type
		  ,adcampaign
		  ,adgroup
		  ,adcreative
		  ,file_path
		  ,LEFT(trigger_time,10) as trigger_time
	  from STG_TD.Tb_PKG_Order
	  where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	  and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''
	  

	exec(@sql)
end

-------------------------------------------------------------------------------------------------------
--Tb_PKG_PayOrder
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_PKG_PayOrder'
begin
	set @sql='
	select 
		convert(datetime,pay_time) pay_time
        ,store_name
      ,pkg_key
      ,td_subid
      ,tdid
      ,oaid
      ,advertiser_id
      ,android_id
      ,imei
      ,account_id
      ,order_id
      ,pay_amount
      ,items
      ,pay_ip
      ,currency_type
      ,paytype
      ,first_pay
      ,device_type
      ,os
      ,creative_id
      ,keyword_id
      ,campaign_name
      ,track_id
      ,attribute_type
      ,adcampaign
      ,adgroup
      ,adcreative
      ,file_path
      ,LEFT(trigger_time,10) as trigger_time
	from STG_TD.Tb_PKG_PayOrder
	where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end
GO
