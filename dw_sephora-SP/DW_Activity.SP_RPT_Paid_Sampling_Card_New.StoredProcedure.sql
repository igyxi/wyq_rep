/****** Object:  StoredProcedure [DW_Activity].[SP_RPT_Paid_Sampling_Card_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Activity].[SP_RPT_Paid_Sampling_Card_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-19       Eric               Change tablename
-- 2023-02-24       Tali               change to DWD
-- 2023-02-28       houshuangqiang     Change source_table
-- ========================================================================================
truncate table DW_Activity.RPT_Paid_Sampling_Card_New;
with paid_sampling as
(
    select
        ge.id as campaign_id,
        ge.start_time,
        ge.end_time,
        coalesce(r.sku_code, ges.sku_code) as sku_code,
        try_cast(r.user_id as bigint) as user_id,
        r.promotion_id,
        up.member_card
    from
        (select * from [ODS_Activity].[Gift_Event_Receiver]) r
    inner join
        (select * from [ODS_Activity].[Gift_Event] where event_type = 0) ge  --sampling
    on ge.id =r.gift_event_id
    left join
        (select * from [ODS_Activity].[Gift_Event_SKU]) ges
    on ge.id = ges.gift_event_id
    inner join [DWD].DIM_Member_Info up
    on up.eb_user_id = r. user_id
),
has_redeemed_sku as
(
    select distinct
        a.campaign_id,
        a.user_id,
        a.member_card
    from
    (
        select * from paid_sampling where promotion_id is null and sku_code is not null and user_id is not null
    )a
    left join
    (
        select
            member_card,
            item_sku_code,
            order_time
        from
            [DWD].[Fact_OMS_Sales_Order_New]
        where channel_code = 'SOA'
        and coalesce(po_order_status,so_order_status) NOT IN (N'取消','TRADE_CLOSED','TRADE_CANCELED')
    ) b
    on a.member_card = b.member_card
    and a.sku_code = b.item_sku_code
    where b.order_time >= a.start_time
    and b.order_time <= a.end_time
),
has_redeemed_promotion as
(
    select distinct
        a.campaign_id,
        a.user_id,
        a.member_card
    from
    (
        select * from paid_sampling where promotion_id is not null and sku_code is null and user_id is not null
    )a
    left join
    (
        select distinct
            member_card,
            place_time,
            promotion_id
        from
            DWD.Fact_Promotion_Order
        where
            channel_code = 'SOA'
    ) t
    on a.promotion_id = t.promotion_id
    and a.member_card = t.member_card
    where t.place_time >= a.start_time
    and t.place_time <= a.end_time
)

insert into DW_Activity.RPT_Paid_Sampling_Card_New
select
    a.campaign_id,
    a.member_card,
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
