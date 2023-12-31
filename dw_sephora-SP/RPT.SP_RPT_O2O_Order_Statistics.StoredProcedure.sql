/****** Object:  StoredProcedure [RPT].[SP_RPT_O2O_Order_Statistics]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_O2O_Order_Statistics] @dt [date] AS
BEGIN
insert  into RPT.RPT_O2O_Order_Statistics
select  p.statistics_date
        ,p.channel_code
        ,p.channel_name
        ,p.store_code
        ,p.store_name
        ,sum(p.total_amount) as total_amount
        ,sum(p.sales_amount) as sales_amount
        ,sum(p.sales_quantity) as sales_quantity
        ,sum(p.refund_amount) as refund_amount
        ,sum(p.refund_quantity) as refund_quantity
        ,sum(p.return_amount) as return_amount
        ,sum(p.return_quantity) as return_quantity
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from
(
    select  format(complete_time, 'yyyy-MM-dd') as statistics_date
            ,channel_code
            ,channel_name
            ,store_code
            ,store_name
            ,sum(item_total_amount) as total_amount
            ,sum(item_apportion_amount) as sales_amount
            ,count(distinct sales_order_number) as sales_quantity
            ,0 as refund_amount
            ,0 as refund_quantity
            ,0 as return_amount
            ,0 as return_quantity
    from    DW_New_OMS.DWS_Store_Order_With_SKU
    where   format(complete_time, 'yyyy-MM-dd') = @dt
    and     is_placed = 1
    group   by format(complete_time, 'yyyy-MM-dd'),channel_code,channel_name,store_code,store_name
    union   all
    select  format(refund_time, 'yyyy-MM-dd') as statistics_date
            ,channel_code
            ,channel_name
            ,store_code
            ,store_name
            ,0 as total_amount
            ,0 as sales_amount
            ,0 as sales_quantity
            ,sum(case when order_type = 'CANCELED' then item_apportion_amount else 0 end) as refund_amount
            ,count(distinct case when order_type = 'CANCELED' then refund_no else null end) as refund_quantity
            ,sum(case when order_type = 'RETURN' then item_apportion_amount else 0 end) as return_amount
            ,count(distinct case when order_type = 'RETURN' then refund_no else null end) as return_quantity
    from    DW_New_OMS.DWS_Refund_Order
    where   format(refund_time, 'yyyy-MM-dd') = @dt
    and     refund_status = N'退款成功'
    group   by format(refund_time, 'yyyy-MM-dd'),channel_code,channel_name,store_code,store_name
) p
group by p.statistics_date,p.channel_code,p.channel_name,p.store_code,p.store_name
END
GO
