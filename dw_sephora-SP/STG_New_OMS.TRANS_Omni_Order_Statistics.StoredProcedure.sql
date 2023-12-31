/****** Object:  StoredProcedure [STG_New_OMS].[TRANS_Omni_Order_Statistics]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_New_OMS].[TRANS_Omni_Order_Statistics] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-04       wangzhichun           Initial Version
-- 2022-11-23       wangzhichun           add column
-- 2022-12-13       wangzhichun           update increment
-- ========================================================================================
truncate table STG_New_OMS.OMNI_Order_Statistics;
insert into STG_New_OMS.OMNI_Order_Statistics
select 
		id,
		case when trim(shop_code) in ('','null') then null else trim(shop_code) end as shop_code,
		complete_date,
		case when trim(platform_id) in ('','null') then null else trim(platform_id) end as platform_id,
		original_sales_amount,
		sales_amount,
		sales_order_number,
		refund_amount,
		refund_number,
		return_amount,
		return_number,
		create_time,
		day_time,
		case when trim(day_flag) in ('','null') then null else trim(day_flag) end as day_flag,
		week_time,
		case when trim(week_flag) in ('','null') then null else trim(week_flag) end as week_flag,
		case when trim(create_user) in ('','null') then null else trim(create_user) end as create_user,
        is_synt,
        modify_time,
		case when trim(is_deleted) in ('','null') then null else trim(is_deleted) end as is_deleted,        
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_New_OMS.OMNI_Order_Statistics
) t
where rownum = 1
END
GO
