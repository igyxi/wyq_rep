/****** Object:  StoredProcedure [TEMP].[SP_Fact_Coupon_Offer_Bak20230404]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Coupon_Offer_Bak20230404] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       Mac            Initial Version
-- 2022-01-06       Tali           add sales_order_number for pos coupon 
-- 2022-01-27       Tali           delete collate
-- 2022-02-23       Tali           set member_card from dim_member_info
-- 2022-03-08       Tali           change the delete logic
-- 2022-04-27       Tali           add oms coupon
-- 2022-05-25       Tali           fix oms user_id with more member_card
-- 2023-03-29       Tali           change ods_crm.dimstore to dw_crm.dim_Store
-- ========================================================================================

DECLARE @ts bigint = null;
select 
    -- get max timestamp of the day before 
    @ts = max_timestamp 
from 
(
    select  *, row_number() over(order by last_update_time desc) rownum
    from [Management].[Table_Last_Update_Logging] 
    where CONCAT([schema],'.',[table]) = 'ODS_CRM.ACCOUNT_OFFER' 
    and last_update_time between @dt and DATEADD(day, 1, @dt)
) t
where rownum = 1;

delete from DWD.Fact_Coupon_Offer where coupon_offer_id in (
    select account_offer_id from ODS_CRM.account_offer where [timestamp] > @ts
) and source = 'CRM';

with accout_offer as
(
    select
        ao.account_offer_id,
        ao.account_id,
        o.offer_id,
        o.offer_name,
        ot.offer_type_code,
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
        ao.[timestamp] > @ts
),
crm_order as (
    select 
        coalesce(d.sales_order_number, c.invc_no) as sales_order_number,
        c.member_id, 
        c.item_sku_code, 
        c.order_time,
        c.sap_time,
        c.coupon_offer_id
    from
        DW_CRM.DWS_Trans_Order_With_SKU c
    join
        ODS_CRM.offer f
    on c.item_sku_code = f.sku
    left join
        STG_OMS.Purchase_Order d
    on c.invc_no = d.purchase_order_number
    and c.channel_code <> 'OFF_LINE'
    where
        c.item_quantity > 0
    and c.order_time > DATEADD(day, -10, @dt)
    and c.order_time < DATEADD(day, 1, @dt)
)


insert into [DWD].[Fact_Coupon_Offer]
select
    a.account_offer_id as coupon_offer_id,
    a.sku_code as coupon_code,
    a.offer_type_code as coupon_type,
    a.offer_type_name as coupon_type_name,
    m.member_card,
    a.[status] as coupon_status,
    a.qty as quantity,
    a.effective_from_date as start_date,
    a.effective_to_date as end_date,
    a.used_time,
    a.expired_time,
    -- a.expired_time as expired_time,
    a.offer_id as offer_id,
    a.offer_name  as offer_name,
    a.offer_type as offer_type,
    a.offer_type_name,
    p.promotion_id,
    c.sales_order_number, 
    s.store_code,
    -- a.Offer_CardType as offer_card_type,
    -- t.sales_order_number as sales_order_number,
    a.create_time as create_time,
    a.update_time as update_time,
    'CRM'  as source,
    current_timestamp as insert_timestamp
from 
(
    select 
        *,
        row_number() over(partition by account_id, sku_code, [status] order by  used_time, effective_to_date) rownum 
    from 
        accout_offer
) a
left join 
    DW_CRM.DIM_Store s
on a.store_id = s.store_id
left join
    STG_Promotion.CRM_EB_REL p
on a.sku_code = p.crm_promotion_code
left join
    DWD.DIM_Member_Info m
on  a.account_id = m.member_id
left join 
(
    select 
        sales_order_number, 
        coupon_offer_id, 
        row_number() over(partition by coupon_offer_id order by sap_time desc) rownum
    from 
        crm_order 
    where 
        coupon_offer_id is not null 
) c
on a.account_offer_id = c.coupon_offer_id
and c.rownum = 1
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
;


delete from DWD.Fact_Coupon_Offer where source = 'OMS' and coupon_offer_id in (
    select px_coupon_id from [STG_Promotion].[PX_Coupon] where (create_time > @dt or update_time > @dt) and origin = 'eb'
);
insert into [DWD].[Fact_Coupon_Offer]
select
    a.px_coupon_id as coupon_offer_id,
    null as coupon_code,
    a.type as coupon_type,
    case when a.type = 2 then N'折扣' 
         when a.type = 1 then N'现金券'
         when a.type = 3 then N'礼品'
         when a.type = 4 then N'运费券'
    end as coupon_type_name,
    m.member_card,
    case  
        when a.status=1 then 2  
        when a.status=2 then 1 
    else a.status end as coupon_status,
    1 as quantity,
    a.effective as start_time,
    a.expire as end_time,
    a.use_time as used_time,
    null as expired_time,
    null as offer_id,
    null as offer_name,
    null as offer_type,
    null as offer_type_name,
    a.promotion_id,
    a.order_id as sales_order_number,
    null as store_code,
    a.create_time,
    a.update_time,
    'OMS' as source,
    current_timestamp as insert_timestamp
from 
    [STG_Promotion].[PX_Coupon] a
left join
(
    select 
        eb_user_id, 
        member_card, 
        row_number() over(partition by eb_user_id order by single_pink_card_validate_type desc, register_date desc) row_num
    from 
        DWD.DIM_Member_Info  
    where 
        account_status = 1
)m
on a.user_id = m.eb_user_id
and m.row_num = 1
where 
    a.origin = 'eb'
and (a.create_time > @dt or a.update_time > @dt)
;

END

GO
