/****** Object:  StoredProcedure [STG_Order].[TRANS_OrderItems]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Order].[TRANS_OrderItems] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-31       wangzhichun        Initial Version
-- 2022-04-11       wangzhichun        add column
-- 2022-05-25       wangzhichun        add column
-- 2022-07-07       tali               change order_id as hash column
-- 2022-09-29       wubin              add live_room_id/live_channel
-- ========================================================================================
truncate table STG_Order.OrderItems;
insert into STG_Order.OrderItems
select 
    case when trim(id) in ('null','') then null else trim(id) end as id,
    case when trim(order_id) in ('null','') then null else trim(order_id) end as order_id,    
    case when trim(sku_id) in ('null','') then null else trim(sku_id) end as sku_id,
    case when trim(skucode) in ('null','') then null else trim(skucode) end as skucode,
    type,
    offer_price,
    sap_price,
    total_amount,
    total_adjustment,
    shipping,
    shipping_adjustment,
    quantity,
    case when trim(status) in ('null','') then null else trim(status) end as status,
    user_id,
    case when trim(address_id) in ('null','') then null else trim(address_id) end as address_id,
    create_time,
    create_user,
    update_time,
    update_user,
    case when trim(image_path) in ('null','') then null else trim(image_path) end as image_path,
    case when trim(brands) in ('null','') then null else trim(brands) end as brands,
    case when trim(product_name_cn) in ('null','') then null else trim(product_name_cn) end as product_name_cn,
    case when trim(product_name_en) in ('null','') then null else trim(product_name_en) end as product_name_en,
    case when trim(sale_attr) in ('null','') then null else trim(sale_attr) end as sale_attr,
    case when trim(product_id) in ('null','') then null else trim(product_id) end as product_id,
    case when trim(category) in ('null','') then null else trim(category) end as category,
    case when trim(type1) in ('null','') then null else trim(type1) end as type1,
    case when trim(wcs_id) in ('null','') then null else trim(wcs_id) end as wcs_id,
    estimated_delivery_time,
    page_estimated_delivery_time,
    case when trim(obtain_method) in ('null','') then null else trim(obtain_method) end as obtain_method,
    comments,
    case when trim(return_status) in ('null','') then null else trim(return_status) end as return_status,
    case when trim(current_return_status) in ('null','') then null else trim(current_return_status) end as current_return_status,
    case when trim(source) in ('null','') then null else trim(source) end as source,
    expire_time,
    is_delete,
    case when trim(exchange_discount) in ('null','') then null else trim(exchange_discount) end as exchange_discount,
    case when trim(activity_info) in ('null','') then null else trim(activity_info) end as activity_info,
    integral,
    item_id,
    case when trim(tag_comment) in ('null','') then null else trim(tag_comment) end as tag_comment,
    case when trim(live_room_id) in ('','null') then null else trim(live_room_id) end as live_room_id,
    case when trim(live_channel) in ('','null') then null else trim(live_channel) end as live_channel,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id, order_id order by dt desc) rownum from ODS_Order.OrderItems
) t
where rownum = 1
END

GO
