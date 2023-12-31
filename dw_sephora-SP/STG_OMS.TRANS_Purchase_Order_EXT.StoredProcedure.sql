/****** Object:  StoredProcedure [STG_OMS].[TRANS_Purchase_Order_EXT]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Purchase_Order_EXT] AS
BEGIN
truncate table STG_OMS.Purchase_Order_EXT;
insert into STG_OMS.Purchase_Order_EXT
select 
    purchase_order_ext_sys_id,
    purchase_order_sys_id,
    case when trim(r_oms_order_sys_id) in ('null','') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    case when trim(purchase_order_number) in ('null','') then null else trim(purchase_order_number) end as purchase_order_number,
    create_time,
    update_time,
    case when trim(apply_type) in ('null','') then null else trim(apply_type) end as apply_type,
    case when trim(apply_status) in ('null','') then null else trim(apply_status) end as apply_status,
    case when trim(apply_kuaidi_status) in ('null','') then null else trim(apply_kuaidi_status) end as apply_kuaidi_status,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by purchase_order_ext_sys_id order by dt desc) rownum from ODS_OMS.Purchase_Order_EXT
) t
where rownum = 1
END


GO
