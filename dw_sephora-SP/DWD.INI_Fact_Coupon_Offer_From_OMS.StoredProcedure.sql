/****** Object:  StoredProcedure [DWD].[INI_Fact_Coupon_Offer_From_OMS]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[INI_Fact_Coupon_Offer_From_OMS] AS
BEGIN
delete from DWD.Fact_Coupon_Offer where source = 'OMS';
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
;
END
GO
