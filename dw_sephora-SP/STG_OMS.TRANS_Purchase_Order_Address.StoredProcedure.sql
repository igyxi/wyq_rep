/****** Object:  StoredProcedure [STG_OMS].[TRANS_Purchase_Order_Address]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Purchase_Order_Address] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-31       wangzhichun        Initial Version
-- 2022-04-11       wangzhichun        add column
-- 2022-06-23       tali               change address
-- ========================================================================================
truncate table STG_OMS.Purchase_Order_Address;
insert into STG_OMS.Purchase_Order_Address
select 
    purchase_order_address_sys_id,
    case when trim(lower(r_oms_stkout_hd_sys_id)) in ('null','') then null else trim(r_oms_stkout_hd_sys_id) end as r_oms_stkout_hd_sys_id,
    purchase_order_sys_id,
    case when trim(lower(address)) in ('null','') then null else trim(address) end as address,
    case when trim(lower(address_type)) in ('null','') then null else trim(address_type) end as address_type,
    case when trim(lower(city)) in ('null','') then null else trim(city) end as city,
    case when trim(lower(comment)) in ('null','') then null else trim(comment) end as comment,
    case when trim(lower(country)) in ('null','') then null else trim(country) end as country,
    case when trim(lower(create_op)) in ('null','') then null else trim(create_op) end as create_op,
    create_time,
    case when trim(lower(district)) in ('null','') then null else trim(district) end as district,
    sign_time,
    case when trim(lower(exp_tracking_number)) in ('null','') then null else trim(exp_tracking_number) end as exp_tracking_number,
    case when trim(lower(exp_vendor)) in ('null','') then null else trim(exp_vendor) end as exp_vendor,
    case when trim(lower(province)) in ('null','') then null else trim(province) end as province,
    null as email,
    null as mobile,
    case when trim(lower(name)) in ('null','') then null else trim(name) end as name,
    null as phone,
    shipping_time,
    case when trim(lower(status)) in ('null','') then null else trim(status) end as status,
    case when trim(lower(update_op)) in ('null','') then null else trim(update_op) end as update_op,
    update_time,
    case when trim(lower(warehouse_code)) in ('null','') then null else trim(warehouse_code) end as warehouse_code,
    case when trim(lower(zipcode)) in ('null','') then null else trim(zipcode) end as zipcode,
    case when trim(lower(basic_status)) in ('null','') then null else trim(basic_status) end as basic_status,
    sys_create_time,
    sys_update_time,
    is_encrypt,
    case when trim(lower(desen_mobile)) in ('null','') then null else trim(desen_mobile) end as desen_mobile,
    case when trim(lower(desen_telephone)) in ('null','') then null else trim(desen_telephone) end as desen_telephone,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by purchase_order_sys_id, purchase_order_address_sys_id order by dt desc) rownum from ODS_OMS.Purchase_Order_Address 
) t
where rownum = 1;
END



GO
