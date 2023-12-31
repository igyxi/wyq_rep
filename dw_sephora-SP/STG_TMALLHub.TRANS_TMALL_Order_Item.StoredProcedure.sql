/****** Object:  StoredProcedure [STG_TMALLHub].[TRANS_TMALL_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TMALLHub].[TRANS_TMALL_Order_Item] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_TMALLHub.TMALL_Order_Item;
insert into STG_TMALLHub.TMALL_Order_Item
select 
    id,
    case when trim(order_id) in ('null','') then null else trim(order_id) end as order_id,
    case when trim(oid) in ('null','') then null else trim(oid) end as oid,
    case when trim(sku_id) in ('null','') then null else trim(sku_id) end as sku_id,
    case when trim(outer_sku_id) in ('null','') then null else trim(outer_sku_id) end as outer_sku_id,
    case when trim(sku_properties_name) in ('null','') then null else trim(sku_properties_name) end as sku_properties_name,
    case when trim(title) in ('null','') then null else trim(title) end as title,
    price,
    payment,
    num,
    divide_order_fee,
    tax_coupon_discount,
    discount_fee,
    case when trim(tax_free) in ('null', '') then null 
         when trim(tax_free) = 'false' then 0 
         when trim(tax_free) = 'true' then 1
    end as tax_free,
    total_fee,
    part_mjz_discount,
    sub_order_tax_promotion_fee,
    sub_order_tax_fee,
    case when trim(is_delete) in ('null', '') then null 
         when trim(is_delete) = 'false' then 0 
         when trim(is_delete) = 'true' then 1
    end as is_delete,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    current_timestamp as insert_timestamp
from 
    ODS_TMALLHub.TMALL_Order_Item
where dt = @dt
END


GO
