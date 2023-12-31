/****** Object:  StoredProcedure [ODS_TD].[SP_Tb_IOS_Click]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_Tb_IOS_Click] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-14       weichen           Initial Version
-- ========================================================================================
DELETE FROM ODS_TD.Tb_IOS_Click WHERE CAST(clicktime AS DATE)= @dt
INSERT INTO ODS_TD.Tb_IOS_Click
SELECT 
	convert(datetime,clicktime) clicktime,
	appkey,
	spreadurl,
	spreadname,
	spreadgroup,
	channel_id,
	channel_name,
	case when len(click_ua) > 4000 then left(click_ua,3999) else  click_ua end as click_ua,
	click_ip,
	tdsubid,
	browserid,
	adcreative,
	adcampaign,
	adgroup,
	fraud_prevention,
	case when len(remark) > 4000 then left(remark,3999) else remark end as remark,
	file_path,
	getdate() as trigger_time
from STG_TD.Tb_IOS_Click
WHERE CAST(clicktime AS DATE)= @dt
;
END
GO
