/****** Object:  StoredProcedure [TEMP].[SP_RPT_OBC_All_Performance_Daily_Bak_20230427]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OBC_All_Performance_Daily_Bak_20230427] @dt [VARCHAR](10) AS
BEGIN
delete from [DW_Transcosmos].[RPT_OBC_All_Performance_Daily] where dt >= dateadd(DD,-4,@dt);
with refund as
(
   select
       a.*,
       b.refund_daily_amount,
       b.refund_date
   from
       [DW_Transcosmos].[DWS_IM_Service_Sales_Order_Detail] a
   left join
   (
       select
           sales_order_number,
           refund_date,
           sum(refund_sum) as refund_daily_amount
       from
       (
           select 
               oms_order_refund_sys_id, 
               oms_order_code as sales_order_number, 
               cast(refund_time as date) as refund_date,
               cast(max(refund_time) over (partition by oms_order_code) as date) as latest_refund_date, 
               refund_sum 
            from 
                [STG_OMS].[OMS_Order_Refund] 
            where 
                refund_status = 'REFUNDED'
       ) t
       where latest_refund_date between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt
       group by sales_order_number,refund_date
   ) b
   on a.sales_order_number = b.sales_order_number
   where a.seat_account is not null
)

insert into [DW_Transcosmos].[RPT_OBC_All_Performance_Daily]
select 
    substring(@dt,1,7) as statistic_month,
    session_end_date as statistic_date,
    a.payed_daily_amount as session_user_payed_daily_amount,
    a.payed_daily_amount-b.refund_daily_amount as session_user_actual_payed_daily_amount,
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
left join 
(
    select 
        refund_date,
        sum(refund_daily_amount) as refund_daily_amount
    from
        refund
    group by 
        refund_date
)b
on a.session_end_date = b.refund_date
;
end
GO
