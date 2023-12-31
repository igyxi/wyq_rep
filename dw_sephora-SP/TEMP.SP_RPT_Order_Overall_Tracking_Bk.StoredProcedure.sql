/****** Object:  StoredProcedure [TEMP].[SP_RPT_Order_Overall_Tracking_Bk]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Order_Overall_Tracking_Bk] @dt [varchar](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       tali     Initial Version
-- 2022-01-06       Mac      add cancel_daily
-- ========================================================================================
truncate table [DW_OMS].[RPT_Order_Overall_Tracking]
insert into [DW_OMS].[RPT_Order_Overall_Tracking]
select
    c.place_date as statistic_date,
    c.store_cd,
    c.payment_daily,
    isnull(a.pending_daily, 0),
    isnull(a.pending_mtd, 0),
    b.return_daily,
    b.cancel_daily,
    current_timestamp as insert_timestamp
from
(
    SELECT
        case when rsobl.store_cd ='S001' then rsobl.store_cd else channel_cd end as store_cd
        ,rsobl.place_date
        ,SUM(rsobl.product_amount) AS payment_daily
    FROM 
        DW_OMS.RPT_Sales_Order_Basic_Level rsobl
    JOIN 
        DW_Common.Dim_EB_StoreGroup desg
    ON 
        desg.store_cd = rsobl.store_cd COLLATE Chinese_PRC_CS_AI_WS
    WHERE 
        rsobl.is_placed_flag = 1
    AND desg.store_group IS NOT NULL
    and rsobl.place_date >= dateadd(day,1,EOMONTH(@dt,-1))
    and rsobl.place_date <= @dt
    -- AND rsobl.place_date >= '2021-10-01'
    AND rsobl.channel_cd <> 'OFF_LINE'
    GROUP BY 
        case when rsobl.store_cd ='S001' then rsobl.store_cd else channel_cd end,
        rsobl.place_date
)c 
left join
    DW_OMS.RPT_Pending_Orders_Statistic a 
on a.store_cd=c.store_cd
and a.statistic_date=c.place_date
left join
(
    select
        sync_date as statistic_date,
        case when b.store_cd ='S001' then b.store_cd else b.channel_cd end as store_cd,
        sum(refund_amount) as return_daily,
        sum(cancel_amount) as cancel_daily
    from
    (
        select distinct
            oms_order_refund_sys_id,
            sales_order_number,
            case when negative_type in (N'线上退货退款',N'拒收',N'退货退款',N'联系不到客户',N'库内拦截')  then refund_amount else 0 end refund_amount,
            case when negative_type in (N'取消',N'整单取消退款',N'部分取消')  then refund_amount else 0 end cancel_amount,
            case when negative_type in (N'线上退货退款',N'拒收',N'退货退款',N'联系不到客户',N'库内拦截')      then  format(sap_sync_time, 'yyyy-MM-dd')
                 when  negative_type in (N'取消',N'整单取消退款',N'部分取消')    then format(refund_time, 'yyyy-MM-dd') end  as sync_date
        from
            DW_OMS.DWS_Negative_Order
        where
            -- negative_type in (N'取消',N'线上退货退款',N'整单取消退款',N'拒收',N'退货退款',N'联系不到客户',N'部分取消')
            negative_type in (N'线上退货退款',N'拒收',N'退货退款',N'联系不到客户',N'库内拦截',N'取消',N'整单取消退款',N'部分取消')
            
          and refund_status = 'REFUNDED'
    )a
    inner join
        dw_oms.RPT_Sales_Order_Basic_Level b
    on a.sales_order_number = b.sales_order_number
    group by 
        sync_date,
        case when b.store_cd ='S001' then b.store_cd else b.channel_cd end 
)b
on a.store_cd = b.store_cd
and a.statistic_date = b.statistic_date;

UPDATE STATISTICS DW_OMS.RPT_Order_Overall_Tracking;
END


GO
