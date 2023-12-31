/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_PS_Phase2_Order_Delivery_Analysis_20221028]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_PS_Phase2_Order_Delivery_Analysis_20221028] @start_date [varchar](10) AS
begin
truncate table DW_OMS.RPT_PS_Phase2_Order_Delivery_Analysis;
with basic as (
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
    from [DW_OMS].[DWS_PS_Phase2_Order]
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
    from [DW_OMS].[DWS_PS_Phase2_Order] s
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
        from dw_oms.dws_online_return_apply_order 
        group by sales_order_number
    )n on s.sales_order_number = n.sales_order_number
),
ship as
(
    select 
       store,payment_date,[1] as fulfill1,[2] as fulfill2,[3] as fulfill3,[4] as fulfill4,[5] as fulfill5,[6] as fulfill6,[7] as fulfill7,[8] as fulfill8,[9] as fulfill9,[10] as fulfill10,[11] as fulfill11,[12] as fulfill12,[13] as fulfill13,[14] as fulfill14,[15] as fulfill15,[16] as fulfill16,[17] as fulfill17,[18] as fulfill18,[19] as fulfill19,[20] as fulfill20,[21] as fulfill21,[22] as fulfill22,[23] as fulfill23,[24] as fulfill24,[25] as fulfill25,[26] as fulfill26,[27] as fulfill27,[28] as fulfill28,[29] as fulfill29,[30] as fulfill30,[31] as fulfill31,[32] as fulfill32,[33] as fulfill33,[34] as fulfill34,[35] as fulfill35,[36] as fulfill36,'amount' as type
    from
    (
        select 
            a.store as store, a.payment_date as payment_date, b.id, 
            sum(case when a.status = 'DELIVERY' and shipping_date = b.dt then a.payed_amount else 0 end) as shipped
        from basic a
        join 
        (
            select
                dt,
                row_number() over(order by dt) id
            from DW_Common.DIM_Date
            where dt between @start_date and dateadd(dd, 35, @start_date)
        ) b on a.payment_date <= b.dt
        group by a.payment_date, b.id, a.store
    ) t
    PIVOT
    (
        max(shipped) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36])
    ) pvt
    union all
    select 
        store,payment_date,[1] as fulfill1,[2] as fulfill2,[3] as fulfill3,[4] as fulfill4,[5] as fulfill5,[6] as fulfill6,[7] as fulfill7,[8] as fulfill8,[9] as fulfill9,[10] as fulfill10,[11] as fulfill11,[12] as fulfill12,[13] as fulfill13,[14] as fulfill14,[15] as fulfill15,[16] as fulfill16,[17] as fulfill17,[18] as fulfill18,[19] as fulfill19,[20] as fulfill20,[21] as fulfill21,[22] as fulfill22,[23] as fulfill23,[24] as fulfill24,[25] as fulfill25,[26] as fulfill26,[27] as fulfill27,[28] as fulfill28,[29] as fulfill29,[30] as fulfill30,[31] as fulfill31,[32] as fulfill32,[33] as fulfill33,[34] as fulfill34,[35] as fulfill35,[36] as fulfill36,'qty' as type 
    from (
        select
            a.store as store, a.payment_date as payment_date, b.id, 
            sum(case when a.status = 'DELIVERY' and shipping_date = b.dt then 1 else 0 end) as shipped
        from basic a
        join (
            select
                dt,
                row_number() over(order by dt) id
            from DW_Common.DIM_Date
            where dt between @start_date and dateadd(dd, 35, @start_date)
        ) b on a.payment_date <= b.dt
        group by a.payment_date, b.id, a.store
    ) t
    PIVOT
    (
        max(shipped) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36])
    ) pvt
),
original as(
    select
        a.payment_date as payment_date,
        a.store as store,
        sum(case when a.status in ('DELIVERY','CANCEL','WAITING') then a.payed_amount else 0 end) as original,
        sum(case when a.status = 'DELIVERY' then a.payed_amount else 0 end) as shipped,
        sum(case when a.status = 'CANCEL' then a.payed_amount else 0 end) as cancelled,
        sum(case when a.status = 'WAITING' then a.payed_amount else 0 end) as pending,
        sum(case when a.status = 'RETURN' then a.payed_amount else 0 end) as returned,
        'amount' as type
    from basic a
    group by a.store,a.payment_date
    union all
    select
        a.payment_date as payment_date,
        a.store as store,
        sum(case when a.status in ('DELIVERY','CANCEL','WAITING') then 1 else 0 end) as original,
        sum(case when a.status = 'DELIVERY' then 1 else 0 end) as shipped,
        sum(case when a.status = 'CANCEL' then 1 else 0 end) as cancelled,
        sum(case when a.status = 'WAITING' then 1 else 0 end) as pending,
        sum(case when a.status = 'RETURN' then 1 else 0 end) as returned,
        'qty'  as type
    from basic a
    group by a.store,a.payment_date
),
delivery_detail as(
    select
        cast(a.payment_date as varchar(10)) as payment_date,a.store,a.type,a.original,a.shipped,
        a.cancelled,a.pending,a.returned,b.fulfill1,b.fulfill2,b.fulfill3,b.fulfill4,b.fulfill5,b.fulfill6,b.fulfill7,b.fulfill8,b.fulfill9,b.fulfill10,b.fulfill11,b.fulfill12,b.fulfill13,b.fulfill14,b.fulfill15,b.fulfill16,b.fulfill17,b.fulfill18,b.fulfill19,b.fulfill20,b.fulfill21,b.fulfill22,b.fulfill23,b.fulfill24,b.fulfill25,
        b.fulfill26,b.fulfill27,b.fulfill28,b.fulfill29,b.fulfill30,b.fulfill31,b.fulfill32,b.fulfill33,b.fulfill34,b.fulfill35,b.fulfill36
    from original a 
    left join ship b on a.payment_date=b.payment_date and a.store=b.store and a.type=b.type
)

insert into DW_OMS.RPT_PS_Phase2_Order_Delivery_Analysis
select
    payment_date,
    store,
    type,
    original,
    shipped,
    cancelled,
    pending,
    returned,
    fulfill1,
    fulfill2,
    fulfill3,
    fulfill4,
    fulfill5,
    fulfill6,
    fulfill7,
    fulfill8,
    fulfill9,
    fulfill10,
    fulfill11,
    fulfill12,
    fulfill13,
    fulfill14,
    fulfill15,
    fulfill16,
    fulfill17,
    fulfill18,
    fulfill19,
    fulfill20,
    fulfill21,
    fulfill22,
    fulfill23,
    fulfill24,
    fulfill25,
    fulfill26,
    fulfill27,
    fulfill28,
    fulfill29,
    fulfill30,
    fulfill31,
    fulfill32,
    fulfill33,
    fulfill34,
    fulfill35,
    fulfill36,
    rate,
    insert_timestamp
from (
    select *,
        concat(substring(cast(round(shipped*100.0/original,2) as varchar(512)),1,5),'%') as rate,
        current_timestamp as insert_timestamp
    from delivery_detail
    union all
    select 
        N'total' as payment_date,
        store,
        type,
        sum(original) as original,
        sum(shipped) as shipped,
        sum(cancelled) as cancelled,
        sum(pending) as pending,
        sum(returned) as returned,
        sum(fulfill1) as fulfill1,
        sum(fulfill2) as fulfill2,
        sum(fulfill3) as fulfill3,
        sum(fulfill4) as fulfill4,
        sum(fulfill5) as fulfill5,
        sum(fulfill6) as fulfill6,
        sum(fulfill7) as fulfill7,
        sum(fulfill8) as fulfill8,
        sum(fulfill9) as fulfill9,
        sum(fulfill10) as fulfill10,
        sum(fulfill11) as fulfill11,
        sum(fulfill12) as fulfill12,
        sum(fulfill13) as fulfill13,
        sum(fulfill14) as fulfill14,
        sum(fulfill15) as fulfill15,
        sum(fulfill16) as fulfill16,
        sum(fulfill17) as fulfill17,
        sum(fulfill18) as fulfill18,
        sum(fulfill19) as fulfill19,
        sum(fulfill20) as fulfill20,
        sum(fulfill21) as fulfill21,
        sum(fulfill22) as fulfill22,
        sum(fulfill23) as fulfill23,
        sum(fulfill24) as fulfill24,
        sum(fulfill25) as fulfill25,
        sum(fulfill26) as fulfill26,
        sum(fulfill27) as fulfill27,
        sum(fulfill28) as fulfill28,
        sum(fulfill29) as fulfill29,
        sum(fulfill30) as fulfill30,
        sum(fulfill31) as fulfill31,
        sum(fulfill32) as fulfill32,
        sum(fulfill33) as fulfill33,
        sum(fulfill34) as fulfill34,
        sum(fulfill35) as fulfill35,
        sum(fulfill3) as fulfill36,
        concat(substring(cast(round(sum(shipped)*100.0/sum(original),2) as varchar(512)),1,5),'%') as rate,
        current_timestamp as insert_timestamp
    from delivery_detail
    group by store,type
)t;
end
GO
