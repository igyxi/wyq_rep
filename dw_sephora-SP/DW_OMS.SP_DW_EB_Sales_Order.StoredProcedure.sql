/****** Object:  StoredProcedure [DW_OMS].[SP_DW_EB_Sales_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DW_EB_Sales_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-09       LeoZhai           Initial Version
-- ========================================================================================
truncate table [DWD].[Fact_EB_Sales_Order];
insert into DWD.Fact_EB_Sales_Order
select
    a.sales_order_number as sales_order_number,
    a.channel_id,
    a.channel_code,
    a.channel_name,
    a.sub_channel_code,
    a.sub_channel_name,
    td.province as province,
    td.city as city,
    td.district,
    a.store_name,
    a.o2o_shop_cd,
    a.[type] as type_code,
    a.member_id,
    a.member_card,
    a.member_card_grade,
    a.payment_status as payment_status,
    a.payed_amount as payment_amount,
    a.order_internal_status as order_status,
    a.order_time,
    a.payment_time,
    a.is_valid,
    a.is_placed,
    a.place_time,
    a.place_date,
    a.smartba_flag,
    a.ouid,

    a.shipping_type,
    a.shop_pick,
    a.order_expected_ware_house,
    a.related_order_number,
    a.times_flag,
    a.cancel_type,
    a.super_order_id,
    a.food_order_flag,
    a.payable_amount,
    a.coupon_amount,
    a.deal_type as so_deal_type,
    a.deposit_flag,
    a.merge_flag,
    a.split_flag,




    case 
        when a.store_id = 'S001' then  COALESCE(a.member_card, a.member_id)
        when a.store_id='DOUYIN001' then  concat(a.member_id,td.province,td.city,td.district)
        else a.member_id
    end as super_id,

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

    CURRENT_TIMESTAMP as insert_timestamp

select
    a.sales_order_sys_id,
    a.sales_order_number,
    a.store_id,
    case when a.channel_id = 'TMALL' and a.shop_id = 'TM2' then 'TMALL_WEI' 
        when a.channel_id = 'TMALL' and a.store_id = 'TMALL004' then 'TMALL_CHALING' 
        when a.channel_id = 'TMALL' and a.store_id = 'TMALL005' then 'TMALL_PTR'
        when a.channel_id = 'TMALL' and a.store_id = 'TMALL006' then 'TMALL_WEI'
        when a.channel_id = 'JD' and a.store_id = 'JD003' then 'JD_FCS'
    else a.channel_id end channel_id,
    si.channel_id as channel_code,
    si.channel_name,
    case when a.store_id = 'S001' then a.channel_id
        when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006'
        else a.store_id
    end as sub_channel_code,
    case
        when a.store_id = 'S001' then a.channel_id
        when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then N'天猫WEI旗舰店'
        else si.store_name
    end as sub_channel_name,
    si.store_name,
    case when a.store_id = 'S001' and a.channel_id = 'O2O' then substring(a.buyer_memo,1,4) else null end as o2o_shop_cd,
    a.type,
    a.member_id,
    case when si.channel_id = 'JD' and a.member_card like 'JD%' then SUBSTRING(a.member_card, 3, len(a.member_card)-2) else a.member_card end as member_card,
    COALESCE(a.member_card_grade, b.group_name) as member_card_grade,
    a.order_internal_status,
    a.order_time,
    a.payment_status,
    a.payment_time,
    a.payed_amount,
    case 
        when a.basic_status <> 'DELETED' and a.type not in (2, 9) and a.payment_status = 1
        and (a.order_internal_status like '%SIGNED%' or a.order_internal_status like '%SHIPPED%')
        and a.product_total > 1 then 1
        else 0 
    end as is_valid,
    case when a.basic_status <> 'DELETED'
        and a.store_id not in ('TMALL002', 'GWP001')
        and a.type not in (2, 9)
        and ((a.payment_status = 1 and a.payment_time is not null) or a.type = 8)
        and a.product_total > 1 then 1
        else 0
    end as is_placed,
    case when a.type = 8 then a.order_time
        else COALESCE(a.payment_time, a.order_time)
    end as place_time,
    cast(
        case when a.type = 8 then a.order_time 
            else COALESCE(a.payment_time, a.order_time)
        end as date
    ) as place_date,
    case when a.smartba_flag is not null then a.smartba_flag
         when os.order_id is not null and a.channel_id = 'MINIPROGRAM' then 1
        else 0
    end as smartba_flag,
    a.ouid,
    a.shipping_type,
    a.shop_pick,
    a.order_expected_ware_house,
    a.related_order_number,
    a.times_flag,
    a.cancel_type,
    a.super_order_id,
    a.food_order_flag,
    a.payable_amount,
    a.coupon_amount,
    a.deal_type as so_deal_type,
    a.deposit_flag,
    a.merge_flag,
    a.split_flag,

    case 
        when a.store_id = 'S001' then  COALESCE(a.member_card, a.member_id)
        when a.store_id='DOUYIN001' then  concat(a.member_id,td.province,td.city,td.district)
        else a.member_id
    end as super_id,

    tc.item_quantity,
    tc.item_market_price,
    tc.item_sale_price,
    tc.item_adjustment_unit,
    tc.item_adjustment_total,
    tc.apportion_amount_unit,
    tc.apportion_amount,
    tc.item_sku,
    tc.item_name,
    tc.item_description,
    tc.item_brand,
    tc.item_product_id,
    tc.item_type,
    tc.order_item_source,
    tc.item_category,
    tc.returned_quantity,
    tc.apply_quantity,
    tc.sale_org,
    tc.have_srv_flag,
    tc.task_flag,
    tc.deal_type,
    tc.deal_type_flag,
    tc.promotion_num,
    tc.tmall_oid,
    tc.jd_sku_id,
    tc.item_order_tax_fee,
    tc.item_discount_fee,
    tc.item_sub_order_tax_promotion_fee,
    tc.presales_date,
    tc.douyin_oid,
    tc.source,

    CURRENT_TIMESTAMP as insert_timestamp
from
    STG_OMS.Sales_Order a
left join
(
    select order_id, group_name from STG_Order.Orders where group_name <> 'O2O'
) b
on a.sales_order_number = b.order_id
left join
    ODS_OMS.OMS_Store_Info si
on case when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006' else a.store_id end = si.store_id
left join
(
    select distinct
        order_id
    from
        STG_Order.Order_Source
    where
        utm_campaign = 'BA'
    and
        utm_medium ='seco'
) os
on  a.sales_order_number = os.order_id
left join
    STG_OMS.Sales_Order_item tc
on a.sales_order_sys_id = tc.sales_order_sys_id
left join
(
    select
        sales_order_sys_id,
        opcm.crm_province as province,
        opcm.crm_city as city,
        soa.district,
        row_number() over(partition by sales_order_sys_id order by create_time desc) rn
    from
        STG_OMS.Sales_order_Address soa
    left join
        STG_OMS.OMS_Province_City_Mapping opcm
    on soa.province = opcm.oms_province
    and isnull(soa.city, '') = isnull(opcm.oms_city, '')
    where
        soa.is_delete = 0
) td
on a.sales_order_sys_id = td.sales_order_sys_id
and td.rn = 1
left join 
(
    select sales_order_sys_id,cast(mobile_guid as varchar) as mobile_guid from STG_OMS.Order_Guid_Info
) gi
on a.sales_order_sys_id = gi.sales_order_sys_id;

END


GO
