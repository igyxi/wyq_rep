/****** Object:  StoredProcedure [DWD].[INI_Fact_Coupon_Offer]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[INI_Fact_Coupon_Offer] @dt [varchar](10) AS 
begin
delete from [DWD].[Fact_Coupon_Offer_New] where create_time >= @dt and create_time < dateadd(month,1,@dt);
with account_offer as
(
    select
        ao.account_offer_id,
        ao.account_id,
        o.offer_id,
        o.offer_name,
        ot.offer_type_name_en as offer_type,
        ot.offer_type_name,
        o.sku as sku_code,
        ao.qty,
        ISNULL(ao.effective_from_date, ao.create_time) as effective_from_date,
        ao.effective_to_date,
        ao.status,
        CASE WHEN ao.status IN (2,5) THEN ISNULL(ao.used_time,ao.setting_time) ELSE ao.used_time END used_time,
        ao.expired_time,
        ao.place_id as store_id,
        ao.create_time,
        ao.setting_time as update_time
    from 
        ODS_CRM.account_offer ao
    left join 
        ODS_CRM.offer o 
    on ao.offer_id=o.offer_id
    left join 
        ODS_CRM.offer_type ot 
    on o.offer_type_id = ot.offer_type_id
    left join 
        ODS_CRM.crm_product p 
    on o.crm_product_id = p.crm_product_id
    where
        ao.create_time >= @dt 
    and ao.create_time < dateadd(month,1,@dt)
)
-- crm_order as (
--     select 
--         case when c.channel_code <> 'OFF_LINE' then d.sales_order_number else c.invc_no end as sales_order_number,
--         c.member_id, 
--         c.item_sku_code, 
--         c.order_time,
--         c.sap_time,
--         c.coupon_offer_id
--     from
--         DW_CRM.DWS_Trans_Order_With_SKU c
--     join
--         ODS_CRM.offer f
--     on c.item_sku_code = f.sku
--     left join
--         STG_OMS.Purchase_Order d
--     on c.invc_no = d.purchase_order_number
--     and c.channel_code <> 'OFF_LINE'
--     where
--         c.item_quantity > 0
--     -- and c.order_time > DATEADD(day, -10, @dt)
--     -- and c.order_time < DATEADD(day, 1, @dt)
-- )

insert into [DWD].[Fact_Coupon_Offer_New]
select
    a.account_offer_id as coupon_offer_id,
    a.sku_code as coupon_code,
    m.member_card,
    a.[status] as coupon_offer_status,
    a.qty as quantity,
    a.effective_from_date as start_date,
    a.effective_to_date as end_date,
    a.used_time,
    a.expired_time as expired_time,
    a.offer_id as offer_id,
    a.offer_name  as offer_name,
    a.offer_type as offer_type,
    a.offer_type_name,
    -- isnull(c.sales_order_number, t.sales_order_number) as sales_order_number,
    -- c.sales_order_number,
    null sales_order_number,
    s.store_code,
    -- a.Offer_CardType as offer_card_type,
    -- t.sales_order_number as sales_order_number,
    a.create_time as create_time,
    a.update_time as update_time,
    'CRM'  as source,
    current_timestamp as insert_timestamp
from 
    account_offer a
-- (
--     select 
--         *,
--         row_number() over(partition by account_id, sku_code, [status] order by  used_time, effective_to_date) rownum 
--     from 
--         accout_offer
-- ) a
left join 
    ODS_CRM.DIMStore s
on a.store_id = s.store_id
left join
    DWD.DIM_Member_Info m
on  a.account_id = m.member_id
-- left join 
-- (
--     select 
--         sales_order_number, 
--         coupon_offer_id, 
--         row_number() over(partition by coupon_offer_id order by sap_time desc) rownum
--     from 
--         crm_order 
--     where 
--         coupon_offer_id is not null 
-- ) c
-- on a.account_offer_id = c.coupon_offer_id
-- and c.rownum = 1;
END
-- left join 
-- (
--     select 
--         sales_order_number,
--         member_id, 
--         item_sku_code, 
--         sap_time,
--         row_number() over(partition by member_id, item_sku_code, cast(sap_time as date) order by sap_time) rownum   
--     from 
--         crm_order 
--     where 
--         coupon_offer_id is null 
-- ) t
-- on a.account_id = t.member_id
-- and a.sku_code = t.item_sku_code
-- and CAST(a.used_time as date) = cast(t.sap_time as date)
-- and a.status = '2'
-- and a.rownum = t.rownum
-- ;
GO
