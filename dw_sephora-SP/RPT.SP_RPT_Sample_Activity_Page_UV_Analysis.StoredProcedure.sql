/****** Object:  StoredProcedure [RPT].[SP_RPT_Sample_Activity_Page_UV_Analysis]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sample_Activity_Page_UV_Analysis] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-28       litao        Initial Version
-- ========================================================================================


---获取活动开始&结束时间参数

DECLARE @start_date DATE
DECLARE @end_date DATE 

select 
    @start_date=min(cast(start_time as date)),--活动最早开始时间
    @end_date=max(cast(end_time as date))--活动最晚结束时间 
from 
    dwd.dim_gift_event 
where normal_skus is not null
and normal_skus<>''
and limit_count is not null;


truncate table [RPT].[RPT_Sample_Activity_Page_UV_Analysis];
---处理活动信息
with dim_activity_info as
(
    select
          distinct
          cast(event_id as nvarchar(521)) as activity_id,               --活动id
          event_name as activity_name,           --活动名称 
          case 
              when event_type = '1' then N'分享'
              when event_type = '0' then N'直接领取'
          end as activity_type,                   --活动类型
          start_time,                             --活动开始时间
          end_time,                               --活动结束时间
          cast(end_time as date) as end_date,     --活动开始日期
          cast(start_time as date) as start_date, --活动结束日期
          sku_code                                --活动小样sku_code 
      from
          dwd.dim_gift_event
      where normal_skus is not null
      and normal_skus<>''
      and limit_count is not null
 )
,
daily_dragon_uv as 
(
   select 
      b.activity_id,
      sum(a.dragon_uv) as dragon_uv
   from 
     rpt.rpt_sample_activity_page_uv_daily a 
   inner join dim_activity_info b 
   on 1=1
   where a.activity_id='99999'
   and a.statistics_date>=@start_date
   and a.statistics_date<=@end_date
   and a.statistics_date>=b.start_date
   and a.statistics_date<=end_date
   group by b.activity_id
)
,
daily_activity_uv as 
(
  select
      a.activity_id, 
      sum(a.activity_uv) activity_uv,
      sum(a.single_activity_uv) single_activity_uv,
      sum(a.share_uv) share_uv,
      sum(a.cart_uv) cart_uv
  from 
     rpt.rpt_sample_activity_page_uv_daily a 
   inner join dim_activity_info b 
   on a.activity_id=b.activity_id
   where a.activity_id<>'99999'
   and a.channel='ALL'
   and a.statistics_date>=@start_date
   and a.statistics_date<=@end_date
   and a.statistics_date>=b.start_date
   and a.statistics_date<=b.end_date
   group by a.activity_id
)
,
redeem_sampling as 
(
select  
   a.activity_id, 
   count(distinct a.member_card) as redeem_sampling_user
from 
  RPT.RPT_Sample_Redeemed_Order_Detail a 
  inner join dim_activity_info b 
  on a.activity_id=b.activity_id
  and a.place_date>=b.start_date
  and a.place_date<=b.end_date
group by a.activity_id
)

 
insert into [RPT].[RPT_Sample_Activity_Page_UV_Analysis]
select
    t.activity_id,
    t.activity_name,
    t.activity_type,
    t.start_time,
    t.end_time,
    t1.dragon_uv, 
    t2.activity_uv,
    t2.single_activity_uv,
    t2.share_uv,
    t2.cart_uv,
    t3.redeem_sampling_user,
    CURRENT_TIMESTAMP as insert_timestamp 
from
  dim_activity_info t
left join 
  daily_dragon_uv t1
on t.activity_id = t1.activity_id
left join 
  daily_activity_uv t2 
on t.activity_id = t2.activity_id 
left join 
  redeem_sampling t3 
on t.activity_id = t3.activity_id
;

END


 
GO
