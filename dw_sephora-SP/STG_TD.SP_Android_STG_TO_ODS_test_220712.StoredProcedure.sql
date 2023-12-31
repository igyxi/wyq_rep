/****** Object:  StoredProcedure [STG_TD].[SP_Android_STG_TO_ODS_test_220712]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TD].[SP_Android_STG_TO_ODS_test_220712] @StartDate [datetime],@EndDate [datetime],@TableName [varchar](255),@TimeColumn [varchar](255) AS


declare @sql varchar(4000)

set @sql= '
delete
from ODS_TD.'+@TableName+'
where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

exec(@sql)

-------------------------------------------------------------------------------------------------------
--Tb_Android_Click
-------------------------------------------------------------------------------------------------------
if @TableName='Tb_Android_Click_test_220712'
begin
	set @sql='
	SELECT convert(datetime,clicktime) clicktime
		,appkey
		,spreadurl
		,spreadname
		,spreadgroup
		,channel_id
		,channel_name
		,click_ua
		,click_ip
		,tdsubid
		,browserid
		,adcreative
		,adcampaign
		,adgroup
		,fraud_prevention
		,remark
		,file_path
		,LEFT(trigger_time,10) as trigger_time
	FROM STG_TD.Tb_Android_Click_test_220712
	where '+@TimeColumn+'>='''+convert(varchar(10),convert(date,@StartDate))+'''
	and '+@TimeColumn+'<'''+convert(varchar(10),convert(date,@EndDate))+''''

	exec(@sql)
end
GO
