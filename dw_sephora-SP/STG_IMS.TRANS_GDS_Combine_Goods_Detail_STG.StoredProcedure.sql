/****** Object:  StoredProcedure [STG_IMS].[TRANS_GDS_Combine_Goods_Detail_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_GDS_Combine_Goods_Detail_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.GDS_Combine_Goods_Detail_STG;
insert into STG_IMS.GDS_Combine_Goods_Detail_STG
select 
		id,
		combine_goods_id,
		goods_id,
		case when trim(goods_code) in ('','null','None') then null else trim(goods_code) end as goods_code,
		case when trim(goods_name) in ('','null','None') then null else trim(goods_name) end as goods_name,
		singleproduct_id,
		case when trim(singleproduct_code) in ('','null','None') then null else trim(singleproduct_code) end as singleproduct_code,
		case when trim(singleproduct_name) in ('','null','None') then null else trim(singleproduct_name) end as singleproduct_name,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		market_price,
		cost_price,
		barcode_id,
		brand_id,
		measuunit_id,
		qty,
		case when trim(shop_condition) in ('','null','None') then null else trim(shop_condition) end as shop_condition,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		lastchanged,
		is_gift,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.GDS_Combine_Goods_Detail_STG
where dt = @dt
END

GO
