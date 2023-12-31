/****** Object:  StoredProcedure [STG_IMS].[TRANS_GDS_Combine_Goods_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_GDS_Combine_Goods_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.GDS_Combine_Goods_STG;
insert into STG_IMS.GDS_Combine_Goods_STG
select 
		id,
		case when trim(combine_goods_code) in ('','null','None') then null else trim(combine_goods_code) end as combine_goods_code,
		case when trim(combine_goods_name) in ('','null','None') then null else trim(combine_goods_name) end as combine_goods_name,
		case when trim(path) in ('','null','None') then null else trim(path) end as path,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		start_date,
		end_date,
		classification_id,
		categorytree_id,
		market_price,
		case when trim(contrast_code) in ('','null','None') then null else trim(contrast_code) end as contrast_code,
		measuunit_id,
		case when trim(is_online) in ('','null','None') then null else trim(is_online) end as is_online,
		case when trim(is_warehouse) in ('','null','None') then null else trim(is_warehouse) end as is_warehouse,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		lastchanged,
		return_singleproduct_id,
		return_goods_id,
		combine_batch_id,
		case when trim(field_1) in ('','null','None') then null else trim(field_1) end as field_1,
		case when trim(field_2) in ('','null','None') then null else trim(field_2) end as field_2,
		case when trim(field_3) in ('','null','None') then null else trim(field_3) end as field_3,
		case when trim(field_4) in ('','null','None') then null else trim(field_4) end as field_4,
		case when trim(field_5) in ('','null','None') then null else trim(field_5) end as field_5,
		goods_id,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.GDS_Combine_Goods_STG
where dt = @dt
END

GO
