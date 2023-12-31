/****** Object:  StoredProcedure [STG_OMS].[TRANS_Sales_Order_Address]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Sales_Order_Address] AS
BEGIN
truncate table STG_OMS.Sales_Order_Address ;
insert into STG_OMS.Sales_Order_Address
select 
    a.sales_order_address_sys_id,
    a.sales_order_sys_id,
    case when trim(lower(r_oms_order_sys_id)) in ('null', '') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    null as mobile,
    null as pohone,
    case when trim(lower(a.name)) in ('null', '') then null else trim(a.name) end as name,
    case 
        when trim(lower(a.province)) in ('null', '') then null 
        when t1.province_short_name is not null then t1.province_short_name
        else trim(a.province)
    end as province,
    case 
        when trim(lower(a.city)) in ('null', '') then null 
        when t2.city_short_name is not null then t2.city_short_name
        when t3.city_short_name is not null then t3.city_short_name
        else trim(a.city)
    end as city,
    case 
        when trim(lower(a.district)) in ('null', '') then null 
        when t3.district_short_name is not null then t3.district_short_name
        when t4.district_short_name is not null then t4.district_short_name
        else trim(a.district) 
    end as district,
    null as address,
    case when trim(lower(a.order_zip)) in ('null', '') then null else trim(order_zip) end as order_zip,
    a.is_delete,
    case when trim(lower(a.create_op)) in ('null', '') then null else trim(a.create_op) end as create_op,
    create_time,
    case when trim(lower(a.update_op)) in ('null', '') then null else trim(a.update_op) end as update_op,
    update_time,
    case when trim(lower(a.country)) in ('null', '') then null else trim(a.country) end as country,
    null as email,
    case when trim(lower(a.address_type)) in ('null', '') then null else trim(a.address_type) end as address_type,
    case when trim(lower(a.address_seq)) in ('null', '') then null else trim(a.address_seq) end as address_seq,
    sys_create_time,
    sys_update_time,
    case when trim(a.name_invalid) in ('null', '') then null else trim(a.name_invalid) end as name_invalid,
    case when trim(a.address_invalid) in ('null', '') then null else trim(a.address_invalid) end as address_invalid,
    is_encrypt,
    case when trim(a.desen_mobile) in ('null', '') then null else trim(a.desen_mobile) end as desen_mobile,
    case when trim(a.desen_telephone) in ('null', '') then null else trim(a.desen_telephone) end as desen_telephone,
    case when trim(a.oaid) in ('null', '') then null else trim(a.oaid) end as oaid,
    current_timestamp as insert_timestamp
from 
(
    select 
        * 
    from 
    (
        select *, row_number() over(partition by sales_order_sys_id, sales_order_address_sys_id order by dt desc) rownum from ODS_OMS.Sales_Order_Address
    ) t
    where rownum = 1
) a
left join 
    (select distinct province_name,province_short_name from DW_Common.DIM_Area) t1
on trim(a.province) = t1.province_name
left join 
    (select distinct province_short_name, city_name, city_short_name from DW_Common.DIM_Area) t2
on (case when t1.province_short_name is not null then t1.province_short_name else trim(a.province) end) = t2.province_short_name
and trim(a.city) = t2.city_name
left join
    (select distinct province_short_name, city_short_name, district_name, district_short_name from DW_Common.DIM_Area) t3
on (case when t1.province_short_name is not null then t1.province_short_name else trim(a.province) end) = t3.province_short_name
and trim(a.city) = t3.district_name
left join 
    (select distinct province_short_name, district_name, district_short_name from DW_Common.DIM_Area) t4
on (case when t1.province_short_name is not null then t1.province_short_name else trim(a.province) end) = t4.province_short_name
and trim(a.district) = t4.district_name
END


GO
