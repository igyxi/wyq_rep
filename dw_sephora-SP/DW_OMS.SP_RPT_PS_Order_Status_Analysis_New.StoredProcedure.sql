/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_PS_Order_Status_Analysis_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_PS_Order_Status_Analysis_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2023-03-20       tali           new Version
-- 2023-03-27       litao          增加cancel只取退款成功逻辑
-- 2023-05-25       wangzhichun    refund_status='REFUNDED' change refund_status='1' & update order_status
-- ========================================================================================

truncate table [DW_OMS].[RPT_PS_Order_Status_Analysis_New];

with sales_order as (
    select 
        *
    from 
    (
        select
            a.*,
            format(place_time, 'yyyy-MM-dd') as payment_date,
            format(shipping_time, 'yyyy-MM-dd') as shipping_date,
            CASE
                WHEN channel_code = 'SOA' THEN 'Dragon'
                WHEN sub_channel_code IN ('TMALL001','TMALL002') THEN 'TMALL_Sephora'
                WHEN sub_channel_code = 'TMALL004' THEN 'TMALL_CHALING'
                WHEN sub_channel_code = 'TMALL005' THEN 'TMALL_PTR'
                WHEN sub_channel_code = 'TMALL006' THEN 'TMALL_WEI'
                WHEN sub_channel_code IN ('JD001','JD002') THEN 'JD_FSS'
                WHEN sub_channel_code = 'JD003' THEN 'JD_FCS'
                WHEN channel_code = 'DOUYIN' THEN 'DOUYIN'
            END as store,
            case when coalesce(a.po_order_status,a.so_order_status) in (N'取消','TRADE_CANCELED','TRADE_CLOSED') and b.sales_order_number is not null then 1 
                 when coalesce(a.po_order_status,a.so_order_status) in (N'取消','TRADE_CANCELED','TRADE_CLOSED') and b.sales_order_number is null then 0 
                 else 1 
            end as cancel_is_refunded
        from [DWD].[Fact_OMS_Sales_Order_New] a 
        left join 
        (
             select 
                distinct sales_order_number
             from
                [DWD].[Fact_OMS_Refund_Order]
             where
                source = 'New OMS'
              and refund_status =1         -- new oms修改 20230525 
              and refund_source = 'CANCELLED' --增加cancel只取退款成功逻辑
        ) b 
        on a.sales_order_number=b.sales_order_number
        where a.is_placed = 1 
        and a.source = 'New OMS'
        and a.item_sku_code <> 'TRP001'
    ) t
    join
        DATA_OPS.DIM_PrivateSales_Config b
    on case when t.store in ('JD_FSS', 'JD_FCS') then 'JD' else t.store end = b.Channel
    and b.[Status] = 1
    where 
        t.cancel_is_refunded=1
        and format(t.place_time, 'yyyy-MM-dd HH') between FORMAT(StartDate,'yyyy-MM-dd')+' '+LTRIM(StartHour) and FORMAT(EndDate,'yyyy-MM-dd')+' '+LTRIM(EndHour)
), 
refund_order as (
    select * from
    (
        select 
            refund_type,
            refund_source,
            place_time,
            format(place_time, 'yyyy-MM-dd') as payment_date,
            refund_time,
            format(refund_time, 'yyyy-MM-dd') refund_date,
            sales_order_number,
            item_apportion_amount,
            CASE
                WHEN channel_code = 'SOA' THEN 'Dragon'
                WHEN sub_channel_code IN ('TMALL001','TMALL002') THEN 'TMALL_Sephora'
                WHEN sub_channel_code = 'TMALL004' THEN 'TMALL_CHALING'
                WHEN sub_channel_code = 'TMALL005' THEN 'TMALL_PTR'
                WHEN sub_channel_code = 'TMALL006' THEN 'TMALL_WEI'
                WHEN sub_channel_code IN ('JD001','JD002') THEN 'JD_FSS'
                WHEN sub_channel_code = 'JD003' THEN 'JD_FCS'
                WHEN channel_code = 'DOUYIN' THEN 'DOUYIN'
            END as store 
        from 
           [DWD].[Fact_OMS_Refund_Order]
        where 
            source = 'NEW OMS'
        and refund_status =1
    ) t
    join
        DATA_OPS.DIM_PrivateSales_Config b
    on case when t.store in ('JD_FSS', 'JD_FCS') then 'JD' else t.store end = b.Channel
    and b.[Status] = 1
    where 
        format(t.place_time, 'yyyy-MM-dd HH') between FORMAT(StartDate,'yyyy-MM-dd')+' '+LTRIM(StartHour) and FORMAT(EndDate,'yyyy-MM-dd')+' '+LTRIM(EndHour)
)


insert into [DW_OMS].[RPT_PS_Order_Status_Analysis_New]
select 
    a.po_order_status,
    a.so_order_status,
    dragon_qty,
    dragon_amount,
    jd_fcs_qty,
    jd_fcs_amount,
    jd_fss_qty,
    jd_fss_amount,
    tmall_qty,
    tmall_amount,
    tmall_wei_qty,
    tmall_wei_amount,
    tmall_chaling_qty,
    tmall_chaling_amount,
    tmall_ptr_qty,
    tmall_ptr_amount,
    douyin_qty,
    douyin_amount,
    CURRENT_TIMESTAMP as insert_timestmap
from
(
    select 
        po_order_status,
        so_order_status,
        Dragon as Dragon_amount,
        TMALL_Sephora as TMALL_amount,
        TMALL_CHALING as TMALL_CHALING_amount,
        TMALL_PTR as TMALL_PTR_amount,
        TMALL_WEI as TMALL_WEI_amount,
        JD_FSS as JD_FSS_amount,
        JD_FCS as JD_FCS_amount,
        DOUYIN as DOUYIN_amount
    from
    (
        select 
            po_order_status,
            so_order_status,
            store,
            sum(item_apportion_amount) as amount
        from
            sales_order
        group by
            po_order_status,
            so_order_status,
            store
    ) t
    pivot
    (
        sum(amount)
        for store in ([Dragon], [TMALL_Sephora], [TMALL_CHALING], [TMALL_PTR], [TMALL_WEI], [JD_FSS], [JD_FCS], [DOUYIN])
    ) pvt
    union all
    select 
        refund_source as po_order_status,
        refund_source as so_order_status,
        Dragon as Dragon_amount,
        TMALL_Sephora as TMALL_amount,
        TMALL_CHALING as TMALL_CHALING_amount,
        TMALL_PTR as TMALL_PTR_amount,
        TMALL_WEI as TMALL_WEI_amount,
        JD_FSS as JD_FSS_amount,
        JD_FCS as JD_FCS_amount,
        DOUYIN as DOUYIN_amount
    from
    (
        select 
            refund_source,
            store,
            sum(item_apportion_amount) as amount
        from
            refund_order
        where
            refund_source <> 'CANCELLED'
        group by
            refund_source,
            store
    ) t
    pivot
    (
        sum(amount)
        for store in ([Dragon], [TMALL_Sephora], [TMALL_CHALING], [TMALL_PTR], [TMALL_WEI], [JD_FSS], [JD_FCS], [DOUYIN])
    ) pvt
) a
left join
(
    select 
        po_order_status,
        so_order_status,
        Dragon as Dragon_qty,
        TMALL_Sephora as TMALL_qty,
        TMALL_CHALING as TMALL_CHALING_qty,
        TMALL_PTR as TMALL_PTR_qty,
        TMALL_WEI as TMALL_WEI_qty,
        JD_FSS as JD_FSS_qty,
        JD_FCS as JD_FCS_qty,
        DOUYIN as DOUYIN_qty
    from
    (
        select 
            po_order_status,
            so_order_status,
            store,
            count(distinct sales_order_number) as qty
        from
            sales_order
        group by
            po_order_status,
            so_order_status,
            store
    ) t
    pivot
    (
        sum(qty)
        for store in ([Dragon], [TMALL_Sephora], [TMALL_CHALING], [TMALL_PTR], [TMALL_WEI], [JD_FSS], [JD_FCS], [DOUYIN])
    ) pvt
    union all
    select
        refund_source as po_order_status,
        refund_source as so_order_status,
        Dragon as Dragon_qty,
        TMALL_Sephora as TMALL_qty,
        TMALL_CHALING as TMALL_CHALING_qty,
        TMALL_PTR as TMALL_PTR_qty,
        TMALL_WEI as TMALL_WEI_qty,
        JD_FSS as JD_FSS_qty,
        JD_FCS as JD_FCS_qty,
        DOUYIN as DOUYIN_qty
    from
    (
        select 
            refund_source,
            store,
            count(distinct sales_order_number) as qty
        from
            refund_order
        where
            refund_source <> 'CANCELLED'
        group by
            refund_source,
            store
    ) t
    pivot
    (
        sum(qty)
        for store in ([Dragon], [TMALL_Sephora], [TMALL_CHALING], [TMALL_PTR], [TMALL_WEI], [JD_FSS], [JD_FCS], [DOUYIN])
    ) pvt
) q
on a.po_order_status = q.po_order_status
and a.so_order_status=q.so_order_status
END
GO
