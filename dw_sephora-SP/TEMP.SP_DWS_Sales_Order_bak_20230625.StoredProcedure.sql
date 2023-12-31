/****** Object:  StoredProcedure [TEMP].[SP_DWS_Sales_Order_bak_20230625]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Sales_Order_bak_20230625] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-03-31       wangzhichun        update channel_id
-- 2023-01-10       wangzhichun        add split_flag
-- 2023-06-19       Leozhai            change order source to ODS
-- 2023-06-26       Leozhai           fix orders group_name logic
-- ========================================================================================
truncate table DW_OMS.DWS_Sales_Order;
insert into DW_OMS.DWS_Sales_Order
select 
    a.sales_order_sys_id,
    c.sales_order_item_sys_id,
    a.sales_order_number,
    a.type,
    a.store_id,
    case when a.channel_id = 'TMALL' and a.shop_id = 'TM2' then 'TMALL_WEI' 
         when a.channel_id = 'TMALL' and a.store_id = 'TMALL004' then 'TMALL_CHALING' 
         when a.channel_id = 'TMALL' and a.store_id = 'TMALL005' then 'TMALL_PTR'
         when a.channel_id = 'TMALL' and a.store_id = 'TMALL006' then 'TMALL_WEI'
         when a.channel_id = 'JD' and a.store_id = 'JD003' then 'JD_FCS'
    else a.channel_id end as channel_id,
    a.shop_id,
    b.province,
    b.city,
    b.district,
    a.member_id,
    a.open_id,
    a.member_card,
    gi.mobile_guid,
    a.order_consumer,
    a.payment_time,
    cast(a.payment_time as date) as payment_date,
    a.order_time,
    cast(a.order_time as date) as order_date,
    a.basic_status,
    a.order_internal_status,
    a.payment_status,
    a.product_total,
    a.shipping_total,
    a.order_amount,
    a.payed_amount,
    a.adjustment_total,
    a.coupon_adjustment_total,
    a.promotion_adjustment_total,
    a.need_invoice_flag,
    a.buyer_comment,
    a.buyer_memo,
    case when a.store_id = 'S001' and a.channel_id = 'O2O' then substring(a.buyer_memo,1,4) else null end as o2o_shop_cd,
    a.origin_shipping_fee,
    a.black_card_user_flag,
    a.platform_flag,
    COALESCE(a.member_card_grade, d.group_name) as member_card_grade,
    a.packing_box_flag,
    a.packing_box_price,
    a.seller_delivery_time,
    cast(a.seller_delivery_time as date) as seller_delivery_date,
    a.shipping_type,
    a.shop_pick,
    -- a.end_time,
    a.order_expected_ware_house,
    a.related_order_number,
    a.times_flag,
    a.cancel_type,
    a.super_order_id,
    a.food_order_flag,
    a.payable_amount,
    a.coupon_amount,
    a.deal_type,
    a.deposit_flag,
    a.merge_flag,
    a.smartba_flag,
    a.split_flag,
    c.item_quantity,
    c.item_market_price,
    c.item_sale_price,
    c.item_adjustment_unit,
    c.item_adjustment_total,
    c.apportion_amount_unit,
    c.apportion_amount,
    c.item_sku,
    c.item_name,
    c.item_description,
    c.item_brand,
    c.item_product_id,
    c.item_type,
    c.order_item_source,
    c.item_category,
    c.returned_quantity,
    c.apply_quantity,
    c.sale_org,
    c.have_srv_flag,
    c.task_flag,
    c.deal_type,
    c.deal_type_flag,
    c.promotion_num,
    c.tmall_oid,
    c.jd_sku_id,
    c.item_order_tax_fee,
    c.item_discount_fee,
    c.item_sub_order_tax_promotion_fee,
    c.presales_date,
    c.douyin_oid,
    c.source,
    case 
        when a.store_id = 'S001' then  COALESCE(a.member_card, a.member_id)
        when  a.store_id='DOUYIN001' then  concat(a.member_id,b.province,b.city,b.district)
        else a.member_id
    end as super_id,
    case when a.type = 8 then a.order_time 
        else COALESCE(a.payment_time, a.order_time)
    end as place_time, 
    cast(
        case when a.type = 8 then a.order_time 
            else COALESCE(a.payment_time, a.order_time)
        end as date
    ) as place_date,
    case 
        when a.basic_status <> 'DELETED' and a.type not in (2, 9) and a.payment_status = 1
        and (a.order_internal_status like '%SIGNED%' or a.order_internal_status like '%SHIPPED%')
        and a.product_total > 1 then 1
        else 0 
    end as is_valid_flag,
    case when a.basic_status <> 'DELETED' and a.store_id not in ('TMALL002', 'GWP001') and a.type not in (2, 9)
        and ((a.payment_status = 1 and a.payment_time is not null) or a.type = 8)
        and a.product_total > 1 then 1
        else 0 
    end as is_placed_flag,
    case 
        when COALESCE(member_card_grade,group_name) = 'PINK'  then 1
        when COALESCE(member_card_grade,group_name) = 'NEW' then 2
        when COALESCE(member_card_grade,group_name) = 'WHITE' then 3
        when COALESCE(member_card_grade,group_name) = 'BLACK' then 4
        when COALESCE(member_card_grade,group_name) = 'GOLD' then 5
        else 0
    end as member_card_level,
    a.create_time,
    cast(a.create_time as date) as create_date,
    a.update_time,
    cast(a.update_time as date) as update_date,
    a.end_time,
    cast(a.end_time as date) as end_date,
    a.version,
    a.is_delete,
    current_timestamp as insert_timestamp
from
    STG_OMS.Sales_Order a
left join
(
    select 
        order_id,
        case 
            when trim(lower(group_name)) in ('null', '') then null 
            when trim(group_name) = 'GOLDEN' then 'GOLD'
            else trim(group_name) 
        end as group_name 
    from 
        ODS_Order.Orders where group_name <> 'O2O'
) d
on a.sales_order_number = d.order_id
left join 
(
    select 
        sales_order_sys_id,
        province,
        city,
        district,
        row_number() over(partition by sales_order_sys_id order by create_time desc) rn 
    from 
        STG_OMS.Sales_order_Address 
    where 
        is_delete = 0
) b
on a.sales_order_sys_id = b.sales_order_sys_id
and b.rn = 1
left join
    STG_OMS.Sales_Order_Item c
on a.sales_order_sys_id = c.sales_order_sys_id
left join 
(
    select sales_order_sys_id,cast(mobile_guid as varchar) as mobile_guid from STG_OMS.Order_Guid_Info
) gi
on a.sales_order_sys_id = gi.sales_order_sys_id;
UPDATE STATISTICS DW_OMS.DWS_Sales_Order;
end
GO
