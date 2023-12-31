/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Store_Warning]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Store_Warning] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Store_Warning;
insert into STG_IMS.STK_Store_Warning
select 
		id,
		case when trim(warn_name) in ('','null','None') then null else trim(warn_name) end as warn_name,
		status,
		case when trim(sku_codes) in ('','null','None') then null else trim(sku_codes) end as sku_codes,
		case when trim(vb_codes) in ('','null','None') then null else trim(vb_codes) end as vb_codes,
		case when trim(stock_type) in ('','null','None') then null else trim(stock_type) end as stock_type,
		case when trim(channel_code) in ('','null','None') then null else trim(channel_code) end as channel_code,
		warn_symbol,
		warn_num,
		scope,
		start_time,
		end_time,
		case when trim(accept_times) in ('','null','None') then null else trim(accept_times) end as accept_times,
		case when trim(accept_email) in ('','null','None') then null else trim(accept_email) end as accept_email,
		warn_template_id,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		store_warn_type,
		order_type,
		case when trim(warn_shop) in ('','null','None') then null else trim(warn_shop) end as warn_shop,
		warn_time_length,
		store_or_warehouse,
		case when trim(warn_shop_ids) in ('','null','None') then null else trim(warn_shop_ids) end as warn_shop_ids,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Store_Warning
where dt = @dt
END
GO
