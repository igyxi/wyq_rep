/****** Object:  StoredProcedure [TEST].[SP_RPT_Private_Domain_User_SmartBA_New2]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_Private_Domain_User_SmartBA_New2] @dt [date] AS
DECLARE @statistics_date DATE 
--月初调度传的是T-1的日期参数，这里要+1D
SET @statistics_date = (select DATEADD(day,1,@dt));

declare @starttime date = DATEADD(DAY,1,EOMONTH (DATEADD(month,-2, @statistics_date))),
        @endtime   date = EOMONTH (DATEADD(month,-1, @statistics_date))
 
while @starttime <= @endtime
begin
DELETE FROM [RPT].[RPT_Private_Domain_User_New2] where datekey=@starttime;

--SmartBA累计到当天用户数去重统计，一次跑多天逻辑
with smartba_private_domain_user as (
select
  bind_date as datekey,
  'SmartBA' as channel,
  max(t_user_sum) as total_user_cnts,
  max(t_mem_sum) as total_mem_cnts,
  null as total_group_cnts,
  count(distinct case when ro = 1 and status = 0 then unionid end) as new_user_cnts,
  count(distinct case when ro = 1 and status = 0 then member_card end) as new_mem_cnts,
  count(distinct case when ro = 1 and status in (2, 1) then unionid end) as invalid_user_cnts,
  count(distinct case when ro = 1 and status in (2, 1) then member_card end) as invalid_mem_cnts,
  null as new_group_user_cnts,
  CURRENT_TIMESTAMP as insert_timestamp
from
  (
  select
    bind_date,
    status,
    unionid,
    member_card,
    ro,
    sum(case when unionid_row_rank = 1 then 1 else 0 end) over(order by bind_date rows between unbounded preceding and current row) as t_user_sum,
    sum(case when member_card_row_rank = 1 then 1 else 0 end) over(order by bind_date rows between unbounded preceding and current row) as t_mem_sum
  from
    (
    select
      a.bind_date,
      a.unionid,
      a.ba_staff_no,
      a.status,
      a.ro,
      b.member_card,
      case when a.ro = 1 and a.status = 0 then row_number() over(partition by a.unionid,a.ro,a.status order by a.bind_date) else null end as unionid_row_rank,
      case when a.ro = 1 and a.status = 0 and b.member_card is not null then row_number() over(partition by b.member_card,a.ro,a.status order by a.bind_date) else null end as member_card_row_rank
    from
      (
      select
        format(bind_time,'yyyy-MM-dd') as bind_date,
        unionid,
        ba_staff_no,
        status,
        row_number() over(partition by unionid,ba_staff_no order by bind_time desc) as ro
      from
        dwd.fact_member_ba_bind  --用户BA绑定数据
       where bind_time is not null
       and bind_time <> ''
       and store_code not in ('DV','EB','GE','GN','HR','IT','OMR','RO','RS','South','SU','SU - HQ','West')
       and format(create_time, 'yyyy-MM-dd')<=@starttime
    
) a
    left join
(  
   select 
     unionid,
     member_card
   from 
    (select
            unionid,
            member_card,
            row_number() over(partition by unionid order by mnp_bind_mobile_time desc) as row_rank
        from
          dwd.fact_member_mnp_register --判断会员
        where unionid <> ''
          and unionid is not null
          and format(mnp_bind_mobile_time, 'yyyy-MM-dd')<=@starttime
     ) a 
     where row_rank=1
) b
   on a.unionid = b.unionid
) c 
) d
group by bind_date
)


--SmartBA用户数据写入
insert into RPT.RPT_Private_Domain_User_New2
select
  datekey,
  'SmartBA' as channel,
  case when data_type = 2 then lag_total_user_cnts else total_user_cnts end as total_user_cnts,
  case when data_type = 2 then lag_total_mem_cnts else total_mem_cnts end as total_mem_cnts,
  null as total_group_cnts,
  new_user_cnts,
  new_mem_cnts,
  invalid_user_cnts,
  invalid_mem_cnts,
  null as new_group_user_cnts,
  CURRENT_TIMESTAMP as insert_timestamp
from
  (
  select
    datekey,
    total_user_cnts,
    total_mem_cnts,
    new_user_cnts,
    new_mem_cnts,
    invalid_user_cnts,
    invalid_mem_cnts,
    data_type,
    lag(total_user_cnts) over(order by datekey) as lag_total_user_cnts,
    lag(total_mem_cnts) over(order by datekey) as lag_total_mem_cnts
  from
    (
    select
      datekey,
      sum(total_user_cnts) as total_user_cnts,
      sum(total_mem_cnts) as total_mem_cnts,
      sum(new_user_cnts) as new_user_cnts,
      sum(new_mem_cnts) as new_mem_cnts,
      sum(invalid_user_cnts) as invalid_user_cnts,
      sum(invalid_mem_cnts) as invalid_mem_cnts,
      sum(data_type) as data_type
    from
      (
       select
          datekey as datekey,
          --total_user_cnts,
          lag(total_user_cnts) over(order by datekey) as total_user_cnts,
          --total_mem_cnts,
          lag(total_mem_cnts) over(order by datekey) as total_mem_cnts,
          new_user_cnts,
          new_mem_cnts,
          invalid_user_cnts,
          invalid_mem_cnts,
          1 as data_type
        from
          smartba_private_domain_user
        where datekey >= '2021-12-31'
       union all
        select
          date_str as datekey,
          0 as total_user_cnts,
          0 as total_mem_cnts,
          0 as new_user_cnts,
          0 as new_mem_cnts,
          0 as invalid_user_cnts,
          0 as invalid_mem_cnts,
          2 as data_type
        from
          dwd.dim_calendar --补充绑定数据缺失的日期
        --where date_str >= '2022-01-01'
        --  and date_str <= '2022-10-26'
        where date_str=@starttime
        ) b
    where datekey>='2022-01-01' --数据开始日期2022-01-01
    group by datekey
     ) c 
) d
where datekey=@starttime
;

SELECT 'RPT_Private_Domain_User_New2';
SELECT @starttime;
set @starttime = dateadd(day, 1, @starttime);
end
GO
