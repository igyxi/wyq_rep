/****** Object:  StoredProcedure [DW_Promotion].[SP_DWS_OMS_Order_Promotion]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Promotion].[SP_DWS_OMS_Order_Promotion] AS 
begin
truncate table [DW_Promotion].[DWS_OMS_Order_Promotion];
insert into [DW_Promotion].[DWS_OMS_Order_Promotion]
select
    tb.order_id as sales_order_number,
    tb.is_placed,
    tb.place_time,
    tb.channel_code,
    tb.sub_channel_code,
    tb.member_card,
    tb.store_code,
    tb.item_sku_code,
    tb.item_quantity,
    tb.item_total_amount,
    tb.item_discount_amount,
    tb.item_apportion_amount,
    ta.promotion_id as promotion_id,
    tc.promotion_name  as promotion_name,
    ta.promotion_content as promotion_content,
    tc.promotion_type as promotion_type,
    ta.promotion_adjustment as promotion_adjustment_amount,
    ta.promotion_adjustment * tb.sku_rate as promotion_sku_adjustment_amount,
    ta.coupon_code,
    ta.offer_type,
    CONVERT(varchar, ta.create_time, 120) as create_time,
    'OMS' as source,
    CURRENT_TIMESTAMP as insert_timestamp
from 
(
    select
        case when merge_oid is null then A.order_id else B.merge_oid end merge_oid,
        value as sku_id_value,
        a.promotion_id,
        a.coupon_code,
        a.promotion_content,
        a.promotion_adjustment,
        a.offer_id,
        c.[type] as offer_type,
        a.create_time
    from 
    (
        select distinct
            order_id, 
            promotion_id, 
            coupon_code,
            promotion_content,
            promotion_adjustment, 
            offer_id,
            create_time,
            value
        from
            [STG_Order].[Order_Promotion] (nolock)
        CROSS APPLY STRING_SPLIT(sku_id, ',')
    ) a
    left join 
    (
        select oid, merge_oid, row_number() over(partition by oid order by create_time desc) rn from [STG_Order].[Merge_Order]  (nolock) 
    ) b
    on a.order_id = b.oid
    and b.rn = 1
    left join 
        STG_Promotion.Promotion_Offer c
    on a.promotion_id = c.promotion_sys_id
) ta
join 
(   
    select 
        *, 
        case when item_total_amount is null or item_total_amount = 0 then 0.0 
            else item_total_amount/sum(item_total_amount)over(partition by merge_oid) 
        end as sku_rate
    from 
    (
        -- select 
        --     t1.merge_oid,
        --     t1.order_id,
        --     t1.card_no,
        --     t1.channel_code,
        --     t1.sub_channel_code,
        --     t1.is_placed,
        --     t1.place_time,
        --     t1.sku_id,
        --     isnull(t2.item_sku, t1.skucode) as skucode,
        --     isnull(t2.quantity, t1.quantity) as quantity,
        --     isnull(t2.total_amount, t1.total_amount) as total_amount,
        --     isnull(t2.total_adjustment, t1.total_adjustment) as total_adjustment,
        --     isnull(t2.apportion_amount, t1.total_amount - t1.total_adjustment) as Sales_VAT
        -- from
        -- (
        select
            case when merge_oid is null then c.order_id else B.merge_oid end merge_oid,
            c.order_id,
            c.card_no,
            a.sales_order_number as sales_order_number,
            a.channel_code,
            a.sub_channel_code,
            a.is_placed,
            a.place_time,
            a.member_card,
            a.store_code,
            d.sku_id, 
            a.item_sku_code,
            a.item_quantity,
            a.item_total_amount,
            a.item_apportion_amount,
            a.item_discount_amount
            -- d.skucode,
            -- d.quantity,
            -- d.total_amount,
            -- abs(d.total_adjustment) total_adjustment  --折扣减免金额
        from  
            [STG_Order].[Orders] c
        join
            DW_OMS.DWS_Sales_Order_With_SKU a
        on c.order_id = a.sales_order_number
        left join 
        (
            select oid, merge_oid, row_number() over(partition by oid order by create_time desc) rn from [STG_Order].[merge_Order]  (nolock) 
        )b 
        on c.order_id = b.oid
        and b.rn = 1
        left join
            [STG_Order].[Orderitems] (nolock) d 
        on c.order_id = d.order_id
        -- ) t1
        -- join
        -- (
        --     select
        --         a.sales_order_number,
        --         c.sku_id,
        --         b.item_sku,
        --         sum(b.item_quantity) as quantity,
        --         sum(b.apportion_amount) as apportion_amount,
        --         sum(abs(b.item_adjustment_total)) as total_adjustment,
        --         sum(b.apportion_amount + abs(b.item_adjustment_total)) as total_amount
        --     from 
        --         STG_OMS.Purchase_Order a
        --     left join 
        --         STG_OMS.Purchase_Order_item b
        --     on b.purchase_order_sys_id = a.purchase_order_sys_id
        --     left join
        --         STG_Product.PROD_SKU c
        --     on isnull(b.virtual_sku, b.item_sku) = c.sku_code
        --     where 
        --         a.split_type <> 'SPLIT_ORIGIN'
        --         and a.basic_status <> 'DELETED'
        --         and a.type <> 2
        --     group by sales_order_number,item_sku,c.sku_id
        -- ) t2
        -- on t1.sales_order_number = t2.sales_order_number
        -- and t1.sku_id = t2.sku_id
    ) t
) tb 
on ta.merge_oid = tb.merge_oid
and ta.sku_id_value = tb.sku_id
left join
    stg_promotion.promotion(nolock) tc
on ta.promotion_id=tc.promotion_sys_id
;
end


GO
