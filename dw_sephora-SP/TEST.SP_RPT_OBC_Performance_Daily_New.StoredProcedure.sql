/****** Object:  StoredProcedure [TEST].[SP_RPT_OBC_Performance_Daily_New]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_OBC_Performance_Daily_New] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-07-05       tali           add 美容顾问
-- 2022-08-25       houshuangqiang add HomeChat
-- 2022-04-14       litao          1.剔除掉无效对话的majorel供应商相关数据，2.全部majorel供应商相关的数据
-- ========================================================================================
delete from [test].[RPT_OBC_Performance_Daily_New] where dt = @dt;

--- 全部majorel供应商相关的数据
with DWS_IM_Service_Sales_Order_Detail_Tmp as
(
select 
    a.seat_id,
    a.seat_id as seat_account, 
    a.seat_name, 
    a.seat_group_id,
    a.seat_service_id,
    a.seat_vendors,
    a.user_id, 
    a.session_start_time,
    a.session_end_time, 
    a.sales_order_number,
    a.payed_amount,
    a.place_time,
    a.place_daily_seq, 
    a.dt 
from
    test.DWS_IM_Service_Sales_Order_Detail_New a  
)
,
refund as
(
   select
       a.*,
       b.refund_daily_amount,
       b.refund_mtd_amount,
       b.refund_amount,
       b.latest_refund_time,
       a.payed_amount - (case when b.refund_amount is null then 0 else b.refund_amount end)actual_payed_amount,
       row_number() over (partition by a.seat_account, a.user_id, cast(latest_refund_time as date) order by (a.payed_amount - (case when b.refund_amount is null then 0 else b.refund_amount end))) as refund_daily_seq
   from
       DWS_IM_Service_Sales_Order_Detail_Tmp a
   left join
   (
       select
           sales_order_number,
           sum(case when cast(refund_time as date) = @dt then refund_sum else null end) refund_daily_amount,
           sum(case when year(refund_time) = year(@dt) and MONTH(refund_time) = MONTH(@dt) then refund_sum else null end) refund_mtd_amount,
           sum(refund_sum) refund_amount,
           max(refund_time) as latest_refund_time
       from
       (
           select distinct  sales_order_number, refund_time, refund_amount as refund_sum from DWD.Fact_Refund_Order where source = 'OMS' and refund_status = 'REFUNDED'
       ) t
       group by sales_order_number
   ) b
   on a.sales_order_number = b.sales_order_number
   where a.seat_account is not null 
)

insert into [test].[RPT_OBC_Performance_Daily_New]
select
   N'全部majorel供应商相关的数据',
   substring(@dt,1,7),
   @dt as statistic_date,
   case when m.seat_account is null then 'total' else m.seat_account end as seat_account,
   case when m.seat_name is null then 'total' else m.seat_name end as seat_name,
   case when m.seat_vendors is null then 'total' else m.seat_vendors end as seat_vendors,
   case when m.session_user_daily_cnt is null then 0 else m.session_user_daily_cnt end as session_user_daily_cnt,
   case when m.session_transfer_user_daily_cnt is null then 0 else m.session_transfer_user_daily_cnt end as session_transfer_user_daily_cnt,
   case when m.session_real_user_daily_cnt is null then 0 else m.session_real_user_daily_cnt end as session_real_user_daily_cnt,
   case when m.session_user_payed_daily_cnt is null then 0 else m.session_user_payed_daily_cnt end as session_user_payed_daily_cnt,
   case when m.session_user_payed_daily_amount is null then 0 else m.session_user_payed_daily_amount end as session_user_payed_daily_amount,
   case when m.session_user_payed_daily_cnt is null then 0 else m.session_user_payed_daily_cnt end - case when n.refund_user_daily_cnt is null then 0 else n.refund_user_daily_cnt end as session_user_actual_payed_daily_cnt,
   case when m.session_user_payed_daily_amount is null then 0 else m.session_user_payed_daily_amount end - case when n.refund_daily_amount is null then 0 else n.refund_daily_amount end as session_user_actual_payed_daily_amount,
   case when m.session_user_mtd_cnt is null then 0 else m.session_user_mtd_cnt end as session_user_mtd_cnt,
   case when m.session_transfer_user_mtd_cnt is null then 0 else m.session_transfer_user_mtd_cnt end as session_transfer_user_mtd_cnt,
   case when m.session_real_user_mtd_cnt is null then 0 else m.session_real_user_mtd_cnt end as session_real_user_mtd_cnt,
   case when m.session_user_payed_mtd_cnt is null then 0 else m.session_user_payed_mtd_cnt end as session_user_payed_mtd_cnt,
   case when m.session_user_payed_mtd_amount is null then 0 else m.session_user_payed_mtd_amount end as session_user_payed_mtd_amount,
   case when m.session_user_payed_mtd_cnt is null then 0 else m.session_user_payed_mtd_cnt end  - case when n.refund_user_mtd_cnt is null then 0 else n.refund_user_mtd_cnt end  as session_user_actual_payed_daily_cnt,
   case when m.session_user_payed_mtd_amount is null then 0 else m.session_user_payed_mtd_amount end - case when n.refund_mtd_amount is null then 0 else n.refund_mtd_amount end as session_user_actual_payed_daily_amount,
   current_timestamp as insert_timestamp,
   @dt as dt
from 
(
   select
       seat_account,
       seat_name,
       seat_vendors,
       count(case when session_end_date = @dt and session_daily_seq = 1 then user_id else null end) as session_user_daily_cnt,
       count(case when session_end_date = @dt and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_daily_cnt,
       count(case when session_end_date = @dt and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_daily_cnt,
       count(case when session_end_date = @dt and place_date = @dt and place_daily_seq= 1 then user_id else null end) as session_user_payed_daily_cnt,
       sum(case when session_end_date = @dt and place_date = @dt then payed_amount else null end) as session_user_payed_daily_amount,
       count(case when session_end_month = substring(@dt,1,7) and session_daily_seq = 1 then user_id else null end) as session_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and place_month = substring(@dt,1,7) and place_daily_seq= 1 then user_id else null end) as session_user_payed_mtd_cnt,
       sum(case when session_end_month = substring(@dt,1,7) and place_month = substring(@dt,1,7) then payed_amount else null end) as session_user_payed_mtd_amount
   from
   (
       select
           a.seat_account,
           a.seat_name,
           a.seat_vendors,
           a.user_id,
           a.session_end_time,
           cast(a.session_end_time as date) as session_end_date,
           format(a.session_end_time,'yyyy-MM') as session_end_month,
           a.session_daily_seq,
           b.payed_amount,
           b.place_time,
           cast(b.place_time as date) as place_date,
           format(b.place_time,'yyyy-MM') as place_month,
           b.place_daily_seq,
           a.session_end_type
       from
       (
           select 
               --csi.seat_account,
               cs.agent_id as seat_account,
               --csi.seat_name,
               cs.agent_name as seat_name,
               'Majorel'  as seat_vendors,
               --csi.seat_vendors,
               try_cast(cs.visitor_name as bigint) as user_id,
               cs.end_time as session_end_time,
               cs.end_reason as session_end_type,
               --row_number() over(partition by csi.seat_account, cs.visitor_name, cast(cs.end_time as date) order by cs.end_time desc) session_daily_seq
               row_number() over(partition by cs.agent_id, cs.visitor_name, cast(cs.end_time as date) order by cs.end_time desc) session_daily_seq
           from
            (select user_id 
			   from [ODS_Transcosmos].[Public_Work_Group_User] 
			   where work_group_id='1000010337' --只取 “Majorel-售前”
			 ) us
		   inner join
           (
               select  
                   *
               from 
                   [STG_Transcosmos].[CS_IM_Service] a 
               where 
                   dt between '2021-02-09' and @dt
               and try_cast(visitor_name as bigint) is not null
               and group_name in (N'商品相关',N'售前咨询', N'美容顾问', 'HomeChat') 
           ) cs
          on us.user_id = cs.agent_id
       ) a
       left join
       (
           select *  from DWS_IM_Service_Sales_Order_Detail_Tmp where dt between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt  
       ) b
       on a.user_id = b.user_id
       and a.seat_account = b.seat_id
       and a.session_end_time = b.session_end_time
   ) t
   group by seat_account,seat_name,seat_vendors
   union all
   select
       null as seat_account,
       null as seat_name,
       null as seat_vendors,
       count(case when session_end_date = @dt and session_daily_seq = 1 then user_id else null end) as session_user_daily_cnt,
       count(case when session_end_date = @dt and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_daily_cnt,
       count(case when session_end_date = @dt and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_daily_cnt,
       count(case when session_end_date = @dt and place_date = @dt and place_daily_seq= 1 then user_id else null end) as session_user_payed_daily_cnt,
       sum(case when session_end_date = @dt and place_date = @dt then payed_amount else null end) as session_user_payed_daily_amount,
       count(case when session_end_month = substring(@dt,1,7) and session_daily_seq = 1 then user_id else null end) as session_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and place_month = substring(@dt,1,7) and place_daily_seq= 1 then user_id else null end) as session_user_payed_mtd_cnt,
       sum(case when session_end_month = substring(@dt,1,7) and place_month = substring(@dt,1,7) then payed_amount else null end) as session_user_payed_mtd_amount
   from
   (
       select
           a.seat_account,
           a.seat_name,
           a.seat_vendors,
           a.user_id,
           a.session_end_time,
           cast(a.session_end_time as date) as session_end_date,
           format(a.session_end_time,'yyyy-MM') as session_end_month,
           a.session_daily_seq,
           b.payed_amount,
           b.place_time,
           cast(b.place_time as date) as place_date,
           format(b.place_time,'yyyy-MM') as place_month,
           b.place_daily_seq,
           a.session_end_type
       from
       (
           select 
               --csi.seat_account,
               cs.agent_id as seat_account,
               --csi.seat_name,
               cs.agent_name as seat_name,
               'Majorel'  as seat_vendors,
               --csi.seat_vendors,
               try_cast(cs.visitor_name as bigint) as user_id,
               cs.end_time as session_end_time,
               cs.end_reason as session_end_type,
               --row_number() over(partition by csi.seat_account, cs.visitor_name, cast(cs.end_time as date) order by cs.end_time desc) session_daily_seq
               row_number() over(partition by cs.agent_id, cs.visitor_name, cast(cs.end_time as date) order by cs.end_time desc) session_daily_seq
           from
           (select user_id 
			   from [ODS_Transcosmos].[Public_Work_Group_User] 
			   where work_group_id='1000010337' --只取 “Majorel-售前”
			 ) us
		   inner join
           (
               select  
                   *
               from 
                   [STG_Transcosmos].[CS_IM_Service]
               where 
                   dt between '2021-02-09' and @dt
               and try_cast(visitor_name as bigint) is not null
               and group_name in (N'商品相关',N'售前咨询', N'美容顾问', 'HomeChat') 
           ) cs
           on us.user_id = cs.agent_id
       ) a
       left join
       (
           select *  from DWS_IM_Service_Sales_Order_Detail_Tmp where dt between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt
       ) b
       on a.user_id = b.user_id
       and a.seat_account = b.seat_id
       and a.session_end_time = b.session_end_time
  ) t
) m
left join
(
   select
       seat_account,
       sum(refund_daily_amount) as refund_daily_amount,
       sum(refund_mtd_amount) as refund_mtd_amount,
       count(case when actual_payed_amount < 1 and cast(latest_refund_time as date) = @dt and refund_daily_seq = 1 then user_id else null end) as refund_user_daily_cnt,
       count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = substring(@dt,1,7) and refund_daily_seq = 1 then user_id else null end) as refund_user_mtd_cnt
   from
       refund
   where
       cast(latest_refund_time as date) between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt
   group by seat_account
   union all
   select
       null as seat_account,
       sum(refund_daily_amount) as refund_daily_amount,
       sum(refund_mtd_amount) as refund_mtd_amount,
       count(case when actual_payed_amount < 1 and cast(latest_refund_time as date) = @dt and refund_daily_seq = 1 then user_id else null end) as refund_user_daily_cnt,
       count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = substring(@dt,1,7) and refund_daily_seq = 1 then user_id else null end) as refund_user_mtd_cnt
   from
       refund
   where
       cast(latest_refund_time as date) between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt
) n
on case when m.seat_account is null then 'total' else m.seat_account end  = case when n.seat_account is null then 'total' else n.seat_account end
;


---剔除掉无效对话的majorel供应商相关数据

with DWS_IM_Service_Sales_Order_Detail_Tmp as
(
select
    a.seat_id,
    a.seat_id as seat_account, 
    a.seat_name, 
    a.seat_group_id,
    a.seat_service_id,
    a.seat_vendors,
    a.user_id, 
    a.session_start_time,
    a.session_end_time, 
    a.sales_order_number,
    a.payed_amount,
    a.place_time,
    a.place_daily_seq, 
    a.dt,
    case
        when b.service_vaild is not null then service_vaild
        else 0
    end as service_vaild --判断'会话是否有效, 1:有效,0:无效'
from
    test.DWS_IM_Service_Sales_Order_Detail_New a
left join 
(
    select
        distinct service_id,service_vaild
    from
        STG_Transcosmos.CS_IM_Service_Detail
    where
        service_vaild = 1
) b 
on
    a.seat_service_id = b.service_id
where b.service_vaild is not null --剔除无效会话
)
,
refund as
(
   select
       a.*,
       b.refund_daily_amount,
       b.refund_mtd_amount,
       b.refund_amount,
       b.latest_refund_time,
       a.payed_amount - (case when b.refund_amount is null then 0 else b.refund_amount end)actual_payed_amount,
       row_number() over (partition by a.seat_account, a.user_id, cast(latest_refund_time as date) order by (a.payed_amount - (case when b.refund_amount is null then 0 else b.refund_amount end))) as refund_daily_seq
   from
       DWS_IM_Service_Sales_Order_Detail_Tmp a
   left join
   (
       select
           sales_order_number,
           sum(case when cast(refund_time as date) = @dt then refund_sum else null end) refund_daily_amount,
           sum(case when year(refund_time) = year(@dt) and MONTH(refund_time) = MONTH(@dt) then refund_sum else null end) refund_mtd_amount,
           sum(refund_sum) refund_amount,
           max(refund_time) as latest_refund_time
       from
       (
           select distinct  sales_order_number, refund_time, refund_amount as refund_sum from DWD.Fact_Refund_Order where source = 'OMS' and refund_status = 'REFUNDED'
       ) t
       group by sales_order_number
   ) b
   on a.sales_order_number = b.sales_order_number
   where a.seat_account is not null 
)

insert into [test].[RPT_OBC_Performance_Daily_New]
select
   N'剔除掉无效对话的majorel供应商相关数据',
   substring(@dt,1,7),
   @dt as statistic_date,
   case when m.seat_account is null then 'total' else m.seat_account end as seat_account,
   case when m.seat_name is null then 'total' else m.seat_name end as seat_name,
   case when m.seat_vendors is null then 'total' else m.seat_vendors end as seat_vendors,
   case when m.session_user_daily_cnt is null then 0 else m.session_user_daily_cnt end as session_user_daily_cnt,
   case when m.session_transfer_user_daily_cnt is null then 0 else m.session_transfer_user_daily_cnt end as session_transfer_user_daily_cnt,
   case when m.session_real_user_daily_cnt is null then 0 else m.session_real_user_daily_cnt end as session_real_user_daily_cnt,
   case when m.session_user_payed_daily_cnt is null then 0 else m.session_user_payed_daily_cnt end as session_user_payed_daily_cnt,
   case when m.session_user_payed_daily_amount is null then 0 else m.session_user_payed_daily_amount end as session_user_payed_daily_amount,
   case when m.session_user_payed_daily_cnt is null then 0 else m.session_user_payed_daily_cnt end - case when n.refund_user_daily_cnt is null then 0 else n.refund_user_daily_cnt end as session_user_actual_payed_daily_cnt,
   case when m.session_user_payed_daily_amount is null then 0 else m.session_user_payed_daily_amount end - case when n.refund_daily_amount is null then 0 else n.refund_daily_amount end as session_user_actual_payed_daily_amount,
   case when m.session_user_mtd_cnt is null then 0 else m.session_user_mtd_cnt end as session_user_mtd_cnt,
   case when m.session_transfer_user_mtd_cnt is null then 0 else m.session_transfer_user_mtd_cnt end as session_transfer_user_mtd_cnt,
   case when m.session_real_user_mtd_cnt is null then 0 else m.session_real_user_mtd_cnt end as session_real_user_mtd_cnt,
   case when m.session_user_payed_mtd_cnt is null then 0 else m.session_user_payed_mtd_cnt end as session_user_payed_mtd_cnt,
   case when m.session_user_payed_mtd_amount is null then 0 else m.session_user_payed_mtd_amount end as session_user_payed_mtd_amount,
   case when m.session_user_payed_mtd_cnt is null then 0 else m.session_user_payed_mtd_cnt end  - case when n.refund_user_mtd_cnt is null then 0 else n.refund_user_mtd_cnt end  as session_user_actual_payed_daily_cnt,
   case when m.session_user_payed_mtd_amount is null then 0 else m.session_user_payed_mtd_amount end - case when n.refund_mtd_amount is null then 0 else n.refund_mtd_amount end as session_user_actual_payed_daily_amount,
   current_timestamp as insert_timestamp,
   @dt as dt
from 
(
   select
       seat_account,
       seat_name,
       seat_vendors,
       count(case when session_end_date = @dt and session_daily_seq = 1 then user_id else null end) as session_user_daily_cnt,
       count(case when session_end_date = @dt and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_daily_cnt,
       count(case when session_end_date = @dt and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_daily_cnt,
       count(case when session_end_date = @dt and place_date = @dt and place_daily_seq= 1 then user_id else null end) as session_user_payed_daily_cnt,
       sum(case when session_end_date = @dt and place_date = @dt then payed_amount else null end) as session_user_payed_daily_amount,
       count(case when session_end_month = substring(@dt,1,7) and session_daily_seq = 1 then user_id else null end) as session_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and place_month = substring(@dt,1,7) and place_daily_seq= 1 then user_id else null end) as session_user_payed_mtd_cnt,
       sum(case when session_end_month = substring(@dt,1,7) and place_month = substring(@dt,1,7) then payed_amount else null end) as session_user_payed_mtd_amount
   from
   (
       select
           a.seat_account,
           a.seat_name,
           a.seat_vendors,
           a.user_id,
           a.session_end_time,
           cast(a.session_end_time as date) as session_end_date,
           format(a.session_end_time,'yyyy-MM') as session_end_month,
           a.session_daily_seq,
           b.payed_amount,
           b.place_time,
           cast(b.place_time as date) as place_date,
           format(b.place_time,'yyyy-MM') as place_month,
           b.place_daily_seq,
           a.session_end_type
       from
       (
           select 
               --csi.seat_account,
               cs.agent_id as seat_account,
               --csi.seat_name,
               cs.agent_name as seat_name,
               'Majorel'  as seat_vendors,
               --csi.seat_vendors,
               try_cast(cs.visitor_name as bigint) as user_id,
               cs.end_time as session_end_time,
               cs.end_reason as session_end_type,
               --row_number() over(partition by csi.seat_account, cs.visitor_name, cast(cs.end_time as date) order by cs.end_time desc) session_daily_seq
               row_number() over(partition by cs.agent_id, cs.visitor_name, cast(cs.end_time as date) order by cs.end_time desc) session_daily_seq
           from 
		   (select user_id 
			   from [ODS_Transcosmos].[Public_Work_Group_User] 
			   where work_group_id='1000010337' --只取 “Majorel-售前”
			 ) us
			 
		   inner join
		   
           (
               select  
                   *
               from 
                   [STG_Transcosmos].[CS_IM_Service]
               where 
                   dt between '2021-02-09' and @dt
               and try_cast(visitor_name as bigint) is not null
               and group_name in (N'商品相关',N'售前咨询', N'美容顾问', 'HomeChat')
           ) cs
		   on us.user_id = cs.agent_id
		   
           inner join 
		   
           (select distinct service_id from STG_Transcosmos.CS_IM_Service_Detail where service_vaild = 1) cc 
          on 
            cs.service_id=cc.service_id 
       ) a
       left join
       (
           select *  from DWS_IM_Service_Sales_Order_Detail_Tmp where dt between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt  
       ) b
       on a.user_id = b.user_id
       and a.seat_account = b.seat_id
       and a.session_end_time = b.session_end_time
   ) t
   group by seat_account,seat_name,seat_vendors
   union all
   select
       null as seat_account,
       null as seat_name,
       null as seat_vendors,
       count(case when session_end_date = @dt and session_daily_seq = 1 then user_id else null end) as session_user_daily_cnt,
       count(case when session_end_date = @dt and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_daily_cnt,
       count(case when session_end_date = @dt and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_daily_cnt,
       count(case when session_end_date = @dt and place_date = @dt and place_daily_seq= 1 then user_id else null end) as session_user_payed_daily_cnt,
       sum(case when session_end_date = @dt and place_date = @dt then payed_amount else null end) as session_user_payed_daily_amount,
       count(case when session_end_month = substring(@dt,1,7) and session_daily_seq = 1 then user_id else null end) as session_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and session_end_type = 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_transfer_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and session_end_type <> 'CHANGE_AGENT_END' and session_daily_seq = 1 then user_id else null end) as session_real_user_mtd_cnt,
       count(case when session_end_month = substring(@dt,1,7) and place_month = substring(@dt,1,7) and place_daily_seq= 1 then user_id else null end) as session_user_payed_mtd_cnt,
       sum(case when session_end_month = substring(@dt,1,7) and place_month = substring(@dt,1,7) then payed_amount else null end) as session_user_payed_mtd_amount
   from
   (
       select
           a.seat_account,
           a.seat_name,
           a.seat_vendors,
           a.user_id,
           a.session_end_time,
           cast(a.session_end_time as date) as session_end_date,
           format(a.session_end_time,'yyyy-MM') as session_end_month,
           a.session_daily_seq,
           b.payed_amount,
           b.place_time,
           cast(b.place_time as date) as place_date,
           format(b.place_time,'yyyy-MM') as place_month,
           b.place_daily_seq,
           a.session_end_type
       from
       (
           select 
               --csi.seat_account,
               cs.agent_id as seat_account,
               --csi.seat_name,
               cs.agent_name as seat_name,
               'Majorel'  as seat_vendors,
               --csi.seat_vendors,
               try_cast(cs.visitor_name as bigint) as user_id,
               cs.end_time as session_end_time,
               cs.end_reason as session_end_type,
               --row_number() over(partition by csi.seat_account, cs.visitor_name, cast(cs.end_time as date) order by cs.end_time desc) session_daily_seq
               row_number() over(partition by cs.agent_id, cs.visitor_name, cast(cs.end_time as date) order by cs.end_time desc) session_daily_seq
           from
		   (select user_id 
			   from [ODS_Transcosmos].[Public_Work_Group_User] 
			   where work_group_id='1000010337' --只取 “Majorel-售前”
			 ) us
		    inner join
           (
               select  
                   *
               from 
                   [STG_Transcosmos].[CS_IM_Service]
               where 
                   dt between '2021-02-09' and @dt
               and try_cast(visitor_name as bigint) is not null
               and group_name in (N'商品相关',N'售前咨询', N'美容顾问', 'HomeChat') 
           ) cs
		   on  us.user_id = cs.agent_id
           inner join 
           (select distinct service_id from STG_Transcosmos.CS_IM_Service_Detail where service_vaild = 1) cc 
          on 
            cs.service_id=cc.service_id 
       ) a
       left join
       (
           select *  from DWS_IM_Service_Sales_Order_Detail_Tmp where dt between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt
       ) b
       on a.user_id = b.user_id
       and a.seat_account = b.seat_id
       and a.session_end_time = b.session_end_time
  ) t
) m
left join
(
   select
       seat_account,
       sum(refund_daily_amount) as refund_daily_amount,
       sum(refund_mtd_amount) as refund_mtd_amount,
       count(case when actual_payed_amount < 1 and cast(latest_refund_time as date) = @dt and refund_daily_seq = 1 then user_id else null end) as refund_user_daily_cnt,
       count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = substring(@dt,1,7) and refund_daily_seq = 1 then user_id else null end) as refund_user_mtd_cnt
   from
       refund
   where
       cast(latest_refund_time as date) between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt
   group by seat_account
   union all
   select
       null as seat_account,
       sum(refund_daily_amount) as refund_daily_amount,
       sum(refund_mtd_amount) as refund_mtd_amount,
       count(case when actual_payed_amount < 1 and cast(latest_refund_time as date) = @dt and refund_daily_seq = 1 then user_id else null end) as refund_user_daily_cnt,
       count(case when actual_payed_amount < 1 and format(latest_refund_time,'yyyy-MM') = substring(@dt,1,7) and refund_daily_seq = 1 then user_id else null end) as refund_user_mtd_cnt
   from
       refund
   where
       cast(latest_refund_time as date) between DATEADD(DD,1,EOMONTH(@dt,-1)) and @dt
) n
on case when m.seat_account is null then 'total' else m.seat_account end  = case when n.seat_account is null then 'total' else n.seat_account end
;



END
GO
