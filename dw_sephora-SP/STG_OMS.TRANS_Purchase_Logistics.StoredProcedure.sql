/****** Object:  StoredProcedure [STG_OMS].[TRANS_Purchase_Logistics]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Purchase_Logistics] AS 
begin
truncate table STG_OMS.Purchase_Logistics;
insert into STG_OMS.Purchase_Logistics
select 
    purchase_order_logistics_sys_id,
    case when trim(lower(r_oms_stkout_hd_sys_id)) in ('','null') then null else trim(r_oms_stkout_hd_sys_id) end as r_oms_stkout_hd_sys_id,
    purchase_order_sys_id,
    case when trim(lower(logistics_shipping_company)) in ('','null') then null else trim(logistics_shipping_company) end as logistics_shipping_company,
    case when trim(lower(logistics_number)) in ('','null') then null else trim(logistics_number) end as logistics_number,
    logistics_shipping_time,
    logistics_sign_time,
    create_time,
    update_time,
    need_flag,
    case when trim(lower(create_user)) in ('','null') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('','null') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp
from 
(
    select *,row_number() over(partition by purchase_order_logistics_sys_id order by dt desc) rownum from ODS_OMS.Purchase_Logistics
) t
where rownum = 1;
end



GO
