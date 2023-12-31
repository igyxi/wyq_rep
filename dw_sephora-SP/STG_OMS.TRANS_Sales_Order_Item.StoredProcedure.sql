/****** Object:  StoredProcedure [STG_OMS].[TRANS_Sales_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Sales_Order_Item] AS
BEGIN
truncate table STG_OMS.Sales_Order_Item;
insert into STG_OMS.Sales_Order_Item
select 
    sales_order_item_sys_id,
    sales_order_sys_id,
    case when trim(lower(r_oms_order_item_sys_id)) in ('null', '') then null else trim(r_oms_order_item_sys_id) end as r_oms_order_item_sys_id,
    case when trim(lower(r_oms_order_sys_id)) in ('null', '') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    item_quantity,
    item_market_price,
    item_sale_price,
    item_adjustment_unit,
    item_adjustment_total,
    apportion_amount,
    apportion_amount_unit,
    case when trim(lower(item_sku)) in ('null', '') then null else trim(item_sku) end as item_sku,
    case when trim(lower(item_name)) in ('null', '') then null else trim(item_name) end as item_name,
    case when trim(lower(item_description)) in ('null', '') then null else trim(item_description) end as item_description,
    case when trim(lower(item_brand)) in ('null', '') then null else trim(item_brand) end as item_brand,
    case when trim(lower(item_product_id)) in ('null', '') then null else trim(item_product_id) end as item_product_id,
    update_time,
    case 
        when trim(lower(item_type)) in ('null', '') then null
        when trim(item_type) = N'正常商品' then 'NORMAL'
        else trim(item_type) 
    end as item_type,
    case when trim(lower(item_size)) in ('null', '') then null else trim(item_size) end as item_size,
    case when trim(lower(item_color)) in ('null', '') then null else trim(item_color) end as item_color,
    item_weight,
    case when trim(lower(order_item_source)) in ('null', '') then null else trim(order_item_source) end as order_item_source,
    case when trim(lower(item_category)) in ('null', '') then null else trim(item_category) end as item_category,
    create_time,
    sys_create_time,
    sys_update_time,
    returned_quantity,
    apply_quantity,
    case when trim(lower(sale_org)) in ('null', '') then null else trim(sale_org) end as sale_org,
    case when trim(lower(have_srv_flag)) in ('null', '') then null else trim(have_srv_flag) end as have_srv_flag,
    case when trim(lower(task_flag)) in ('null', '') then null else trim(task_flag) end as task_flag,
    tax_rate,
    adjustment_amount,
    deposit_amount,
    platform_adjustment_amount,
    srv_fee,
    transport_fee,
    gift_card_amount,
    case when trim(lower(deal_type)) in ('null', '') then null else trim(deal_type) end as deal_type,
    case when trim(lower(deal_type_flag)) in ('null', '') then null else trim(deal_type_flag) end as deal_type_flag,
    case when trim(lower(promotion_num)) in ('null', '') then null else trim(promotion_num) end as promotion_num,
    tmall_oid,
    case when trim(lower(jd_sku_id)) in ('null', '') then null else trim(jd_sku_id) end as jd_sku_id,
    item_order_tax_fee,
    item_discount_fee,
    item_sub_order_tax_promotion_fee,
    case when trim(lower(create_user)) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    presales_date,
    case when trim(lower(douyin_oid)) in ('null', '') then null else trim(douyin_oid) end as douyin_oid,
    case when trim(lower(source)) in ('null', '') then null else trim(source) end as source,
    case when trim(lower(activity_id)) in ('null', '') then null else trim(activity_id) end as activity_id,
    case when trim(lower(activity_type)) in ('null', '') then null else trim(activity_type) end as activity_type,
    case when trim(lower(third_server_rate)) in ('null', '') then null else trim(third_server_rate) end as third_server_rate,
    third_server_amount,
    case when trim(lower(author_name)) in ('null', '') then null else trim(author_name) end as author_name,
    case when trim(lower(author_id)) in ('null', '') then null else trim(author_id) end as author_id,
    case when trim(lower(video_id)) in ('null', '') then null else trim(video_id) end as video_id,
    case when trim(lower(room_id)) in ('null', '') then null else trim(room_id) end as room_id,
    case when trim(lower(live_room_id)) in ('null', '') then null else trim(live_room_id) end as live_room_id,
    case when trim(lower(live_channel)) in ('null', '') then null else trim(live_channel) end as live_channel,
    current_timestamp as insert_timestamp
from 
(
    select *, ROW_NUMBER() over (partition by sales_order_sys_id, sales_order_item_sys_id order by dt desc) rownum from ODS_OMS.Sales_Order_Item
)t
where rownum = 1
END


GO
