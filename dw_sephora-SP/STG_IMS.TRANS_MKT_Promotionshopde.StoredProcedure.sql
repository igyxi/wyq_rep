/****** Object:  StoredProcedure [STG_IMS].[TRANS_MKT_Promotionshopde]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_MKT_Promotionshopde] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.MKT_Promotionshopde;
insert into STG_IMS.MKT_Promotionshopde
select 
		id,
		shop_scope_id,
		promotion_id,
		shop_id,
		case when trim(shop_code) in ('','null','None') then null else trim(shop_code) end as shop_code,
		case when trim(shop_name) in ('','null','None') then null else trim(shop_name) end as shop_name,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.MKT_Promotionshopde
where dt = @dt
END

GO
