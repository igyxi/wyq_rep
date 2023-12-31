/****** Object:  StoredProcedure [TEMP].[SP_Mid_SmartBA_Private_Domain_user]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Mid_SmartBA_Private_Domain_user] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       litao           Initial Version
-- ========================================================================================

 
truncate table Temp.Mid_SmartBA_Private_Domain_user;
insert into Temp.Mid_SmartBA_Private_Domain_user
select 
bind_date as datekey,
'SmartBA' as channel,
max(t_user_sum) as total_user_cnts,
max(t_mem_sum) as total_mem_cnts,
0 as total_group_cnts,
count(distinct case when ro=1 and status=0 then unionid end) as new_user_cnts,
count(distinct case when ro=1 and status=0 then member_card end) as new_mem_cnts,
count(distinct case when ro=1 and status in (2,1) then unionid end) as invalid_user_cnts,
count(distinct case when ro=1 and status in (2,1) then member_card end) as invalid_mem_cnts,
0 as new_group_user_cnts,
CURRENT_TIMESTAMP as insert_timestamp
from 
(
select 
  bind_date,
  status,
  unionid,
  member_card,
  ro,
  sum(case when unionid_row_rank=1 then 1 else 0 end) over(order by bind_date rows between unbounded preceding and current row) as t_user_sum,
  sum(case when member_card_row_rank=1 then 1 else 0 end) over(order by bind_date rows between unbounded preceding and current row) as t_mem_sum
from 
(
select
  a.bind_date,
  a.unionid,
  a.ba_staff_no,
  a.status,
  a.ro,
  b.member_card,
  case when a.ro=1 and a.status=0 then row_number() over(partition by a.unionid,a.ro,a.status order by a.bind_date) else null end as unionid_row_rank,
  case when a.ro=1 and a.status=0 and b.member_card is not null then row_number() over(partition by b.member_card,a.ro,a.status order by a.bind_date) else null end as member_card_row_rank
from
(
select
    format(bind_time, 'yyyy-MM-dd') as bind_date,
    unionid,
    ba_staff_no,
    status,
    row_number() over(partition by unionid,ba_staff_no order by bind_time desc) as ro
 from
dwd.fact_member_ba_bind
where bind_time is not null 
and bind_time<>'' 
--and format(bind_time, 'yyyy-MM-dd')<='2022-10-20'
) a  
left join 
(
select 
 unionid,max(member_card) as member_card
from dwd.fact_member_mnp_register
where unionid<>''
and unionid is not null
group by unionid
) b
on a.unionid=b.unionid
) c 
) d 
group by bind_date
;
END
GO
