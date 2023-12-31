/****** Object:  StoredProcedure [STG_New_OMS].[TRANS_Omni_Order_Month_Statistics]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_New_OMS].[TRANS_Omni_Order_Month_Statistics] AS
BEGIN  
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-04       wangzhichun           Initial Version
-- 2022-11-04       wangzhichun           add column
-- 2022-12-13       wangzhichun           update increment
-- ========================================================================================
truncate table STG_New_OMS.OMNI_Order_Month_Statistics;
insert into STG_New_OMS.OMNI_Order_Month_Statistics
select 
		id,
		case when trim(platform_id) in ('','null') then null else trim(platform_id) end as platform_id,
		bill_date,
		case when trim(sku_code) in ('','null') then null else trim(sku_code) end as sku_code,
		case when trim(sku_name) in ('','null') then null else trim(sku_name) end as sku_name,
		case when trim(shop_code) in ('','null') then null else trim(shop_code) end as shop_code,
		case when trim(shop_name) in ('','null') then null else trim(shop_name) end as shop_name,
		case when trim(city) in ('','null') then null else trim(city) end as city,
		original_price,
		price,
		qty,
		price_total,
		case when trim(category_code) in ('','null') then null else trim(category_code) end as category_code,
		case when trim(brand_code) in ('','null') then null else trim(brand_code) end as brand_code,
		create_time,
		case when trim(create_by) in ('','null') then null else trim(create_by) end as create_by,
		synt_time,
		case when trim(synt_flag) in ('','null') then null else trim(synt_flag) end as synt_flag,
		case when trim(synt_by) in ('','null') then null else trim(synt_by) end as synt_by,
		case when trim(bill_state) in ('','null') then null else trim(bill_state) end as bill_state,
        is_synt,
        modify_time,
        sku_order_status,
        case when trim(is_deleted) in ('','null') then null else trim(is_deleted) end as is_deleted,
		current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_New_OMS.OMNI_Order_Month_Statistics
) t
where rownum = 1
END
GO
