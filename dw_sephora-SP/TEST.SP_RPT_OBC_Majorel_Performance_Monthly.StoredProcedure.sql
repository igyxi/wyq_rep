/****** Object:  StoredProcedure [TEST].[SP_RPT_OBC_Majorel_Performance_Monthly]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_OBC_Majorel_Performance_Monthly] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-06       litao    Initial Version,Copy SP_RPT_OBC_Performance_Monthly logic 
 
-- ========================================================================================
delete from [test].[RPT_OBC_Majorel_Performance_Monthly] where statistic_month = cast(EOMONTH(@dt, -1) as varchar(7));

--- 全部majorel供应商相关的数据

-- 退款金额
with refund as
(
    select
		a.user_id,
        a.seat_id,
        b.refund_monthly_amount,
        b.refund_amount,
        b.latest_refund_time,
        a.payed_amount - coalesce(b.refund_amount,0) as actual_payed_amount,
        row_number() over (partition by a.seat_id, a.user_id, cast(latest_refund_time as date) order by (a.payed_amount - coalesce(b.refund_amount,0))) as refund_daily_seq
    from [test].[RPT_IM_Service_Majorel_Sales_Order_Detail] a
    left join
    (
		select 	sales_order_number,
				sum(case when format(refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then refund_amount else null end) refund_monthly_amount,
				sum(refund_amount) refund_amount,
				max(refund_time) as latest_refund_time
		from 
            (select distinct sales_order_number,refund_time,refund_amount from DWD.Fact_Refund_Order where 	refund_status = 'REFUNDED' ) a
		group 	by sales_order_number
    ) b
    on a.sales_order_number = b.sales_order_number
    where a.seat_id is not null
),

-- 会话的起止时间
session_s as
(
    select
        a.service_id as session_id,
        a.agent_id as seat_id,
		a.agent_name as seat_name, 
        visitor_name as user_id,
        begin_time as session_start_time,
        end_time as session_end_time,
        end_reason as session_end_type
    from
        [STG_Transcosmos].[CS_IM_Service] a
    inner join 
	   (select user_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') b  
    on a.agent_id=b.user_id
    where
        substring(dt,1,7) = cast(EOMONTH(@dt, -1) as varchar(7))
    and dt >= '2023-04-18'
    and try_cast(visitor_name as bigint) is not null
    and group_name in (N'商品相关',N'售前咨询', N'美容顾问','HomeChat')
),

-- so订单数据
so_order as
(
    select  o.sales_order_number
            ,m.member_id
            ,o.payed_amount
            ,o.place_time
    from
    (
            select sales_order_number,
--                member_id,
                member_card,
                payment_amount as payed_amount,
                place_time
        from    DWD.Fact_Sales_Order
        where   source = 'OMS'
        and     is_placed = 1
        and     channel_code = 'SOA'
        and     cast(place_time as date) between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1))
        group   by sales_order_number,member_card,payment_amount,place_time
    ) o
    left join
    (
        select  member_card
                ,cast(eb_user_id as nvarchar) as member_id
        from    DWD.DIM_Member_Info
        group   by member_card,eb_user_id
    ) m
    on  o.member_card = m.member_card
),

sessions_payed_cnt as
(
    select
        count(distinct case when format(a.session_end_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then a.session_id else null end) as session_payed_monthly_cnt,
        a.seat_id
    from
        session_s a
    inner join so_order b
    on a.user_id = b.member_id
    where
        b.place_time > a.session_start_time
    and b.member_id is not null
    and datediff(day,a.session_start_time,b.place_time) >= 0
    and datediff(day,a.session_start_time,b.place_time) < 5
    and a.seat_id is not null
    group by a.seat_id
    union all
	-- 求总金额
    select
        count(distinct case when format(a.session_end_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then a.session_id else null end) as session_payed_monthly_cnt,
        null as seat_id
    from
        session_s a
	inner join so_order b 
	on  a.user_id = b.member_id
    where
        b.place_time > a.session_start_time
    and b.member_id is not null
    and datediff(day,a.session_start_time,b.place_time) >= 0
    and datediff(day,a.session_start_time,b.place_time) < 5
    and a.seat_id is not null
)

insert into [test].[RPT_OBC_Majorel_Performance_Monthly]
select
    N'全部majorel供应商相关的数据' as Data_Content,
	cast(EOMONTH(@dt, -1) as varchar(7)),
    case when m.seat_id is null then 'total' else cast(m.seat_id as nvarchar(100)) end as seat_id,
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
        seat_id,
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
            a.seat_id,
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
                csh.seat_id,
                csh.seat_name,
                'Majorel' as seat_vendors,
                try_cast(csh.user_id as bigint) as user_id,
                csh.session_end_time,
                csh.session_end_type,
                csh.session_id,
                row_number() over(partition by csh.seat_id, csh.user_id,cast(csh.session_end_time as date) order by csh.session_end_time desc) session_daily_seq
            from
            --    (select user_id as seat_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') csi
            --left join
                session_s csh
            --on csi.seat_id = csh.seat_id
        ) a
        left join
        (
            select * from [test].[RPT_IM_Service_Majorel_Sales_Order_Detail] where dt between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1))
        ) b
        on a.user_id = b.user_id
        and a.seat_id = b.seat_id
        and a.session_end_time = b.session_end_time
    ) t
    group by seat_id,seat_name,seat_vendors
    union all
    select
        null as seat_id,
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
            a.seat_id,
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
                csh.seat_id,
                csh.seat_name,
                'Majorel' as seat_vendors,
                try_cast(csh.user_id as bigint) as user_id,
                csh.session_end_time,
                csh.session_end_type,
                csh.session_id,
                row_number() over(partition by csh.seat_id, csh.user_id,cast(csh.session_end_time as date) order by csh.session_end_time desc) session_daily_seq
            from
            --     (select user_id as seat_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') csi
            --left join
                session_s csh
            --on csi.seat_id = csh.seat_id
        ) a
        left join
        (
            select * from [test].[RPT_IM_Service_Majorel_Sales_Order_Detail] where dt between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1))
        ) b
        on a.user_id = b.user_id
        and a.seat_id = b.seat_id
        and a.session_end_time = b.session_end_time
    ) t
) m
left join
(
    select
        csi.seat_id,
        sum(refund_monthly_amount) as refund_monthly_amount,
        count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) and refund_daily_seq = 1 then user_id else null end) as refund_user_monthly_cnt
    from
        (select user_id as seat_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') csi
    left join
        refund
    on csi.seat_id = refund.seat_id
    where
        format(refund.latest_refund_time,'yyyy-MM')= cast(EOMONTH(@dt, -1) as varchar(7))
    group by csi.seat_id
    union all
    select
        null as seat_id,
        sum(refund_monthly_amount) as refund_monthly_amount,
        count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) and refund_daily_seq = 1 then user_id else null end) as refund_user_monthly_cnt
    from
        (select user_id as seat_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') csi
    left join
        refund
    on csi.seat_id = refund.seat_id
    where
        format(refund.latest_refund_time,'yyyy-MM')= cast(EOMONTH(@dt, -1) as varchar(7))
) n
on case when m.seat_id is null then 999999999 else m.seat_id end = case when n.seat_id is null then 999999999 else n.seat_id end
left join
    sessions_payed_cnt spc
on case when m.seat_id is null then 999999999 else m.seat_id end = case when spc.seat_id is null then 999999999 else spc.seat_id end
;


------剔除掉无效对话的majorel供应商相关数据


-- 退款金额
with refund as
(
    select
		a.user_id,
        a.seat_id,
        b.refund_monthly_amount,
        b.refund_amount,
        b.latest_refund_time,
        a.payed_amount - coalesce(b.refund_amount,0) as actual_payed_amount,
        row_number() over (partition by a.seat_id, a.user_id, cast(latest_refund_time as date) order by (a.payed_amount - coalesce(b.refund_amount,0))) as refund_daily_seq
    from [test].[RPT_IM_Service_Majorel_Sales_Order_Detail] a
    left join
    (
		select 	sales_order_number,
				sum(case when format(refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then refund_amount else null end) refund_monthly_amount,
				sum(refund_amount) refund_amount,
				max(refund_time) as latest_refund_time
		from 
            (select distinct sales_order_number,refund_time,refund_amount from DWD.Fact_Refund_Order where 	refund_status = 'REFUNDED' ) a
		group 	by sales_order_number
    ) b
    on a.sales_order_number = b.sales_order_number
    where a.seat_id is not null
	and  a.service_vaild = 1 --只取有效会话
),

-- 会话的起止时间
session_s as
(
    select
        a.service_id as session_id,
        a.agent_id as seat_id,
		a.agent_name as seat_name, 
        visitor_name as user_id,
        begin_time as session_start_time,
        end_time as session_end_time,
        end_reason as session_end_type
    from
        [STG_Transcosmos].[CS_IM_Service] a
    inner join 
	   (select user_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') b  
    on 
	   a.agent_id=b.user_id 
	inner join  
       (select distinct service_id from STG_Transcosmos.CS_IM_Service_Detail where service_vaild = 1) c  --只取有效会话
    on 
       a.service_id=c.service_id 
    where
        substring(dt,1,7) = cast(EOMONTH(@dt, -1) as varchar(7))
    and dt >= '2023-04-18'
    and try_cast(visitor_name as bigint) is not null
    and group_name in (N'商品相关',N'售前咨询', N'美容顾问','HomeChat')
),

-- so订单数据
so_order as
(
    select  o.sales_order_number
            ,m.member_id
            ,o.payed_amount
            ,o.place_time
    from
    (
            select sales_order_number,
--                member_id,
                member_card,
                payment_amount as payed_amount,
                place_time
        from    DWD.Fact_Sales_Order
        where   source = 'OMS'
        and     is_placed = 1
        and     channel_code = 'SOA'
        and     cast(place_time as date) between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1))
        group   by sales_order_number,member_card,payment_amount,place_time
    ) o
    left join
    (
        select  member_card
                ,cast(eb_user_id as nvarchar) as member_id
        from    DWD.DIM_Member_Info
        group   by member_card,eb_user_id
    ) m
    on  o.member_card = m.member_card
),

sessions_payed_cnt as
(
    select
        count(distinct case when format(a.session_end_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then a.session_id else null end) as session_payed_monthly_cnt,
        a.seat_id
    from
        session_s a
    inner join so_order b
    on a.user_id = b.member_id
    where
        b.place_time > a.session_start_time
    and b.member_id is not null
    and datediff(day,a.session_start_time,b.place_time) >= 0
    and datediff(day,a.session_start_time,b.place_time) < 5
    and a.seat_id is not null
    group by a.seat_id
    union all
	-- 求总金额
    select
        count(distinct case when format(a.session_end_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) then a.session_id else null end) as session_payed_monthly_cnt,
        null as seat_id
    from
        session_s a
	inner join so_order b 
	on  a.user_id = b.member_id
    where
        b.place_time > a.session_start_time
    and b.member_id is not null
    and datediff(day,a.session_start_time,b.place_time) >= 0
    and datediff(day,a.session_start_time,b.place_time) < 5
    and a.seat_id is not null
)

insert into [test].[RPT_OBC_Majorel_Performance_Monthly]
select
    N'剔除掉无效对话的majorel供应商相关数据' as Data_Content,
	cast(EOMONTH(@dt, -1) as varchar(7)),
    case when m.seat_id is null then 'total' else cast(m.seat_id as nvarchar(100)) end as seat_id,
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
        seat_id,
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
            a.seat_id,
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
                csh.seat_id,
                csh.seat_name,
                'Majorel' as seat_vendors,
                try_cast(csh.user_id as bigint) as user_id,
                csh.session_end_time,
                csh.session_end_type,
                csh.session_id,
                row_number() over(partition by csh.seat_id, csh.user_id,cast(csh.session_end_time as date) order by csh.session_end_time desc) session_daily_seq
            from
            --    (select user_id as seat_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') csi
            --left join
                session_s csh
            --on csi.seat_id = csh.seat_id
        ) a
        left join
        (
            select * from [test].[RPT_IM_Service_Majorel_Sales_Order_Detail] where dt between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1)) and service_vaild = 1  --只取有效会话
        ) b
        on a.user_id = b.user_id
        and a.seat_id = b.seat_id
        and a.session_end_time = b.session_end_time
    ) t
    group by seat_id,seat_name,seat_vendors
    union all
    select
        null as seat_id,
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
            a.seat_id,
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
                csh.seat_id,
                csh.seat_name,
                'Majorel' as seat_vendors,
                try_cast(csh.user_id as bigint) as user_id,
                csh.session_end_time,
                csh.session_end_type,
                csh.session_id,
                row_number() over(partition by csh.seat_id, csh.user_id,cast(csh.session_end_time as date) order by csh.session_end_time desc) session_daily_seq
            from
            --     (select user_id as seat_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') csi
            --left join
                session_s csh
            --on csi.seat_id = csh.seat_id
        ) a
        left join
        (
            select * from [test].[RPT_IM_Service_Majorel_Sales_Order_Detail] where dt between DATEADD(DD,1,EOMONTH(@dt, -2)) and DATEADD(DD,5,EOMONTH(@dt, -1)) and service_vaild = 1 --只取有效会话
        ) b
        on a.user_id = b.user_id
        and a.seat_id = b.seat_id
        and a.session_end_time = b.session_end_time
    ) t
) m
left join
(
    select
        csi.seat_id,
        sum(refund_monthly_amount) as refund_monthly_amount,
        count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) and refund_daily_seq = 1 then user_id else null end) as refund_user_monthly_cnt
    from
        (select user_id as seat_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') csi
    left join
        refund
    on csi.seat_id = refund.seat_id
    where
        format(refund.latest_refund_time,'yyyy-MM')= cast(EOMONTH(@dt, -1) as varchar(7))
    group by csi.seat_id
    union all
    select
        null as seat_id,
        sum(refund_monthly_amount) as refund_monthly_amount,
        count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = cast(EOMONTH(@dt, -1) as varchar(7)) and refund_daily_seq = 1 then user_id else null end) as refund_user_monthly_cnt
    from
        (select user_id as seat_id from [ODS_Transcosmos].[Public_Work_Group_User] where work_group_id='1000010337') csi
    left join
        refund
    on csi.seat_id = refund.seat_id
    where
        format(refund.latest_refund_time,'yyyy-MM')= cast(EOMONTH(@dt, -1) as varchar(7))
) n
on case when m.seat_id is null then 999999999 else m.seat_id end = case when n.seat_id is null then 999999999 else n.seat_id end
left join
    sessions_payed_cnt spc
on case when m.seat_id is null then 999999999 else m.seat_id end = case when spc.seat_id is null then 999999999 else spc.seat_id end
;


END
GO
