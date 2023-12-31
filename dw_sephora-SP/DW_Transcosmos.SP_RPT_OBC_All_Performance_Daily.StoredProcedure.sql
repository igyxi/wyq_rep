/****** Object:  StoredProcedure [DW_Transcosmos].[SP_RPT_OBC_All_Performance_Daily]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Transcosmos].[SP_RPT_OBC_All_Performance_Daily] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-21       houshaungqiang      change [STG_OMS].[OMS_Order_Refund] to DWD.Fact_Refund_Order
-- ========================================================================================
delete from [DW_Transcosmos].[RPT_OBC_All_Performance_Daily] where dt >= dateadd(DD,-4,@dt);
with refund as
(
    select  refund.refund_date
            ,sum(refund.refund_amount) as refund_amount
    from    [DW_Transcosmos].[DWS_IM_Service_Sales_Order_Detail] service
    left    join
    (
        select  sales_order_number
                ,sum(refund_amount) as refund_amount
                ,refund_date
        from
        (
            select  sales_order_number
                    ,refund_amount
                    ,format(refund_time, 'yyyy-MM-dd') as refund_date
                    ,format(max(refund_time) over (partition by sales_order_number),'yyyy-MM-dd') as latest_refund_date
            from
            (
               select   sales_order_number
                       -- ,purchase_order_number -- 如果申请单中的po单号和原始的退款单中单号不一样，会造成数据差异，如果将po去重去掉，也会造成数据差异（一个so单有多个po单分几次申请退款）
                        ,refund_number
                        ,refund_amount
                        ,refund_time
                from    DWD.Fact_Refund_Order
                where   source = 'OMS'
                and     refund_status = 'REFUNDED' -- 如果为了性能，可以在这里限制一下时间
                group   by sales_order_number,refund_number,refund_amount,refund_time
            ) p
        ) t
        where latest_refund_date between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt -- 这里限制的意义不是很大
        group   by sales_order_number,refund_date
    ) refund
    on  service.sales_order_number = refund.sales_order_number
	where service.seat_account is not null
    group by refund.refund_date
)


insert into [DW_Transcosmos].[RPT_OBC_All_Performance_Daily]
select
    substring(@dt,1,7) as statistic_month,
    session_end_date as statistic_date,
    a.payed_daily_amount as session_user_payed_daily_amount,
    a.payed_daily_amount-refund.refund_amount as session_user_actual_payed_daily_amount,
    current_timestamp as insert_timestamp,
    session_end_date as dt
from
(
    select
        cast(session_end_time as date) as session_end_date,
        sum(payed_amount) as payed_daily_amount
    from
        DW_Transcosmos.DWS_IM_Service_Sales_Order_Detail
    where
        dt >= dateadd(DD,-4,@dt)
    and
        seat_name is not null
    and
        cast(session_end_time as date) >= dateadd(DD,-4,@dt)
    group by
        cast(session_end_time as date)
)a
left join refund
on a.session_end_date = refund.refund_date
END
GO
