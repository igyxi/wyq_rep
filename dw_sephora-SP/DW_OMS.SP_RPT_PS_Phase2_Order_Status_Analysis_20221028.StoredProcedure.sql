/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_PS_Phase2_Order_Status_Analysis_20221028]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_PS_Phase2_Order_Status_Analysis_20221028] AS
BEGIN
truncate table [DW_OMS].[RPT_PS_Phase2_Order_Status_Analysis];
with basic as 
(
    select 
        store,
        sales_order_number,
        purchase_order_number,
        payment_time,
        payment_date,
        payed_amount,
        order_internal_status,
        status,
        shipping_time,
        shipping_date    
    from 
        [DW_OMS].[DWS_PS_Phase2_Order]
    union all 
    select 
        s.store,
        s.sales_order_number,
        s.purchase_order_number,
        s.payment_time,
        s.payment_date,
        s.payed_amount,
        'RETURN' as order_internal_status,
        'RETURN' as status,
        s.shipping_time,
        s.shipping_date
    from
        [DW_OMS].[DWS_PS_Phase2_Order] s
    inner join (
    -- 于2021-12-13修改逻辑
    -- (
    --     select distinct
    --         sales_order_number
    --     from
    --         DW_OMS.DWS_Negative_Order
    --     where
    --         negative_type in (N'线上退货退款',N'退货退款',N'拒收',N'联系不到客户')
    -- ) n
    select 
        sales_order_number,
        min(create_time) as create_time
    from
         dw_oms.dws_online_return_apply_order 
    group by sales_order_number
         )n
    on s.sales_order_number = n.sales_order_number
)

insert into [DW_OMS].[RPT_PS_Phase2_Order_Status_Analysis]
select 
    d.status_comment,
    t.dragon_qty,
    t.dargon_amount, 
    (case when t0.dargon_amount is null or t0.dargon_amount=0 then null else t.dargon_amount/t0.dargon_amount end)  as dragon_rate,
    t.jd_qty,
    t.jd_amount,
    (case when t0.jd_amount is null or t0.jd_amount=0 then null else t.jd_amount/t0.jd_amount end) as jd_rate, 
    t.tmall_qty,
    t.tmall_amount,
    (case when t0.tmall_amount is null or t0.tmall_amount=0 then null else t.tmall_amount/t0.tmall_amount end) as tmall_rate,
    t.tmall_wei_qty,
    t.tmall_wei_amount,
    (case when t0.tmall_wei_amount is null or t0.tmall_wei_amount=0 then null else t.tmall_wei_amount/t0.tmall_wei_amount end) as tmall_wei_rate, 
    t.tmall_chaling_qty,
    t.tmall_chaling_amount,
    (case when t0.tmall_chaling_amount is null or t0.tmall_chaling_amount=0 then null else t.tmall_chaling_amount/t0.tmall_chaling_amount end) as tmall_chaling_rate, 
    t.tmall_ptr_qty,
    t.tmall_ptr_amount,
    (case when t0.tmall_ptr_amount is null or t0.tmall_ptr_amount=0 then null else t.tmall_ptr_amount/t0.tmall_ptr_amount end) as tmall_ptr_rate, 
    t.redbook_qty,
    t.redbook_amount,
    (case when t0.redbook_amount is null or t0.redbook_amount=0 then null else t.redbook_amount/t0.redbook_amount end) as redbook_rate, 
    t.douyin_qty,
    t.douyin_amount,
    (case when t0.douyin_amount is null or t0.douyin_amount=0 then null else t.douyin_amount/t0.douyin_amount end) as douyin_rate, 
    t.qty,
    t.amount,
    (case when t0.amount is null or t0.amount=0 then null else t.amount/t0.amount end) as rate,
    status_type,
    status_level,
    status_order
from
(
select
    order_internal_status,
    status_comment,
    status_type,
    status_level,
    status_order
from 
    DW_OMS.DIM_Order_Internal_Status
) d
left join
(
    select 
        order_internal_status,
        count(case when store='Dragon' then 1 else null end ) as dragon_qty,
        sum(case when store='Dragon' then payed_amount else null end ) as dargon_amount,
        count(case when store='JD' then 1 else null end ) as jd_qty,
        sum(case when store='JD' then payed_amount else null end ) as jd_amount,
        count(case when store='TMALL' then 1 else null end ) as tmall_qty,
        sum(case when store='TMALL' then payed_amount else null end ) as tmall_amount,
        count(case when store='TMALL_WEI' then 1 else null end ) as tmall_wei_qty,
        sum(case when store='TMALL_WEI' then payed_amount else null end ) as tmall_wei_amount,
        count(case when store='TMALL_CHALING' then 1 else null end ) as tmall_chaling_qty,
        sum(case when store='TMALL_CHALING' then payed_amount else null end ) as tmall_chaling_amount,
        count(case when store='TMALL_PTR' then 1 else null end ) as tmall_ptr_qty,
        sum(case when store='TMALL_PTR' then payed_amount else null end ) as tmall_ptr_amount,
        count(case when store='REDBOOK' then 1 else null end ) as redbook_qty,
        sum(case when store='REDBOOK' then payed_amount else null end ) as redbook_amount,
        count(case when store='DOUYIN' then 1 else null end ) as douyin_qty,
        sum(case when store='DOUYIN' then payed_amount else null end ) as douyin_amount,
        count(1) as qty,
		2 AS [level],
        sum(payed_amount ) as amount
    from
        basic
    group by 
        order_internal_status
    union all
    select 
        case when order_internal_status in ('DELIVERY', 'SHIPPED', 'SIGNED', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') then 'SHIPPED'
            when order_internal_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') then 'CANCELLED'
            when order_internal_status in ('WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') then 'PENDING'
            when order_internal_status in ('RETURN') then 'RETURN'
        else 'OTHER'
        end as order_internal_status,  
        count(case when store='Dragon' then 1 else null end ) as dragon_qty,
        sum(case when store='Dragon' then payed_amount else null end ) as dargon_amount,
        count(case when store='JD' then 1 else null end ) as jd_qty,
        sum(case when store='JD' then payed_amount else null end ) as jd_amount,
        count(case when store='TMALL' then 1 else null end ) as tmall_qty,
        sum(case when store='TMALL' then payed_amount else null end ) as tmall_amount,
        count(case when store='TMALL_WEI' then 1 else null end ) as tmall_wei_qty,
        sum(case when store='TMALL_WEI' then payed_amount else null end ) as tmall_wei_amount,
        count(case when store='TMALL_CHALING' then 1 else null end ) as tmall_chaling_qty,
        sum(case when store='TMALL_CHALING' then payed_amount else null end ) as tmall_chaling_amount,
        count(case when store='TMALL_PTR' then 1 else null end ) as tmall_ptr_qty,
        sum(case when store='TMALL_PTR' then payed_amount else null end ) as tmall_ptr_amount,
        count(case when store='REDBOOK' then 1 else null end ) as redbook_qty,
        sum(case when store='REDBOOK' then payed_amount else null end ) as redbook_amount,
        count(case when store='DOUYIN' then 1 else null end ) as douyin_qty,
        sum(case when store='DOUYIN' then payed_amount else null end ) as douyin_amount,
        count(1) as qty,
		1 AS [level],
        sum(payed_amount) as amount
    from
        basic
    group by 
        case when order_internal_status in ('DELIVERY', 'SHIPPED', 'SIGNED', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') then 'SHIPPED'
             when order_internal_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') then 'CANCELLED'
             when order_internal_status in ('WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') then 'PENDING'
             when order_internal_status in ('RETURN') then 'RETURN'
             else 'OTHER'
             end 
) t
 on d.order_internal_status = t.order_internal_status
 and t.level = d.status_level
left join
(
    select 
        sum(case when store='Dragon' then payed_amount else null end ) as dargon_amount,
        sum(case when store='JD' then payed_amount else null end ) as jd_amount,
        sum(case when store='TMALL' then payed_amount else null end ) as tmall_amount,
        sum(case when store='TMALL_WEI' then payed_amount else null end ) as tmall_wei_amount,
        sum(case when store='TMALL_CHALING' then payed_amount else null end ) as tmall_chaling_amount,
        sum(case when store='TMALL_PTR' then payed_amount else null end ) as tmall_ptr_amount,
        sum(case when store='REDBOOK' then payed_amount else null end ) as redbook_amount,
        sum(case when store='DOUYIN' then payed_amount else null end ) as douyin_amount,
        sum(payed_amount ) as amount
        -- sum(case when order_internal_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL','WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') then  0 else payed_amount end ) as real_amount
    from
        [DW_OMS].[DWS_PS_Order]
) t0
on 1 = 1

union all

-- RETRUN
select 
    d.status_comment,
    t.dragon_qty,
    t.dargon_amount, 
    (case when t0.dargon_amount is null or t0.dargon_amount=0 then null else t.dargon_amount/t0.dargon_amount end)  as dragon_rate,
    t.jd_qty,
    t.jd_amount,
    (case when t0.jd_amount is null or t0.jd_amount=0 then null else t.jd_amount/t0.jd_amount end) as jd_rate, 
    t.tmall_qty,
    t.tmall_amount,
    (case when t0.tmall_amount is null or t0.tmall_amount=0 then null else t.tmall_amount/t0.tmall_amount end) as tmall_rate,
    t.tmall_wei_qty,
    t.tmall_wei_amount,
    (case when t0.tmall_wei_amount is null or t0.tmall_wei_amount=0 then null else t.tmall_wei_amount/t0.tmall_wei_amount end) as tmall_wei_rate, 
    t.tmall_chaling_qty,
    t.tmall_chaling_amount,
    (case when t0.tmall_chaling_amount is null or t0.tmall_chaling_amount=0 then null else t.tmall_chaling_amount/t0.tmall_chaling_amount end) as tmall_chaling_rate, 
    t.tmall_ptr_qty,
    t.tmall_ptr_amount,
    (case when t0.tmall_ptr_amount is null or t0.tmall_ptr_amount=0 then null else t.tmall_ptr_amount/t0.tmall_ptr_amount end) as tmall_ptr_rate, 
    t.redbook_qty,
    t.redbook_amount,
    (case when t0.redbook_amount is null or t0.redbook_amount=0 then null else t.redbook_amount/t0.redbook_amount end) as redbook_rate, 
    t.douyin_qty,
    t.douyin_amount,
    (case when t0.douyin_amount is null or t0.douyin_amount=0 then null else t.douyin_amount/t0.douyin_amount end) as douyin_rate, 
    t.qty,
    t.amount,
    (case when t0.amount is null or t0.amount=0 then null else t.amount/t0.amount end) as rate,
    status_type,
    status_level,
    status_order
from
(
select
    order_internal_status,
    status_comment,
    status_type,
    status_level,
    status_order
from 
    DW_OMS.DIM_Order_Internal_Status
where 
    order_internal_status = 'RETURN'
) d
left join
(
    select 
        order_internal_status,
        count(case when store='Dragon' then 1 else null end ) as dragon_qty,
        sum(case when store='Dragon' then payed_amount else null end ) as dargon_amount,
        count(case when store='JD' then 1 else null end ) as jd_qty,
        sum(case when store='JD' then payed_amount else null end ) as jd_amount,
        count(case when store='TMALL' then 1 else null end ) as tmall_qty,
        sum(case when store='TMALL' then payed_amount else null end ) as tmall_amount,
        count(case when store='TMALL_WEI' then 1 else null end ) as tmall_wei_qty,
        sum(case when store='TMALL_WEI' then payed_amount else null end ) as tmall_wei_amount,
        count(case when store='TMALL_CHALING' then 1 else null end ) as tmall_chaling_qty,
        sum(case when store='TMALL_CHALING' then payed_amount else null end ) as tmall_chaling_amount,
        count(case when store='TMALL_PTR' then 1 else null end ) as tmall_ptr_qty,
        sum(case when store='TMALL_PTR' then payed_amount else null end ) as tmall_ptr_amount,
        count(case when store='REDBOOK' then 1 else null end ) as redbook_qty,
        sum(case when store='REDBOOK' then payed_amount else null end ) as redbook_amount,
        count(case when store='DOUYIN' then 1 else null end ) as douyin_qty,
        sum(case when store='DOUYIN' then payed_amount else null end ) as douyin_amount,
        count(1) as qty,
		2 AS [level],
        sum(payed_amount ) as amount
    from
        basic
    where 
        order_internal_status = 'RETURN'
    group by 
        order_internal_status
    union all
    select 
        case when order_internal_status in ('DELIVERY', 'SHIPPED', 'SIGNED', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') then 'SHIPPED'
            when order_internal_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') then 'CANCELLED'
            when order_internal_status in ('WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') then 'PENDING'
            when order_internal_status in ('RETURN') then 'RETURN'
        else 'OTHER'
        end as order_internal_status,
        count(case when store='Dragon' then 1 else null end ) as dragon_qty,
        sum(case when store='Dragon' then payed_amount else null end ) as dargon_amount,
        count(case when store='JD' then 1 else null end ) as jd_qty,
        sum(case when store='JD' then payed_amount else null end ) as jd_amount,
        count(case when store='TMALL' then 1 else null end ) as tmall_qty,
        sum(case when store='TMALL' then payed_amount else null end ) as tmall_amount,
        count(case when store='TMALL_WEI' then 1 else null end ) as tmall_wei_qty,
        sum(case when store='TMALL_WEI' then payed_amount else null end ) as tmall_wei_amount,
        count(case when store='TMALL_CHALING' then 1 else null end ) as tmall_chaling_qty,
        sum(case when store='TMALL_CHALING' then payed_amount else null end ) as tmall_chaling_amount,
        count(case when store='TMALL_PTR' then 1 else null end ) as tmall_ptr_qty,
        sum(case when store='TMALL_PTR' then payed_amount else null end ) as tmall_ptr_amount,
        count(case when store='REDBOOK' then 1 else null end ) as redbook_qty,
        sum(case when store='REDBOOK' then payed_amount else null end ) as redbook_amount,
        count(case when store='DOUYIN' then 1 else null end ) as douyin_qty,
        sum(case when store='DOUYIN' then payed_amount else null end ) as douyin_amount,
        count(1) as qty,
		1 AS [level],
        sum(payed_amount) as amount
    from
        basic
    where 
        order_internal_status = 'RETURN'
    group by 
        case when order_internal_status in ('DELIVERY', 'SHIPPED', 'SIGNED', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') then 'SHIPPED'
             when order_internal_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') then 'CANCELLED'
             when order_internal_status in ('WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') then 'PENDING'
             when order_internal_status in ('RETURN') then 'RETURN'
             else 'OTHER'
             end 
) t
 on d.order_internal_status = t.order_internal_status
 AND t.level = d.status_level
left JOIN
(
    select 
        sum(case when store='Dragon' then payed_amount else null end ) as dargon_amount,
        sum(case when store='JD' then payed_amount else null end ) as jd_amount,
        sum(case when store='TMALL' then payed_amount else null end ) as tmall_amount,
        sum(case when store='TMALL_WEI' then payed_amount else null end ) as tmall_wei_amount,
        sum(case when store='TMALL_CHALING' then payed_amount else null end ) as tmall_chaling_amount,
        sum(case when store='TMALL_PTR' then payed_amount else null end ) as tmall_ptr_amount,
        sum(case when store='REDBOOK' then payed_amount else null end ) as redbook_amount,
        sum(case when store='DOUYIN' then payed_amount else null end ) as douyin_amount,
        sum(payed_amount ) as amount
        -- sum(case when order_internal_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL','WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') then  0 else payed_amount end ) as real_amount
    from
        [DW_OMS].[DWS_PS_Order]
    where
    order_internal_status not in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL','WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') 
) t0
on 1 = 1
;
    end
GO
