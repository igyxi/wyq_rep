/****** Object:  StoredProcedure [STG_TD].[SP_IOS_STG_TO_ODS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TD].[SP_IOS_STG_TO_ODS] @StartDate [datetime],@EndDate [datetime],@TableName [varchar](255),@TimeColumn [varchar](255) AS


declare @sql varchar(4000)

set @sql= '
delete
from ODS_TD.'+@TableName+'
where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

exec(@sql)

-------------------------------------------------------------------------------------------------------
--Tb_IOS_Click
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_IOS_Click'
begin
	set @sql='
	  select 
		convert(datetime,clicktime) clicktime
       ,appkey
      ,spreadurl
      ,spreadname
      ,spreadgroup
      ,channel_id
      ,channel_name
      ,case when len(click_ua) > 4000 then left(click_ua,3999)
		else  click_ua end as click_ua
      ,click_ip
      ,tdsubid
      ,browserid
      ,adcreative
      ,adcampaign
      ,adgroup
      ,fraud_prevention
      ,case when len(remark) > 4000 then left(remark,3999)
		else remark end as remark
      ,file_path
      ,getdate() trigger_time
	from STG_TD.Tb_IOS_Click
	where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end
-------------------------------------------------------------------------------------------------------
--Tb_IOS_Install
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_IOS_Install'
begin
	set @sql='
	  select 
	  convert(datetime,active_time) active_time
		 ,channel_name
		  ,campaign_name
		  ,td_subid
		  ,tdid
		  ,idfa
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
		  ,track_id
		  ,attribute_type
		  ,adcampaign
		  ,adgroup
		  ,adcreative
		  ,custom
		  ,file_path
		  ,getdate() trigger_time
	from STG_TD.Tb_IOS_Install
	where trigger_time not like ''%csv%''
	and '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+'''
	union all
	select 
	  convert(datetime,active_time) active_time
		 ,channel_name
		  ,campaign_name
		  ,td_subid
		  ,idfa tdid
		  ,active_ip idfa
		  ,active_type active_ip
		  ,device_type active_type
		  ,os device_type
		  ,clickTime os
		  ,clickIp clickTime
		  ,assistant_click_1_campaign_name clickIp
		  ,assistant_click_2_campaign_name assistant_click_1_campaign_name
		  ,assistant_click_3_campaign_name assistant_click_2_campaign_name
		  ,creative_id assistant_click_3_campaign_name
		  ,keyword_id creative_id
		  ,track_id keyword_id
		  ,attribute_type track_id
		  ,adcampaign attribute_type
		  ,adgroup adcampaign
		  ,adcreative adgroup
		  ,custom adcreative
		  ,file_path custom
		  ,trigger_time file_path
		  ,getdate() trigger_time
	from STG_TD.Tb_IOS_Install
	where trigger_time like ''%csv%''
	and '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end
-------------------------------------------------------------------------------------------------------
--Tb_IOS_Order
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_IOS_Order'
begin
	set @sql='
	  SELECT convert(datetime,order_time) order_time
		  ,channel_name
		  ,campaign_name
		  ,td_subid
		  ,idfa tdid
		  ,account_id idfa
		  ,order_id account_id
		  ,order_amount order_id
		  ,items order_amount
		  ,currency_type items
		  ,order_ip currency_type
		  ,device_type order_ip
		  ,os device_type
		  ,creative_id os
		  ,keyword_id creative_id
		  ,track_id keyword_id
		  ,attribute_type track_id
		  ,adcampaign attribute_type
		  ,adgroup adcampaign
		  ,adcreative adgroup
		  ,file_path adcreative
		  ,trigger_time file_path
		  ,getdate() trigger_time
	  FROM STG_TD.Tb_IOS_Order
	  where trigger_time like ''%csv%''
	  and '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	  and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+'''
	  union all
	  select 
			convert(datetime,order_time) order_time
		   ,channel_name
		  ,campaign_name
		  ,td_subid
		  ,tdid
		  ,idfa
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
		  ,track_id
		  ,attribute_type
		  ,adcampaign
		  ,adgroup
		  ,adcreative
		  ,file_path
		  ,getdate() trigger_time
	from STG_TD.Tb_IOS_Order
	where trigger_time not like ''%csv%''
	and '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end

-------------------------------------------------------------------------------------------------------
--Tb_IOS_PayOrder
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_IOS_PayOrder'
begin
	set @sql='
	   select 
	convert(datetime,pay_time) pay_time
      ,channel_name
      ,campaign_name
      ,td_subid
      ,tdid
      ,idfa
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
      ,track_id
      ,attribute_type
      ,adcampaign
      ,adgroup
      ,adcreative
      ,file_path
      ,getdate() trigger_time
	from STG_TD.Tb_IOS_PayOrder
	where trigger_time not like ''%csv%''
	and '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+'''
	union all
	select 
		convert(datetime,pay_time) pay_time
		  ,channel_name
		  ,campaign_name
		  ,td_subid
		  ,idfa tdid
		  ,account_id idfa
		  ,order_id account_id
		  ,pay_amount order_id
		  ,items pay_amount
		  ,pay_ip items
		  ,currency_type pay_ip
		  ,paytype currency_type
		  ,first_pay paytype
		  ,device_type first_pay
		  ,os device_type
		  ,creative_id os
		  ,keyword_id creative_id
		  ,track_id keyword_id
		  ,attribute_type track_id
		  ,adcampaign attribute_type
		  ,adgroup adcampaign
		  ,adcreative adgroup
		  ,file_path adcreative
		  ,trigger_time file_path
		  ,getdate() trigger_time
	from STG_TD.Tb_IOS_PayOrder
	where trigger_time like ''%csv%''
	and '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end

-------------------------------------------------------------------------------------------------------
--Tb_IOS_Wakeup
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_IOS_Wakeup'
begin
	set @sql='
	   SELECT convert(datetime,deeplink_time) deeplink_time
      ,channel_name
      ,campaign_name
      ,td_subid
      ,tdid
      ,idfa
      ,link
      ,deeplink_ip
      ,device_type
      ,os
      ,creative_id
      ,keyword_id
      ,track_id
      ,adcampaign
      ,adgroup
      ,adcreative
      ,file_path
      ,getdate() trigger_time
	  FROM STG_TD.Tb_IOS_Wakeup
	  where trigger_time not like ''%csv%''
	  and '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	  and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+'''
	  union all
	  SELECT convert(datetime,deeplink_time) deeplink_time
		  ,channel_name
		  ,campaign_name
		  ,td_subid
		  ,idfa tdid
		  ,link idfa
		  ,deeplink_ip link
		  ,device_type deeplink_ip
		  ,os device_type
		  ,creative_id os
		  ,keyword_id creative_id
		  ,track_id keyword_id
		  ,adcampaign track_id
		  ,adgroup adcampaign
		  ,adcreative adgroup
		  ,file_path adcreative
		  ,trigger_time file_path
		  ,getdate() trigger_time
	  FROM STG_TD.Tb_IOS_Wakeup
	  where trigger_time like ''%csv%''
	and '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end
GO
