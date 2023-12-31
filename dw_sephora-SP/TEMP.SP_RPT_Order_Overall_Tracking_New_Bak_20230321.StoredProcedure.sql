/****** Object:  StoredProcedure [TEMP].[SP_RPT_Order_Overall_Tracking_New_Bak_20230321]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Order_Overall_Tracking_New_Bak_20230321] @dt [varchar](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       tali     Initial Version
-- 2022-01-06       Mac      add cancel_daily
-- 2022-01-27       Tali     delete collate
-- 2023-03-20       wangzhichun change_source
-- ========================================================================================
truncate table [DW_OMS].[RPT_Order_Overall_Tracking_New];
insert into [DW_OMS].[RPT_Order_Overall_Tracking_New]
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
        case when rsobl.channel_code ='SOA' then 'S001'
            when sub_channel_code='TMALL006' then 'TMALL_WEI'
            when sub_channel_code='TMALL004' then 'TMALL_CHALING'
            when sub_channel_code='TMALL005' then 'TMALL_PTR'
            when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
            when sub_channel_code='DOUYIN001' then 'DOUYIN'
            when sub_channel_code='REDBOOK001' then 'REDBOOK'
            when sub_channel_code='JD003' then 'JD_FCS'
            when sub_channel_code in ('JD001','JD002') then 'JD'
            when sub_channel_code='GWP001' then 'OFF_LINE'
            else sub_channel_code end  as store_cd
        ,rsobl.place_date
        ,SUM(rsobl.product_amount) AS payment_daily
    FROM 
        -- DW_OMS.RPT_Sales_Order_Basic_Level rsobl
        RPT.RPT_Sales_Order_Basic_Level rsobl
    JOIN 
        DW_Common.Dim_EB_StoreGroup desg
    ON 
        desg.store_cd = case when rsobl.channel_code='SOA' THEN 'S001' ELSE rsobl.sub_channel_code END
    WHERE 
        rsobl.is_placed = 1
    AND desg.store_group IS NOT NULL
    and rsobl.place_date >= dateadd(day,1,EOMONTH(@dt,-1))
    and rsobl.place_date <= @dt
    -- AND rsobl.place_date >= '2021-10-01'
    AND rsobl.sub_channel_code <> 'GWP001'
    GROUP BY 
        case when rsobl.channel_code ='SOA' then 'S001'
            when sub_channel_code='TMALL006' then 'TMALL_WEI'
            when sub_channel_code='TMALL004' then 'TMALL_CHALING'
            when sub_channel_code='TMALL005' then 'TMALL_PTR'
            when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
            when sub_channel_code='DOUYIN001' then 'DOUYIN'
            when sub_channel_code='REDBOOK001' then 'REDBOOK'
            when sub_channel_code='JD003' then 'JD_FCS'
            when sub_channel_code in ('JD001','JD002') then 'JD'
            when sub_channel_code='GWP001' then 'OFF_LINE'
            else sub_channel_code end,
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
        case when b.channel_code ='SOA' then 'S001'
            when sub_channel_code='TMALL006' then 'TMALL_WEI'
            when sub_channel_code='TMALL004' then 'TMALL_CHALING'
            when sub_channel_code='TMALL005' then 'TMALL_PTR'
            when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
            when sub_channel_code='DOUYIN001' then 'DOUYIN'
            when sub_channel_code='REDBOOK001' then 'REDBOOK'
            when sub_channel_code='JD003' then 'JD_FCS'
            when sub_channel_code in ('JD001','JD002') then 'JD'
            when sub_channel_code='GWP001' then 'OFF_LINE'
            else sub_channel_code end as store_cd,
        sum(refund_amount) as return_daily,
        sum(cancel_amount) as cancel_daily
    from
    (
        select distinct
            -- oms_order_refund_sys_id,
            sales_order_number,
            case when negative_type in (N'线上退货退款',N'拒收',N'退货退款',N'联系不到客户',N'库内拦截')  then refund_amount else 0 end refund_amount,
            case when negative_type in (N'取消',N'整单取消退款',N'部分取消')  then refund_amount else 0 end cancel_amount,
            case when negative_type in (N'线上退货退款',N'拒收',N'退货退款',N'联系不到客户',N'库内拦截')      then  format(sap_sync_time, 'yyyy-MM-dd')
                 when  negative_type in (N'取消',N'整单取消退款',N'部分取消')    then format(refund_time, 'yyyy-MM-dd') end  as sync_date
        from
        (
            select 
                sales_order_number,
                order_status,
                refund_status,
                refund_amount,
                refund_time,
                sync_time as sap_sync_time,
                case when refund.order_status in ('SHIPPED','SIGNED') and refund.refund_type in('FULL_ITEM_REFUND') then N'整单取消退款'
                    when refund.order_status in ('SHIPPED','SIGNED') and refund.refund_type in('RETURN_REFUND') then N'退货退款'
                    when refund.order_status in ('SHIPPED','SIGNED') and refund.refund_type in('ONLINE_RETURN_REFUND') then N'线上退货退款'
                    when refund.order_status is null then 'NO DETAIL'
                else i.order_status_cn end as negative_type
            from 
                DWD.Fact_Refund_Order refund
            left join
                DW_OMS.DIM_Purchase_Order_Status i
            on refund.order_status = i.order_status_en
        ) refund
        where
            -- negative_type in (N'取消',N'线上退货退款',N'整单取消退款',N'拒收',N'退货退款',N'联系不到客户',N'部分取消')
            negative_type in (N'线上退货退款',N'拒收',N'退货退款',N'联系不到客户',N'库内拦截',N'取消',N'整单取消退款',N'部分取消')
        and refund_status = 'REFUNDED'
    )a
    inner join
        -- dw_oms.RPT_Sales_Order_Basic_Level b
        RPT.RPT_Sales_Order_Basic_Level b
    on a.sales_order_number = b.sales_order_number
    group by 
        sync_date,
        case when b.channel_code ='SOA' then 'S001'
            when sub_channel_code='TMALL006' then 'TMALL_WEI'
            when sub_channel_code='TMALL004' then 'TMALL_CHALING'
            when sub_channel_code='TMALL005' then 'TMALL_PTR'
            when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
            when sub_channel_code='DOUYIN001' then 'DOUYIN'
            when sub_channel_code='REDBOOK001' then 'REDBOOK'
            when sub_channel_code='JD003' then 'JD_FCS'
            when sub_channel_code in ('JD001','JD002') then 'JD'
            when sub_channel_code='GWP001' then 'OFF_LINE'
            else sub_channel_code end
)b
on a.store_cd = b.store_cd
and a.statistic_date = b.statistic_date;

UPDATE STATISTICS DW_OMS.RPT_Order_Overall_Tracking;
END



GO
