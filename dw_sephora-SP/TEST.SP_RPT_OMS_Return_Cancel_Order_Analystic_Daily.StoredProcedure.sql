/****** Object:  StoredProcedure [TEST].[SP_RPT_OMS_Return_Cancel_Order_Analystic_Daily]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_OMS_Return_Cancel_Order_Analystic_Daily] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-03-29       wangzhichun        Initial Version
-- 2022-11-10       houshuangqiang     update JD003 cancel_amount logic
-- ========================================================================================
delete from [RPT].[RPT_OMS_Return_Cancel_Order_Analystic_Daily_test] where [date] = @dt;
insert into [RPT].[RPT_OMS_Return_Cancel_Order_Analystic_Daily_test]
select
    cast(@dt as date) as [date],
    case when si.store_id='TMALL004' then N'TMALL_Chaling'
        when si.store_id='TMALL005' then N'TMALL_PTR'
        when si.store_id='TMALL006' then N'TMALL_WEI'
        when si.store_id in ('JD001','JD002') then 'JD FSS'
        when si.store_id='JD003' then N'JD FCS'
        when si.channel_id='TMALL' then N'TMALL'
        when si.channel_id='SOA' then N'官网'
        when si.channel_id='DOUYIN' then N'DOUYIN001'
        else si.channel_id end as channel,
    sum(b.return_amount) as return_amount,
    sum(a.product_amount) as oms_sales_amount,
    --sum(cancel_amount) as cancel_amount,
    sum(case when b.cancel_amount is null and c.cancel_amount is null then null
             else coalesce(b.cancel_amount, 0) + coalesce(c.cancel_amount, 0)
        end) as cancel_amount, 
    current_timestamp as insert_timestamp
from 
    STG_OMS.OMS_Store_Info si
left join 
(
    select 
        store_cd,
        sum(product_amount) as product_amount
    from dw_oms.RPT_Sales_Order_Basic_Level 
    where is_placed_flag = 1
    and basic_status_cd <> 'DELETED'
    and type_cd<>2
    and format(place_time,'yyyy-MM-dd')=@dt
    group by store_cd
) a
on a.store_cd = si.store_id
left join
(
    select 
        store_id as store_id,
        sum(case when refund_type in ('ONLINE_RETURN_REFUND','RETURN_REFUND') 
            or product_out_status in ('CANT_CONTACTED','REJECTED','INTERCEPT')
            or refund_reason in ('REJECTED','CANT_CONTACT')
            then refund_sum end) as return_amount,
        sum(case when refund_type in ('ONLINE_PARTIAL_CANCEL','FULL_ITEM_REFUND','PARTIAL_ITEM_REFUND','FULL_ITEM_DEPOSIT_REFUND')
            and product_out_status not in ('CANT_CONTACTED','REJECTED','INTERCEPT')
            and (refund_reason not in ('CANT_CONTACTED','REJECTED','CANT_CONTACT') or refund_reason is null)
            then refund_sum end) as cancel_amount 
    from stg_oms.oms_order_refund
    where refund_status='REFUNDED'
    and FORMAT(refund_time,'yyyy-MM-dd')=@dt
    group by store_id
) b
on b.store_id = si.store_id
left join 
(
    select 
        store_cd,
        sum(product_amount) as cancel_amount
    from dw_oms.RPT_Sales_Order_Basic_Level 
    where is_placed_flag = 1
    and store_cd = 'JD003'
    and basic_status_cd <> 'DELETED'
    and internal_status_cd = 'CANCELLED'
    and type_cd <> 2
    and format(update_time,'yyyy-MM-dd') = @dt
    group by store_cd
) c
on c.store_cd = si.store_id
where si.store_id not in ('REDBOOK001','GWP001')
group by
    case when si.store_id='TMALL004' then N'TMALL_Chaling'
        when si.store_id='TMALL005' then N'TMALL_PTR'
        when si.store_id='TMALL006' then N'TMALL_WEI'
        when si.store_id in ('JD001','JD002') then 'JD FSS'
        when si.store_id='JD003' then N'JD FCS'
        when si.channel_id='TMALL' then N'TMALL'
        -- when si.channel_id='JD' then N'京东'
        when si.channel_id='SOA' then N'官网'
        when si.channel_id='DOUYIN' then N'DOUYIN001'
        else si.channel_id end;
END 
GO
