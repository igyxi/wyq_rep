/****** Object:  StoredProcedure [TEST].[SP_RPT_PS_Order_Delivery_Analysis_test_20230615]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_PS_Order_Delivery_Analysis_test_20230615] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2023-03-20       tali           new Version
-- 2023-06-14                      测试
-- ========================================================================================
-- DECLARE @start_date DATE

-- SELECT
--     @start_date=MIN(DATEADD(D,-1,StartDate))
-- FROM DATA_OPS.DIM_PrivateSales_Config
-- WHERE [Status]=1

with sales_order as (
	select
		case when store = 'TMALL_Sephora' then 'TMALL' else store end store,
		sales_order_number,
		purchase_order_number,
		payment_date,
		payment_amount,
        item_apportion_amount,
        shipping_date,
		order_status
    from
    (
        select
            sales_order_number,
			purchase_order_number,
			payment_amount,
			item_apportion_amount,
			order_status,
--			payment_time,-- 有空值，这里取place_time
			place_time,
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
            END as store
        from  [temp].[Fact_OMS_Sales_Order_Bak_20230613_Test]
        where is_placed = 1
        and source = 'OMS'
    ) t
    -- join
    --     DATA_OPS.DIM_PrivateSales_Config b
    -- on case when t.store in ('JD_FSS', 'JD_FCS') then 'JD' else t.store end = b.Channel
    -- and b.[Status] = 1
    -- where
    --     format(t.place_time, 'yyyy-MM-dd HH') between FORMAT(StartDate,'yyyy-MM-dd')+' '+LTRIM(StartHour) and FORMAT(EndDate,'yyyy-MM-dd')+' '+LTRIM(EndHour)
),
refund_order as (
	select
		case when store = 'TMALL_Sephora' then 'TMALL' else store end store,
		sales_order_number,
        payment_date,
		item_apportion_amount,
		order_status,
		refund_source
	from
    (
        select
            refund_type,
            case when sub_channel_code IN ('JD001','JD002','JD003') and refund_type='RETURN_REFUND' then 'RETURNED' else refund_source end refund_source ,
			channel_code,
			sub_channel_code,
            place_time,
            format(place_time, 'yyyy-MM-dd') as payment_date,
            refund_time,
            format(refund_time, 'yyyy-MM-dd') refund_date,
            sales_order_number,
            case when order_status in ('INTERCEPT','CANT_CONTACTED') then 'REJECTED' else order_status end as order_status,
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
            [temp].[Fact_OMS_Refund_Order_Test_Bak_20230613]
        where
            source = 'OMS'
        and refund_status = 'REFUNDED'
        -- and format(place_time, 'yyyy-MM-dd') = '2023-03-01'
    ) t
    -- join
    --     DATA_OPS.DIM_PrivateSales_Config b
    -- on case when t.store in ('JD_FSS', 'JD_FCS') then 'JD' else t.store end = b.Channel
    -- and b.[Status] = 1
    -- where
    --     format(t.place_time, 'yyyy-MM-dd HH') between FORMAT(StartDate,'yyyy-MM-dd')+' '+LTRIM(StartHour) and FORMAT(EndDate,'yyyy-MM-dd')+' '+LTRIM(EndHour)
)
-- ,
-- fullfill_amount as (
--     select store, payment_date,
--         [1] fulfil1,
--         [2] fulfil2,
--         [3] fulfil3,
--         [4] fulfil4,
--         [5] fulfil5,
--         [6] fulfil6,
--         [7] fulfil7,
--         [8] fulfil8,
--         [9] fulfil9,
--         [10] fulfil10,
--         [11] fulfil11,
--         [12] fulfil12,
--         [13] fulfil13,
--         [14] fulfil14,
--         [15] fulfil15,
--         [16] fulfil16,
--         [17] fulfil17,
--         [18] fulfil18,
--         [19] fulfil19,
--         [20] fulfil20,
--         [21] fulfil21,
--         [22] fulfil22,
--         [23] fulfil23,
--         [24] fulfil24,
--         [25] fulfil25,
--         [26] fulfil26,
--         [27] fulfil27,
--         [28] fulfil28,
--         [29] fulfil29,
--         [30] fulfil30,
--         [31] fulfil31,
--         [32] fulfil32,
--         [33] fulfil33,
--         [34] fulfil34,
--         [35] fulfil35,
--         [36] fulfil36
--     from
--     (
--         select
--             store,
--             payment_date,
--             DATEDIFF(D,@start_date, shipping_date) + 1 as shipping_days,
--             item_apportion_amount
--         from
--             sales_order t
--         where
--             order_status in ('SHIPPED', 'SIGNED', 'REJECTED', 'INTERCEPT', 'CANT_CONTACTED')
--     ) t
--     PIVOT
--     (
--         sum(item_apportion_amount)
--         for shipping_days in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36])
--     ) pvt
-- ),
-- fullfill_qty as (
--     select store,
--         payment_date,
--         [1] fulfil1,
--         [2] fulfil2,
--         [3] fulfil3,
--         [4] fulfil4,
--         [5] fulfil5,
--         [6] fulfil6,
--         [7] fulfil7,
--         [8] fulfil8,
--         [9] fulfil9,
--         [10] fulfil10,
--         [11] fulfil11,
--         [12] fulfil12,
--         [13] fulfil13,
--         [14] fulfil14,
--         [15] fulfil15,
--         [16] fulfil16,
--         [17] fulfil17,
--         [18] fulfil18,
--         [19] fulfil19,
--         [20] fulfil20,
--         [21] fulfil21,
--         [22] fulfil22,
--         [23] fulfil23,
--         [24] fulfil24,
--         [25] fulfil25,
--         [26] fulfil26,
--         [27] fulfil27,
--         [28] fulfil28,
--         [29] fulfil29,
--         [30] fulfil30,
--         [31] fulfil31,
--         [32] fulfil32,
--         [33] fulfil33,
--         [34] fulfil34,
--         [35] fulfil35,
--         [36] fulfil36
--     from
--     (
--         select distinct
--             store,
--             payment_date,
--             DATEDIFF(D,@start_date, shipping_date) + 1 as shipping_days,
--             sales_order_number
--         from
--             sales_order t
--         where
--             order_status in ('SHIPPED', 'SIGNED', 'REJECTED', 'INTERCEPT', 'CANT_CONTACTED')
--     ) t
--     PIVOT
--     (
--         count(sales_order_number)
--         for shipping_days in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36])
--     ) pvt
-- )

select count(1),
    sum(
        case when coalesce(old.payment_date,'')=coalesce(new.payment_date,'')
        and coalesce(old.store,'')=coalesce(new.store,'')
        and coalesce(old.[type],'')=coalesce(new.[type],'') then 1 else 0 end
    ) as total_number,
    sum(case when coalesce(old.original,0)<>coalesce(new.original,0) then 1 else 0 end) as original,
    sum(case when coalesce(old.shipped,0)<>coalesce(new.shipped,0) then 1 else 0 end) as shipped,
    sum(case when coalesce(old.cancelled,0)<>coalesce(new.cancelled,0) then 1 else 0 end) as cancelled,
    sum(case when coalesce(old.pending,0)<>coalesce(new.pending,0) then 1 else 0 end) as pending,
    sum(case when coalesce(old.returned,0)<>coalesce(new.returned,0) then 1 else 0 end) as returned
from 
    [test].[RPT_PS_Order_Delivery_Analysis_test] old
left join 
    [DW_OMS].[RPT_PS_Order_Delivery_Analysis_New] new 
on coalesce(old.payment_date,'')=coalesce(new.payment_date,'')
and coalesce(old.store,'')=coalesce(new.store,'')
and coalesce(old.[type],'')=coalesce(new.[type],'')

insert into [test].[RPT_PS_Order_Delivery_Analysis_test]
select
    a.payment_date,
    a.store,
    'amount' as type,
    original,
    shipped,
    cancelled,
    pending,
    returned,
    null as fulfil1,
    null as fulfil2,
    null as fulfil3,
    null as fulfil4,
    null as fulfil5,
    null as fulfil6,
    null as fulfil7,
    null as fulfil8,
    null as fulfil9,
    null as fulfil10,
    null as fulfil11,
    null as fulfil12,
    null as fulfil13,
    null as fulfil14,
    null as fulfil15,
    null as fulfil16,
    null as fulfil17,
    null as fulfil18,
    null as fulfil19,
    null as fulfil20,
    null as fulfil21,
    null as fulfil22,
    null as fulfil23,
    null as fulfil24,
    null as fulfil25,
    null as fulfil26,
    null as fulfil27,
    null as fulfil28,
    null as fulfil29,
    null as fulfil30,
    null as fulfil31,
    null as fulfil32,
    null as fulfil33,
    null as fulfil34,
    null as fulfil35,
    null as fulfil36,
    CONCAT(SUBSTRING(CAST(ROUND((ISNULL(shipped,0.0001)*100.0 + 0.0001 )/(ISNULL(original,0.0001) + 0.0001),2) AS VARCHAR(512)),1,5),'%') AS rate,
    current_timestamp as insert_timestamp
from
(
    select
        store,
        payment_date,
        sum(item_apportion_amount) as original,
        sum(case when order_status in ('SHIPPED', 'SIGNED', 'REJECTED', 'INTERCEPT', 'CANT_CONTACTED') then item_apportion_amount end) as shipped,
        sum(case when order_status in ('WAIT_SAPPROCESS', 'EXCEPTION', 'PENDING', 'WAIT_JD_CONFIRM', 'WAIT_JDPROCESS', 'WAIT_SEND_SAP', 'WAIT_TMALLPROCESS', 'WAIT_WAREHOUSE_PROCESS', 'SPLITED', 'WAIT_ROUTE_ORDER') then item_apportion_amount end) as pending
    from
        sales_order t
    group by
        store,
        payment_date
) a
-- left join
--     fullfill_amount f
-- on a.store = f.store
-- and a.payment_date = f.payment_date
left join
(
    select
        store,
        payment_date,
        sum(case when order_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') then item_apportion_amount else null end) as cancelled,
        sum(case when refund_source  = 'RETURNED' then item_apportion_amount else null end) as returned
    from
        refund_order t
    group by
        store,
        payment_date
) c
on a.store = c.store
and a.payment_date = c.payment_date

union all
select
    a.payment_date,
    a.store,
    'qty' as type,
    original,
    shipped,
    cancelled,
    pending,
    returned,
     null as fulfil1,
    null as fulfil2,
    null as fulfil3,
    null as fulfil4,
    null as fulfil5,
    null as fulfil6,
    null as fulfil7,
    null as fulfil8,
    null as fulfil9,
    null as fulfil10,
    null as fulfil11,
    null as fulfil12,
    null as fulfil13,
    null as fulfil14,
    null as fulfil15,
    null as fulfil16,
    null as fulfil17,
    null as fulfil18,
    null as fulfil19,
    null as fulfil20,
    null as fulfil21,
    null as fulfil22,
    null as fulfil23,
    null as fulfil24,
    null as fulfil25,
    null as fulfil26,
    null as fulfil27,
    null as fulfil28,
    null as fulfil29,
    null as fulfil30,
    null as fulfil31,
    null as fulfil32,
    null as fulfil33,
    null as fulfil34,
    null as fulfil35,
    null as fulfil36,
    CONCAT(SUBSTRING(CAST(ROUND((ISNULL(shipped,0.0001)*100.0 + 0.0001 )/(ISNULL(original,0.0001) + 0.0001),2) AS VARCHAR(512)),1,5),'%') AS rate,
    current_timestamp as insert_timestamp
from
(
    select
        store,
        payment_date,
        count(distinct sales_order_number) as original,
        count(distinct case when order_status in ('SHIPPED', 'SIGNED', 'REJECTED', 'INTERCEPT', 'CANT_CONTACTED') then sales_order_number end) as shipped,
        count(distinct case when order_status in ('WAIT_SAPPROCESS', 'EXCEPTION', 'PENDING', 'WAIT_JD_CONFIRM', 'WAIT_JDPROCESS', 'WAIT_SEND_SAP', 'WAIT_TMALLPROCESS', 'WAIT_WAREHOUSE_PROCESS', 'SPLITED', 'WAIT_ROUTE_ORDER') then sales_order_number end) as pending
    from
        sales_order t
    group by
        store,
        payment_date
) a
-- left join
--     fullfill_qty f
-- on a.store = f.store
-- and a.payment_date = f.payment_date
left join
(
    select
        store,
        payment_date,
        count(distinct case when order_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') and refund_source = 'CANCELLED' then sales_order_number else null end) as cancelled,
        count(distinct case when refund_source  = 'RETURNED' then sales_order_number else null end) as returned
    from
        refund_order t
    group by
        store,
        payment_date
) c
on a.store = c.store
and a.payment_date = c.payment_date;
END


GO
