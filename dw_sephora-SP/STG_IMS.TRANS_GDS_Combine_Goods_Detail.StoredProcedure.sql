/****** Object:  StoredProcedure [STG_IMS].[TRANS_GDS_Combine_Goods_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_GDS_Combine_Goods_Detail] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By            Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-15       wangzhichun           Initial Version
-- 2022-09-28       wubin                 update data_create_time/data_update_time
-- 2022-11-25       wangzhichun           update increment
-- 2022-12-15       wangzhichun           change schema
-- ========================================================================================
truncate table STG_IMS.GDS_Combine_Goods_Detail;
insert into STG_IMS.GDS_Combine_Goods_Detail
select 
		id,
		combine_goods_id,
		goods_id,
		case when trim(goods_code) in ('','null') then null else trim(goods_code) end as goods_code,
		case when trim(goods_name) in ('','null') then null else trim(goods_name) end as goods_name,
		singleProduct_id,
		case when trim(singleProduct_code) in ('','null') then null else trim(singleProduct_code) end as singleProduct_code,
		case when trim(singleProduct_name) in ('','null') then null else trim(singleProduct_name) end as singleProduct_name,
		case when trim(status) in ('','null') then null else trim(status) end as status,
		market_price,
		cost_price,
		barcode_id,
		brand_id,
		measuunit_id,
		qty,
		case when trim(shop_condition) in ('','null') then null else trim(shop_condition) end as shop_condition,
		case when trim(create_by) in ('','null') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null') then null else trim(modify_by) end as modify_by,
		modify_time,
		lastchanged,
		is_gift,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_IMS.GDS_Combine_Goods_Detail
) t
where rownum = 1
END
GO
