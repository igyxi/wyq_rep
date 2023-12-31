/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Exchange_Address]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Exchange_Address] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-03       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_OMS.OMS_Exchange_Address;
insert into STG_OMS.OMS_Exchange_Address
select 
		oms_exchange_address_sys_id,
		case when trim(address) in ('','null','None') then null else trim(address) end as address,
		case when trim(city) in ('','null','None') then null else trim(city) end as city,
		case when trim(contactor) in ('','null','None') then null else trim(contactor) end as contactor,
		case when trim(country) in ('','null','None') then null else trim(country) end as country,
		case when trim(create_op) in ('','null','None') then null else trim(create_op) end as create_op,
		create_time,
		case when trim(district) in ('','null','None') then null else trim(district) end as district,
		case when trim(email) in ('','null','None') then null else trim(email) end as email,
		case when trim(mobile) in ('','null','None') then null else trim(mobile) end as mobile,
		case when trim(r_oms_exchange_apply_order_sys_id) in ('','null','None') then null else trim(r_oms_exchange_apply_order_sys_id) end as r_oms_exchange_apply_order_sys_id,
		oms_exchange_apply_order_sys_id,
		case when trim(phone) in ('','null','None') then null else trim(phone) end as phone,
		case when trim(province) in ('','null','None') then null else trim(province) end as province,
		case when trim(update_op) in ('','null','None') then null else trim(update_op) end as update_op,
		update_time,
		version,
		case when trim(zip) in ('','null','None') then null else trim(zip) end as zip,
		is_delete,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_exchange_address_sys_id order by dt desc) rownum from ODS_OMS.OMS_Exchange_Address
) t
where rownum = 1
END
GO
