/****** Object:  StoredProcedure [TEMP].[SP_RPT_Paid_Sampling_Card_Bak20230224]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Paid_Sampling_Card_Bak20230224] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-19       Eric               Change tablename
-- ========================================================================================
truncate table DW_Activity.RPT_Paid_Sampling_Card;
with paid_sampling as 
(
    select 
        ge.id as campaign_id,
        ge.start_time,
        ge.end_time,
        coalesce(r.sku_code,ges.sku_code) as sku_code,
        try_cast(r.user_id as bigint) as user_id,
        r.promotion_id,
        up.card_no
    from 
        (select * from [STG_Activity].[Gift_Event_Receiver]) r 
    inner join 
        (select * from [STG_Activity].[Gift_Event] where event_type=0) ge  --sampling
    on ge.id =r.gift_event_id
    left join 
        [STG_Activity].[Gift_Event_SKU] ges
    on ge.id = ges.gift_event_id
    inner join [STG_User].[User_Profile] up  
    on up.user_id =r. user_id 
),
has_redeemed_sku as
(
    select distinct
        a.campaign_id,
        a.user_id,
        a.card_no
    from 
    (
        select * from paid_sampling where promotion_id is null and sku_code is not null and user_id is not null
    )a
    left join
    (
        select 
            try_cast(member_id as bigint) as member_id,
            item_sku_cd,
            order_time 
        from 
            [DW_OMS].[DWS_Sales_Order] 
        where store_cd = 'S001' and internal_status<>'CANCELLED'
    ) b
    on a.user_id = b.member_id
    and a.sku_code = b.item_sku_cd
    where b.order_time >= a.start_time
    and b.order_time <= a.end_time
),
has_redeemed_promotion as 
(
    select distinct
        a.campaign_id,
        a.user_id,
        a.card_no
    from 
    (
        select * from paid_sampling where promotion_id is not null and sku_code is null and user_id is not null
    )a
    left join 
    (
        select 
            try_cast(b.member_id as bigint) as member_id,
            b.order_time,
            c.promotion_code
        from 
        (
            select * from [STG_OMS].[Sales_Order] where store_id = 'S001' and order_internal_status<>'CANCELLED'
        ) b
        left join
            [STG_OMS].[Sales_Order_Promo] c 
        on b.sales_order_sys_id = c.sales_order_sys_id
    ) t
    on a.promotion_id = t.promotion_code
    and a.user_id = t.member_id
    where t.order_time >= a.start_time
    and t.order_time <= a.end_time
)

insert into DW_Activity.RPT_Paid_Sampling_Card
select
    a.campaign_id,
    a.card_no as card_no,
    case 
        when b.user_id is not null then 1
        when c.user_id is not null then 1
        else 0
    end as has_redeemed,
    current_timestamp as insert_timestamp
from 
    paid_sampling a
left join
    has_redeemed_sku b
on a.user_id = b.user_id
and a.campaign_id = b.campaign_id
left join 
    has_redeemed_promotion c
on a.user_id = c.user_id
and a.campaign_id = b.campaign_id
;
end

GO
