/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Account_Channel_Lock]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Account_Channel_Lock] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Account_Channel_Lock;
insert into STG_IMS.STK_Account_Channel_Lock
select 
		id,
		shop_id,
		platform_id,
		case when trim(platform) in ('','null','None') then null else trim(platform) end as platform,
		goods_id,
		sku_id,
		qty_lock,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Account_Channel_Lock
where dt = @dt
END
GO
