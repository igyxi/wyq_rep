/****** Object:  StoredProcedure [RPT].[SP_RPT_O2O_Order_Statistics_New]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_O2O_Order_Statistics_New] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description      version
-- ----------------------------------------------------------------------------------------
-- 2023-01-17       houshuangqiang   O2O 月报统计    Initial Version, 从sku 表中计算取值
-- ========================================================================================
delete from RPT.RPT_O2O_Order_Statistics_New where dt = @dt;
insert into RPT.RPT_O2O_Order_Statistics_New
select  p.statistics_date
        ,p.channel_code
        ,p.channel_name
        ,p.store_code
        ,p.store_name
        ,sum(p.sales_quantity) as sales_quantity
        ,sum(p.sales_amount) as sales_amount
        ,sum(p.refund_quantity) as refund_quantity
        ,sum(p.refund_amount) as refund_amount
        ,sum(p.return_quantity) as return_quantity
        ,sum(p.return_amount) as return_amount
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from
(
    select 	format(complete_time,'yyyy-MM-dd') as statistics_date
            ,channel_code
            ,channel_name
            ,store_code
            ,store_name
            ,count(distinct sales_order_number) as sales_quantity
            ,sum(item_apportion_amount) as sales_amount
            ,0 as refund_quantity
            ,0 as refund_amount
            ,0 as return_quantity
            ,0 as return_amount
    from 	[DW_NEW_OMS].[DWS_Store_Order_With_SKU]
    where   is_placed = 1
    and     format(complete_time, 'yyyy-MM-dd') = @dt
    and     channel_code in ('JDDJ', 'DIANPING') -- 京东到家/大众点评的销售金额是按自然天统计的
    group   by format(complete_time,'yyyy-MM-dd'),channel_code,channel_name,store_code,store_name
    union   all
    select 	@dt as statistics_date
            ,channel_code
            ,channel_name
            ,store_code
            ,store_name
            ,count(distinct sales_order_number) as sales_quantity
            ,sum(item_apportion_amount) as sales_amount
            ,0 as refund_quantity
            ,0 as refund_amount
            ,0 as return_quantity
            ,0 as return_amount
    from 	[DW_NEW_OMS].[DWS_Store_Order_With_SKU] -- bi_datamart 用 O2O.DWS_Store_Order_With_SKU 表
    where   is_placed = 1
    and     complete_time between concat(@dt, ' 05:00:00') and concat(format(dateadd(day, 1, @dt),'yyyy-MM-dd'), ' 04:59:59')
    and     channel_code = 'MEITUAN'
    group   by channel_code,channel_name,store_code,store_name
    union   all
    select 	format(refund_time,'yyyy-MM-dd') as statistics_date
            ,channel_code
            ,channel_name
            ,store_code
            ,store_name
            ,0 as sales_quantity
            ,0 as sales_amount
            ,count(distinct case when order_type = 'CANCELED' then refund_no end) as refund_quantity -- 可能要加refund_type = 'ALL'
            ,sum(case when order_type = 'CANCELED' then item_apportion_amount end)  as refund_amount
            ,count(distinct case when order_type = 'RETURNED' then refund_no end) as return_quantity
            ,sum(case when order_type = 'RETURNED' then item_apportion_amount end)  as return_amount
    from 	[DW_NEW_OMS].[DWS_Refund_Order]
    where   refund_status = N'退款成功'
    and     order_type = 'RETURNED'
    and     format(refund_time, 'yyyy-MM-dd') = @dt
    and     channel_code in ('JDDJ', 'DIANPING') -- 京东到家/大众点评的销售金额是按自然天统计的
    group   by format(refund_time,'yyyy-MM-dd'),channel_code,channel_name,store_code,store_name
    union   all
    select 	@dt as statistics_date
            ,channel_code
            ,channel_name
            ,store_code
            ,store_name
            ,0 as sales_quantity
            ,0 as sales_amount
            ,count(distinct case when order_type = 'CANCELED' then refund_no end) as refund_quantity -- 可能要加refund_type = 'ALL'
            ,sum(case when order_type = 'CANCELED' then item_apportion_amount end)  as refund_amount
            ,count(distinct case when order_type = 'RETURNED' then refund_no end) as return_quantity
            ,sum(case when order_type = 'RETURNED' then item_apportion_amount end)  as return_amount
    from 	[DW_NEW_OMS].[DWS_Refund_Order]
    where   refund_status = N'退款成功'
    and     order_type = 'RETURNED'
    and     refund_time between concat(@dt, ' 05:00:00') and concat(format(dateadd(day, 1, @dt),'yyyy-MM-dd'), ' 04:59:59')
    and     channel_code = 'MEITUAN'
    group   by channel_code,channel_name,store_code,store_name
) p
group by p.statistics_date,p.channel_code,p.channel_name,p.store_code,p.store_name
END

GO
