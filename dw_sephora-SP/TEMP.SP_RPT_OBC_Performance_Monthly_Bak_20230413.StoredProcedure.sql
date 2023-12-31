/****** Object:  StoredProcedure [TEMP].[SP_RPT_OBC_Performance_Monthly_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OBC_Performance_Monthly_Bak_20230413] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-07-05       tali           add 美容顾问
-- 2022-08-25       houshuangqiang add HomeChat
-- ========================================================================================
delete from [DW_Transcosmos].[RPT_OBC_Performance_Monthly] where statistic_month = cast(EOMONTH(@dt, -1) as varchar(7));
with 
refund as
(
    select
        a.*,
        b.refund_monthly_amount,
        b.refund_amount,
        b.latest_refund_time,
        a.payed_amount - (case when b.refund_amount is null then 0 else b.refund_amount end) as actual_payed_amount,
        row_number() over (partition by a.seat_account, a.user_id, cast(latest_refund_time as date) order by (a.payed_amount - (case when b.refund_amount is null then 0 else b.refund_amount end ))) as refund_daily_seq
    from
        [DW_Transcosmos].[DWS_IM_Service_Sales_Order_Detail] a
    left join
    (
        select
            sales_order_number,
            sum(case when format(refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then refund_sum else null end) refund_monthly_amount,
            sum(refund_sum) refund_amount,
            max(refund_time) as latest_refund_time
        from
        (
            select oms_order_refund_sys_id, oms_order_code as sales_order_number,refund_time, refund_sum from [STG_OMS].[OMS_Order_Refund] where refund_status = 'REFUNDED'
        ) t
        group by sales_order_number
    ) b
    on a.sales_order_number = b.sales_order_number
    where a.seat_account is not null
),
session_s as 
(
    select 
        service_id as session_id,
        b.seat_account,
        visitor_name as user_id,
        begin_time as session_start_time,
        end_time as session_end_time,
        end_reason as session_end_type
    from
        [STG_Transcosmos].[CS_IM_Service] a
    left join
        [STG_Transcosmos].[Seat_Info] b
    on a.agent_name = b.seat_name
    where
        substring(dt,1,7) = cast(EOMONTH(@dt, -1) as varchar(7))
    and dt >= '2021-02-09'
    and try_cast(visitor_name as bigint) is not null
    and group_name in (N'商品相关',N'售前咨询', N'美容顾问','HomeChat')
),
sessions_payed_cnt as
(
    select 
        count(distinct case when format(a.session_end_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then a.session_id else null end) as session_payed_monthly_cnt,
        a.seat_account
    from
        session_s a 
    inner join
    (
        select distinct
            sales_order_number,
            member_id,
            payed_amount,
            place_time
        from
            [DW_OMS].[DWS_Sales_Order]
        where
            is_placed_flag = 1
            and store_cd = 'S001'
            and cast(place_time as date) between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1))
    ) b 
    on a.user_id = b.member_id
    where
        b.place_time > a.session_start_time
    and b.member_id is not null
    and datediff(day,a.session_start_time,b.place_time) >= 0
    and datediff(day,a.session_start_time,b.place_time) < 5 
    and a.seat_account is not null
    group by a.seat_account
    union all
    select 
        count(distinct case when format(a.session_end_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then a.session_id else null end) as session_payed_monthly_cnt,
        null as seat_account
    from
        session_s a 
    inner join
    (
        select distinct
            sales_order_number,
            member_id,
            payed_amount,
            place_time
        from
            [DW_OMS].[DWS_Sales_Order]
        where
            is_placed_flag = 1
            and store_cd = 'S001'
            and cast(place_time as date) between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1))
    ) b 
    on a.user_id = b.member_id
    where
        b.place_time > a.session_start_time
    and b.member_id is not null
    and datediff(day,a.session_start_time,b.place_time) >= 0
    and datediff(day,a.session_start_time,b.place_time) < 5 
    and a.seat_account is not null
)

insert into [DW_Transcosmos].[RPT_OBC_Performance_Monthly]
select
    cast(EOMONTH(@dt, -1) as varchar(7)),
    case when m.seat_account is null then 'total' else m.seat_account end as seat_account,
    case when m.seat_name is null then 'total' else m.seat_name end as seat_name,
    case when m.seat_vendors is null then 'total' else m.seat_vendors end as seat_vendors,
    case when m.session_monthly_cnt is null then 0 else m.session_monthly_cnt end as session_monthly_cnt,
    case when spc.session_payed_monthly_cnt is null then 0 else spc.session_payed_monthly_cnt end as session_payed_monthly_cnt,
    case when m.session_monthly_cnt >0 then concat(cast(round(case when spc.session_payed_monthly_cnt is null then null else spc.session_payed_monthly_cnt end * 100.0 / m.session_monthly_cnt, 2) as varchar(512)) ,'%') else null end as session_payed_monthly_convert,
    case when m.session_user_monthly_cnt is null then 0 else m.session_user_monthly_cnt end as session_user_monthly_cnt,
    case when m.session_transfer_user_monthly_cnt is null then 0 else m.session_transfer_user_monthly_cnt end as session_transfer_user_monthly_cnt,
    case when m.session_real_user_monthly_cnt is null then 0 else m.session_real_user_monthly_cnt end as session_real_user_monthly_cnt,
    case when m.session_user_payed_monthly_cnt is null then 0 else m.session_user_payed_monthly_cnt end as session_user_payed_monthly_cnt,
    case when m.session_user_payed_monthly_amount is null then 0 else m.session_user_payed_monthly_amount end as session_user_payed_monthly_amount,
    case when m.session_user_payed_monthly_cnt is null then 0 else m.session_user_payed_monthly_cnt end - case when n.refund_user_monthly_cnt is null then 0 else n.refund_user_monthly_cnt end as session_user_actual_payed_monthly_cnt,
    (case when m.session_user_payed_monthly_amount is null then 0 else m.session_user_payed_monthly_amount end - case when n.refund_monthly_amount is null then 0 else n.refund_monthly_amount end) as session_user_actual_payed_monthly_amount,
    current_timestamp as insert_timestamp
from 
(
    select
        seat_account,
        seat_name,
        seat_vendors,
        count(distinct case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) then session_id else null end) as session_monthly_cnt,
        count(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and session_daily_seq = 1 then user_id else null end) as session_user_monthly_cnt,
        count(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_monthly_cnt,
        count(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_monthly_cnt,
        count(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and place_date between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1)) and place_daily_seq= 1 then user_id else null end) as session_user_payed_monthly_cnt,
        sum(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and place_date between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1)) then payed_amount else null end) as session_user_payed_monthly_amount
    from
    (
        select
            a.seat_account,
            a.seat_name,
            a.seat_vendors,
            a.user_id,
            a.session_id,
            a.session_end_time,
            format(a.session_end_time,'yyyy-MM') as session_end_month,
            a.session_daily_seq,
            b.payed_amount,
            b.place_time,
            cast(b.place_time as date) as place_date,
            b.place_daily_seq,
            a.session_end_type
        from
        (
            select 
                csi.seat_account,
                csi.seat_name,
                csi.seat_vendors,
                try_cast(csh.user_id as bigint) as user_id,
                csh.session_end_time,
                csh.session_end_type,
                csh.session_id,
                row_number() over(partition by csi.seat_account, csh.user_id,cast(csh.session_end_time as date) order by csh.session_end_time desc) session_daily_seq
            from
                [STG_Transcosmos].[Seat_Info] csi
            left join 
                session_s csh
            on csi.seat_account = csh.seat_account
        ) a
        left join
        (
            select * from [DW_Transcosmos].[DWS_IM_Service_Sales_Order_Detail] where dt between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1))
        ) b
        on a.user_id = b.user_id
        and a.seat_account = b.seat_account
        and a.session_end_time = b.session_end_time
    ) t
    group by seat_account,seat_name,seat_vendors
    union all
    select
        null as seat_account,
        null as seat_name,
        null as seat_vendors,
        count(distinct case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) then session_id else null end) as session_monthly_cnt,
        count(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and session_daily_seq = 1 then user_id else null end) as session_user_monthly_cnt,
        count(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_monthly_cnt,
        count(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_monthly_cnt,
        count(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and place_date between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1)) and place_daily_seq= 1 then user_id else null end) as session_user_payed_monthly_cnt,
        sum(case when session_end_month = cast(EOMONTH(@dt, -1) as varchar(7)) and place_date between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1)) then payed_amount else null end) as session_user_payed_monthly_amount
    from
    (
        select
            a.seat_account,
            a.seat_name,
            a.seat_vendors,
            a.user_id,
            a.session_id,
            a.session_end_time,
            format(a.session_end_time,'yyyy-MM') as session_end_month,
            a.session_daily_seq,
            b.payed_amount,
            b.place_time,
            cast(b.place_time as date) as place_date,
            b.place_daily_seq,
            a.session_end_type
        from
        (
            select 
                csi.seat_account,
                csi.seat_name,
                csi.seat_vendors,
                try_cast(csh.user_id as bigint) as user_id,
                csh.session_end_time,
                csh.session_end_type,
                csh.session_id,
                row_number() over(partition by csi.seat_account, csh.user_id,cast(csh.session_end_time as date) order by csh.session_end_time desc) session_daily_seq
            from
                [STG_Transcosmos].[Seat_Info] csi
            left join 
                session_s csh
            on csi.seat_account = csh.seat_account
        ) a
        left join
        (
            select * from [DW_Transcosmos].[DWS_IM_Service_Sales_Order_Detail] where dt between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1))
        ) b
        on a.user_id = b.user_id
        and a.seat_account = b.seat_account
        and a.session_end_time = b.session_end_time
    ) t 
) m
left join 
(
    select
        csi.seat_account,
        sum(refund_monthly_amount) as refund_monthly_amount,
        count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) and refund_daily_seq = 1 then user_id else null end) as refund_user_monthly_cnt
    from
        [STG_Transcosmos].[Seat_Info] csi
    left join 
        refund
    on csi.seat_account = refund.seat_account
    where 
        format(refund.latest_refund_time,'yyyy-MM')= cast(EOMONTH(@dt, -1) as varchar(7))
    group by csi.seat_account
    union all
    select
        null as seat_account,
        sum(refund_monthly_amount) as refund_monthly_amount,
        count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) and refund_daily_seq = 1 then user_id else null end) as refund_user_monthly_cnt
    from
        [STG_Transcosmos].[Seat_Info] csi
    left join 
        refund
    on csi.seat_account = refund.seat_account
    where 
        format(refund.latest_refund_time,'yyyy-MM')= cast(EOMONTH(@dt, -1) as varchar(7))
) n
on case when m.seat_account is null then 'total' else m.seat_account end = case when n.seat_account is null then 'total' else n.seat_account end
left join
    sessions_payed_cnt spc 
on case when m.seat_account is null then 'total' else m.seat_account end = case when spc.seat_account is null then 'total' else spc.seat_account end
;
END
GO
