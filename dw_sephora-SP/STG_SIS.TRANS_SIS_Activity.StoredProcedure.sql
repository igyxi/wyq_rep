/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Activity] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-26       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Activity;
insert into STG_SIS.SIS_Activity
select 
		id,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		start_time,
		end_time,
		status,
		limit_goods_total_count,
		limit_p_goods_count,
		limit_order_count,
		freight,
		case when trim(deliver_time) in ('','null') then null else trim(deliver_time) end as deliver_time,
		case when trim(sale_rule_text) in ('','null') then null else trim(sale_rule_text) end as sale_rule_text,
		case when trim(banner_img_path) in ('','null') then null else trim(banner_img_path) end as banner_img_path,
		case when trim(del_flag) in ('','null') then null else trim(del_flag) end as del_flag,
		case when trim(location_id_description) in ('','null') then null else trim(location_id_description) end as location_id_description,
		case when trim(warehouse) in ('','null') then null else trim(warehouse) end as warehouse,
		create_time,
		update_time,
		show_status,
		current_timestamp as insert_timestamp
from    
    ODS_SIS.SIS_Activity
where 
    dt = @dt
END
GO
