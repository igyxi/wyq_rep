/****** Object:  StoredProcedure [TEMP].[SP_DW_Promotion_Order_Bak_20230620]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_Promotion_Order_Bak_20230620] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-05       tali           Initial Version
-- 2023-04-17       wangzhichun    change source
-- 2023-04-21       wangzhichun    	   update json field 
-- ========================================================================================
truncate table [DW_Order].[DW_Promotion_Order];
insert into [DW_Order].[DW_Promotion_Order]
select
    t.order_id,
    null as merge_oid,
    ta.promotion_id,
    ta.promotion_name,
    ta.promotion_content,
    ta.promotion_type,
    ta.promotion_adjustment,
    ta.coupon_code,
    ta.offer_id,
    ta.offer_type,
    ta.offer,
    t.skucode as item_sku_code,
    t.quantity,
    t.total_amount,
    sum(t.total_amount) over(partition by t.order_id, ta.promotion_id) as promotion_total_amount,
    ta.create_time,
    ta.update_time,
    CURRENT_TIMESTAMP
from 
(
    select 
        b.merge_oid,
        a.order_id,
        a.promotion_id,
        d.promotion_name,
        a.promotion_content,
        d.promotion_type,
        a.promotion_adjustment,
        a.coupon_code,
        a.offer_id,
        c.[type] as offer_type,
        convert(varchar(4000),c.offer,0) as offer,
        a.item_sku_id,
        a.create_time,
        a.update_time
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
            update_time,
            value as item_sku_id
        from
            STG_Order.Order_Promotion
        CROSS APPLY STRING_SPLIT(sku_id, ',')
    ) a
    left join 
    (
        select distinct oid, merge_oid from STG_Order.Merge_Order where [current] = 1
    ) b
    on a.order_id = b.oid
    left join
        ODS_Promotion.Promotion_Offer c
    on a.promotion_id = c.promotion_sys_id
    and a.offer_id = c.promotion_offer_sys_id
    left join
        ODS_Promotion.promotion d
    on a.promotion_id = d.promotion_sys_id
    where 
        convert(varchar(4000),d.customer_group,0) <> '["TEST"]'
    and b.oid is null
) ta
inner join
    STG_Order.OrderItems t
on t.order_id = ta.order_id
and t.sku_id = ta.item_sku_id
union all
select
    t.order_id,
    t.merge_oid,
    ta.promotion_id,
    ta.promotion_name,
    ta.promotion_content,
    ta.promotion_type,
    ta.promotion_adjustment,
    ta.coupon_code,
    ta.offer_id,
    ta.offer_type,
    ta.offer,
    t.item_sku_code,
    t.quantity,
    t.total_amount,
    sum(t.total_amount) over(partition by t.merge_oid, ta.promotion_id) as promotion_total_amount,
    ta.create_time,
    ta.update_time,
    CURRENT_TIMESTAMP
from 
(
    select 
        b.merge_oid,
        a.order_id,
        a.promotion_id,
        d.promotion_name,
        a.promotion_content,
        d.promotion_type,
        a.promotion_adjustment,
        a.coupon_code,
        a.offer_id,
        c.[type] as offer_type,
        convert(varchar(4000),c.offer,0) as offer,
        a.item_sku_id,
        a.create_time,
        a.update_time
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
            update_time,
            value as item_sku_id
        from
            STG_Order.Order_Promotion
        CROSS APPLY STRING_SPLIT(sku_id, ',')
    ) a
    join 
    (
        select distinct oid, merge_oid from STG_Order.Merge_Order where [current] = 1
    ) b
    on a.order_id = b.oid
    left join
        ODS_Promotion.Promotion_Offer c
    on a.promotion_id = c.promotion_sys_id
    and a.offer_id = c.promotion_offer_sys_id
    left join
        ODS_Promotion.promotion d
    on a.promotion_id = d.promotion_sys_id
    where 
        convert(varchar(4000),d.customer_group,0) <> '["TEST"]'
) ta
inner join
(
    select distinct
        b.merge_oid,
        a.order_id,
        a.sku_id,
        a.skucode as item_sku_code,
        a.quantity,
        a.total_amount,
        a.total_adjustment
    from  
        STG_Order.OrderItems a
    join 
    (
        select distinct oid, merge_oid from STG_Order.Merge_Order where [current] = 1 
    ) b 
    on a.order_id = b.oid
) t
on t.merge_oid = ta.merge_oid
and t.sku_id = ta.item_sku_id
;
END


GO
