/****** Object:  StoredProcedure [DA_Tagging].[SP_Look_Alike]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_Look_Alike] @masteridlist [nvarchar](max),@targetmembercount [int] AS
BEGIN

-------------------------------------------------------------------------------------------------------------------------
/*
1. 10000:替换为放大后的人数
2. (10133982217,10123311972,10116946693,10126666654,10129152954,10118699803,10119453486,10128726972,10135981103):替换为圈选出来的人群*/
-------------------------------------------------------------------------------------------------------------------------

if not object_id(N'Tempdb..#masteridlist') is null 
drop table #masteridlist
create table #masteridlist(user_id bigint)
insert #masteridlist
select user_id 
from(
	select value as user_id 
	from String_Split(@masteridlist , ',')
)t



-- 标签聚集度排名顺序结果表
Truncate table DA_Tagging.lookalike_meth1_seed_distribution

--IF OBJECT_ID(N'DA_Tagging.lookalike_meth1_seed_distribution',N'U')  IS NOT NULL
--DROP TABLE DA_Tagging.lookalike_meth1_seed_distribution
--CREATE TABLE DA_Tagging.lookalike_meth1_seed_distribution
--(
--    tag_name nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--    if_num int,
--    label_cnt int,
--    most_label nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--    most_label_rate float,
--    second_label nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--    second_label_rate float,
--    num_min float,
--    num_max float,
--    num_std float,
--    num_kurt float,
--    num_30q float,
--    num_70q float,
--    concentration float,
--    concentration_rank int,
--	table_name  nvarchar(255) collate Chinese_PRC_CS_AI_WS
--)



-- 数值标签字段及结果表索引
if not object_id(N'Tempdb..#T') is null
drop table #T
create table #T(id int,ColumnName nvarchar(255),ColumnTable nvarchar(255))
insert #T
select 1,'preferred_range','DA_Tagging.crm_membership2' union all
select 2,'preferred_segment','DA_Tagging.crm_membership2' union all
select 3,'preferred_brand_type','DA_Tagging.crm_membership2' union all
select 4,'member_register_channel','DA_Tagging.crm_membership' union all
select 5,'current_card_type','DA_Tagging.crm_membership' union all
select 6,'most_visited_category','DA_Tagging.engagement' union all
select 7,'most_visited_subcategory','DA_Tagging.engagement' union all
select 8,'most_visited_brand','DA_Tagging.engagement' union all
select 9,'preferred_category','DA_Tagging.online_purchase1' union all
select 10,'preferred_subcategory','DA_Tagging.online_purchase1' union all
select 11,'preferred_thirdcategory','DA_Tagging.online_purchase1' union all
select 12,'skincare_maturity','DA_Tagging.online_purchase1' union all
select 13,'makeup_maturity','DA_Tagging.online_purchase1' union all
select 14,'skincare_price_range','DA_Tagging.online_purchase1' union all
select 15,'makeup_price_range','DA_Tagging.online_purchase1' union all
select 16,'skin_type','DA_Tagging.online_purchase1' union all
select 17,'skincare_demand','DA_Tagging.online_purchase1' union all
select 18,'makeup_demand','DA_Tagging.online_purchase1' union all
select 19,'fragrance_demand','DA_Tagging.online_purchase1' union all
select 20,'preferred_brand','DA_Tagging.online_purchase2' union all
select 21,'eb_customer_status','DA_Tagging.online_user' union all
select 22,'gender','DA_Tagging.online_user' union all
select 23,'city','DA_Tagging.online_user' union all
select 24,'city_tier','DA_Tagging.online_user2' union all
select 25,'crm_prefer_brand','DA_Tagging.crm_membership' union all
select 26,'crm_prefer_category','DA_Tagging.crm_membership'


-- 循环计算数值标签统计值信息，为计算标签聚集度做数值准备
declare @s_num1 int=1
while @s_num1<=26
begin

declare @ColumnName_num1 NVARCHAR(250) = (select ColumnName from #T where id = convert(int,@s_num1))
declare @ColumnTable_num1 NVARCHAR(250) = (select ColumnTable from #T where ColumnName=@ColumnName_num1)
declare @sql_num1 nvarchar(max)

set @sql_num1 ='
		insert into DA_Tagging.lookalike_meth1_seed_distribution(tag_name,if_num,label_cnt,most_label,most_label_rate,second_label,second_label_rate,table_name)
		select max(tag_name) as tag_name
		,max(if_num) as if_num
		,max(label_cnt) as label_cnt
		,max(most_label) as most_label
		,round(max(most_label_rate),2)as most_label_rate
		,max(second_label)as second_label
		,round(max(second_label_rate),2)as second_label_rate
		,max(table_name) as table_name
		from(
			 select '''+@ColumnName_num1+''' as tag_name, 0 as if_num
			 ,max(rn) over() as label_cnt
			 ,case when rn=1 then '+@ColumnName_num1+' else null end as most_label
			 ,case when rn=1 then label_rate else null end as most_label_rate
			 ,case when rn=2 then '+@ColumnName_num1+' else null end as second_label
			 ,case when rn=2 then label_rate else null end as second_label_rate
			 ,'''+@ColumnTable_num1+''' as table_name
			 from(
				  select '+@ColumnName_num1+'
				  ,convert(float,id_cnt)/sum(id_cnt) over() as label_rate
				  ,row_number() over(order by id_cnt desc) as rn
				  from(
					   select '+@ColumnName_num1+'
					   ,count(distinct master_id) as id_cnt
					   from '+@ColumnTable_num1+'
					    where master_id in (select user_id from #masteridlist)
						and '+@ColumnName_num1+' is not null
					   group by '+@ColumnName_num1+'
					   )t1
				  )tt1
			 )ttt1
    '
exec ( @sql_num1)
set @s_num1=@s_num1+1
end


-- 建立类别标签及结果表索引
if not object_id(N'Tempdb..#T') is null drop table #T
create table #T(id int,ColumnName nvarchar(255),ColumnTable nvarchar(255))
insert #T
select 1,'purchase_monetary' , 'DA_Tagging.online_purchase2' union all
select 2,'Monetary_AB' , 'DA_Tagging.online_purchase3' union all
select 3,'Dragon_Sales_AB' , 'DA_Tagging.online_purchase3' union all
select 4,'Tmall_Sales_AB' , 'DA_Tagging.online_purchase3' union all
select 5,'JD_Sales_AB' , 'DA_Tagging.online_purchase3' union all
select 6,'campaign_related_abv' , 'DA_Tagging.online_purchase3' union all
select 7,'media_related_abv' , 'DA_Tagging.online_purchase3' union all
select 8,'offline_sales' , 'DA_Tagging.crm_membership' union all
select 9,'crm_ab' , 'DA_Tagging.crm_membership' union all
select 10,'member_tenure_days' , 'DA_Tagging.crm_membership' union all
select 11,'recency' , 'DA_Tagging.crm_membership' 



-- 循环计算类别类标签的分度峰度值
declare @s_nonum1 int=1
while @s_nonum1<=11
begin

declare @ColumnName_nonum1 NVARCHAR(250) = (select ColumnName from #T where id = convert(int,@s_nonum1))
declare @ColumnTable_nonum1 NVARCHAR(250) = (select ColumnTable from #T where ColumnName=@ColumnName_nonum1)
declare @sql_nonum1 nvarchar(max)

set @sql_nonum1 ='
	insert into DA_Tagging.lookalike_meth1_seed_distribution(tag_name,if_num,table_name,num_avg,num_min,num_max,num_std,num_30q,num_70q)
	select tag_name,if_num,table_name,num_avg,num_min,num_max,num_std,num_30q,num_70q
	from(
		select '''+@ColumnName_nonum1+''' as tag_name , 1 as if_num , '''+@ColumnTable_nonum1+''' as table_name
			 ,round( avg('+@ColumnName_nonum1+'),2) as num_avg, min('+@ColumnName_nonum1+') as num_min
			 , max('+@ColumnName_nonum1+') as num_max , stdev('+@ColumnName_nonum1+') as num_std
		from '+@ColumnTable_nonum1+'
		where '+@ColumnName_nonum1+'<>0
		and master_id in (select user_id from #masteridlist)
	)t1 cross join(
		select distinct percentile_cont(0.3) within group (order by '+@ColumnName_nonum1+') over() as num_30q
		, percentile_cont(0.7) within group (order by '+@ColumnName_nonum1+') over() as num_70q 	
		from(
			select convert(float,'+@ColumnName_nonum1+') as '+@ColumnName_nonum1+'
			from '+@ColumnTable_nonum1+'
			where master_id in (select user_id from #masteridlist)
			)t
	)tt
	
	-- 计算类别标签分布峰度值
	select sum('+@ColumnName_nonum1+') as '+@ColumnName_nonum1+'_sum
	into #'+@ColumnName_nonum1+'temp1
	from (
		select power(('+@ColumnName_nonum1+'-(select avg(convert(float,'+@ColumnName_nonum1+')) 
										 from '+@ColumnTable_nonum1+' where '+@ColumnName_nonum1+'<>0 ) ),4) as '+@ColumnName_nonum1+'
		from(
			select convert(float,'+@ColumnName_nonum1+') as '+@ColumnName_nonum1+'
			from '+@ColumnTable_nonum1+' where '+@ColumnName_nonum1+'<>0 and master_id in (select user_id from #masteridlist)
		)t
	)tt
	

	select power(stdev('+@ColumnName_nonum1+'),4) as '+@ColumnName_nonum1+'_std
	into #'+@ColumnName_nonum1+'temp2
	from(
		select convert(float,'+@ColumnName_nonum1+') as '+@ColumnName_nonum1+'
		from '+@ColumnTable_nonum1+' where '+@ColumnName_nonum1+'<>0 and master_id in (select user_id from #masteridlist)
	)tt
	

	select convert(float,(count(0)-1)) as count0
	into #'+@ColumnName_nonum1+'temp3
	from '+@ColumnTable_nonum1+' where '+@ColumnName_nonum1+'<>0 and master_id in (select user_id from #masteridlist)


	update DA_Tagging.lookalike_meth1_seed_distribution
	set num_kurt = t2.num_kurt
	from DA_Tagging.lookalike_meth1_seed_distribution t1
	cross join(
		select round( '+@ColumnName_nonum1+'_sum/'+@ColumnName_nonum1+'_std/count0 - 3,2) as num_kurt
		from #'+@ColumnName_nonum1+'temp1 cross join #'+@ColumnName_nonum1+'temp2 cross join #'+@ColumnName_nonum1+'temp3
	)t2 where tag_name='''+@ColumnName_nonum1+'''
'

exec (@sql_nonum1)
set @s_nonum1=@s_nonum1+1
end


-- 计算标签聚集度及 圈选人群的标签的聚集度排序
update DA_Tagging.lookalike_meth1_seed_distribution
set concentration=t2.concentration
from DA_Tagging.lookalike_meth1_seed_distribution t1
join(
	select tag_name ,round(0.4/(case when (num_70q-num_30q)<>0 then (num_70q-num_30q) else null end/case when (num_max-num_min)<>0 then (num_max-num_min) else null end),2) as concentration
	from DA_Tagging.lookalike_meth1_seed_distribution
)t2 on t1.tag_name=t2.tag_name


update DA_Tagging.lookalike_meth1_seed_distribution
set concentration=t2.concentration
from DA_Tagging.lookalike_meth1_seed_distribution t1
join(
	select tag_name,round(convert(float,(most_label_rate+second_label_rate))/convert(float,case when (2/convert(float,label_cnt))<>0 then (2/convert(float,label_cnt)) else null end),2) -1 as concentration
	from DA_Tagging.lookalike_meth1_seed_distribution
)t2 on t1.tag_name=t2.tag_name
where t1.concentration is null


update DA_Tagging.lookalike_meth1_seed_distribution
set concentration_rank=t2.concentration_rank
from DA_Tagging.lookalike_meth1_seed_distribution t1
join(
	select tag_name, row_number() over (partition by if_num order by concentration desc) concentration_rank
	from DA_Tagging.lookalike_meth1_seed_distribution
)t2 on t1.tag_name=t2.tag_name




-- 放大人群结果表
truncate table DA_Tagging.v_events_hour_preference


-- 补充相似用户master_id 按标签聚集度排优先级 ,取数值标签值位于圈选人群标签值的(30%，70%)范围内的用户作为放大人群
-- 且数字类型标签优先于类别标签
if not object_id(N'Tempdb..#T31') is null
drop table #T31
create table #T31(id int, tag_name nvarchar(255), table_name nvarchar(255), num_30q float, num_70q float)
insert #T31
select row_number() over (order by if_num desc,concentration_rank) id ,tag_name,table_name,num_30q ,num_70q 
from(
	select if_num,tag_name,most_label,second_label,table_name,concentration ,concentration_rank,num_30q ,num_70q
	from DA_Tagging.lookalike_meth1_seed_distribution
	where concentration_rank<=3 
)tt where if_num=1



--如果限定条件还未圈出指定数据量的人群 继续使用类别标签计算
if not object_id(N'Tempdb..#T32') is null
drop table #T32
create table #T32(id int,tag_name nvarchar(255), most_label nvarchar(255), second_label nvarchar(255),  table_name nvarchar(255))
insert #T32
select row_number() over (order by if_num desc,concentration_rank) id
,tag_name,most_label,second_label,table_name
from(
	select if_num,tag_name,most_label,second_label,table_name,concentration ,concentration_rank,num_30q ,num_70q
	from DA_Tagging.lookalike_meth1_seed_distribution
	where concentration_rank<=3 
)tt where if_num=0




--取出满足首要条件的所有用户 4172750
declare @tag_name NVARCHAR(250) set @tag_name = (select tag_name from #T31 where id=1)
declare @table_name NVARCHAR(250) set @table_name = (select table_name from #T31 where id=1)
declare @num_30q NVARCHAR(250) set @num_30q = (select num_30q from #T31 where id=1)
declare @num_70q NVARCHAR(250) set @num_70q = (select num_70q from #T31 where id=1)
exec  ('insert into DA_Tagging.v_events_hour_preference(user_id,tag_value,tag_name)
		select distinct user_id,tag_value,tag_name
		from(
			select master_id as user_id, '+@tag_name+' as tag_value, '''+@tag_name+''' as tag_name
			from '+@table_name+' where '+@tag_name+'  between '''+@num_30q+''' and '''+@num_70q+''' 
			)t1
		')


--第一次循环 删除3630627 剩下 542123
declare @s_num2 int=2
declare @cou_num int
declare @TagName_num2 NVARCHAR(250) = (select tag_name from #T31 where id = convert(int,@s_num2))
declare @TagTable_num2 NVARCHAR(250) = (select table_name from #T31 where id = convert(int,@s_num2))
declare @Tag30q_num2 NVARCHAR(250) = (select num_30q from #T31 where id = convert(int,@s_num2))
declare @Tag70q_num2 NVARCHAR(250) = (select num_70q from #T31 where id = convert(int,@s_num2))
declare @sql_num2 NVARCHAR(max)
declare @master_left_num NVARCHAR(max)
set @master_left_num = 
	'select @count=count(distinct user_id) from DA_Tagging.v_events_hour_preference
		where user_id not in (
		select master_id 
			from(
				select master_id ,'+@TagName_num2+' from '+@TagTable_num2+'
				where '+@TagName_num2+' between convert(float,'''+@Tag30q_num2+''') and convert(float,'''+@Tag70q_num2+''')
			)t
)'
exec sp_executesql @master_left_num , N'@count int out', @cou_num out


if @cou_num>=(2*@targetmembercount)
begin
	print(@cou_num)
	set @sql_num2 =
			'
			delete from DA_Tagging.v_events_hour_preference
				where user_id not in (
					select master_id 
						from(
							select master_id ,'+@TagName_num2+' from '+@TagTable_num2+'
							where '+@TagName_num2+' between convert(float,'''+@Tag30q_num2+''') and convert(float,'''+@Tag70q_num2+''')
						)t
		)
	'
exec(@sql_num2)
end


-- 第二次删除502072 剩下 40051
declare @s_num2_2 int=3
declare @cou_num_2 int
declare @TagName_num2_2 NVARCHAR(250) = (select tag_name from #T31 where id = convert(int,@s_num2_2))
declare @TagTable_num2_2 NVARCHAR(250) = (select table_name from #T31 where id = convert(int,@s_num2_2))
declare @Tag30q_num2_2 NVARCHAR(250) = (select num_30q from #T31 where id = convert(int,@s_num2_2))
declare @Tag70q_num2_2 NVARCHAR(250) = (select num_70q from #T31 where id = convert(int,@s_num2_2))
declare @sql_num2_2 NVARCHAR(max)
declare @master_left_num_2 NVARCHAR(max)
set @master_left_num_2 = 
	'select @count=count(distinct user_id) from DA_Tagging.v_events_hour_preference
		where user_id not in (
		select master_id 
			from(
				select master_id ,'+@TagName_num2_2+' from '+@TagTable_num2_2+'
				where '+@TagName_num2_2+' between convert(float,'''+@Tag30q_num2_2+''') and convert(float,'''+@Tag70q_num2_2+''')
			)t
)'
exec sp_executesql @master_left_num_2 , N'@count int out', @cou_num_2 out


if @cou_num_2>(2*@targetmembercount)
begin
	print(@cou_num_2)
	set @sql_num2_2 =
			'
			delete from DA_Tagging.v_events_hour_preference
				where user_id not in (
					select master_id 
						from(
							select master_id ,'+@TagName_num2_2+' from '+@TagTable_num2_2+'
							where '+@TagName_num2_2+' between convert(float,'''+@Tag30q_num2_2+''') and convert(float,'''+@Tag70q_num2_2+''')
						)t
		)
	'
exec(@sql_num2_2)
end


-- label 第1次删除15916 剩下24135
declare @s_nonum2_1 int=1
declare @TagName_nonum2_1 NVARCHAR(250) = (select tag_name from #T32 where id = convert(int,@s_nonum2_1))
declare @TagLabelMost_nonum2_1  NVARCHAR(250) = (select most_label from #T32 where id = convert(int,@s_nonum2_1))
declare @TagLabelSecond_nonum2_1  NVARCHAR(250) = (select second_label from #T32 where id = convert(int,@s_nonum2_1))
declare @TagTable_nonum2_1  NVARCHAR(250) = (select table_name from #T32 where id = convert(int,@s_nonum2_1))
declare @sql_nonum2_1  NVARCHAR(max)
declare @master_left_1 NVARCHAR(max)
declare @cou_1 int

set @master_left_1 = '
		select @count=count(distinct user_id) from DA_Tagging.v_events_hour_preference 
		where user_id not in (
				select master_id as user_id from '+@TagTable_nonum2_1+'
				where '+@TagName_nonum2_1+' in ('''+@TagLabelMost_nonum2_1+''', '''+@TagLabelSecond_nonum2_1+''')
				)'

exec sp_executesql @master_left_1 , N'@count int out', @cou_1 out



if @cou_1>(2*@targetmembercount)
begin
	print(@cou_1)
	set @sql_nonum2_1 =
			'delete from DA_Tagging.v_events_hour_preference
			 where user_id not in (
				select master_id as user_id from '+@TagTable_nonum2_1+'
				where '+@TagName_nonum2_1+' in ('''+ @TagLabelMost_nonum2_1+''', '''+@TagLabelSecond_nonum2_1+''')
				)'
exec(@sql_nonum2_1)
end


-- label 第2次删除0  剩下24135
declare @s_nonum2_2 int=2
declare @TagName_nonum2_2 NVARCHAR(250) = (select tag_name from #T32 where id = convert(int,@s_nonum2_2))
declare @TagLabelMost_nonum2_2  NVARCHAR(250) = (select most_label from #T32 where id = convert(int,@s_nonum2_2))
declare @TagLabelSecond_nonum2_2  NVARCHAR(250) = (select second_label from #T32 where id = convert(int,@s_nonum2_2))
declare @TagTable_nonum2_2  NVARCHAR(250) = (select table_name from #T32 where id = convert(int,@s_nonum2_2))
declare @sql_nonum2_2  NVARCHAR(max)
declare @master_left_2 NVARCHAR(max)
declare @cou_2 int

set @master_left_2 = '
		select @count=count(distinct user_id) from DA_Tagging.v_events_hour_preference 
		where user_id not in (
				select master_id as user_id from '+@TagTable_nonum2_2+'
				where '+@TagName_nonum2_2+' in ('''+@TagLabelMost_nonum2_2+''', '''+@TagLabelSecond_nonum2_2+''')
				)'

exec sp_executesql @master_left_2 , N'@count int out', @cou_2 out

if  @cou_2> (2*@targetmembercount)
begin
	print(@cou_2)
	set @sql_nonum2_2 =
			'delete from DA_Tagging.v_events_hour_preference
			 where user_id not in (
				select master_id as user_id from '+@TagTable_nonum2_2+'
				where '+@TagName_nonum2_2+' in ('''+ @TagLabelMost_nonum2_2+''', '''+@TagLabelSecond_nonum2_2+''')
				)'
exec(@sql_nonum2_2)
end


-- label 第3次删除0 剩下24135
declare @s_nonum2_3 int=3
declare @TagName_nonum2_3 NVARCHAR(250) = (select tag_name from #T32 where id = convert(int,@s_nonum2_3))
declare @TagLabelMost_nonum2_3  NVARCHAR(250) = (select most_label from #T32 where id = convert(int,@s_nonum2_3))
declare @TagLabelSecond_nonum2_3  NVARCHAR(250) = (select second_label from #T32 where id = convert(int,@s_nonum2_3))
declare @TagTable_nonum2_3  NVARCHAR(250) = (select table_name from #T32 where id = convert(int,@s_nonum2_3))
declare @sql_nonum2_3  NVARCHAR(max)
declare @master_left_3 NVARCHAR(max)
declare @cou_3 int

set @master_left_3 = '
		select @count=count(distinct user_id) from DA_Tagging.v_events_hour_preference 
		where user_id not in (
				select master_id as user_id from '+@TagTable_nonum2_3+'
				where '+@TagName_nonum2_3+' in ('''+@TagLabelMost_nonum2_3+''', '''+@TagLabelSecond_nonum2_3+''')
				)'

exec sp_executesql @master_left_3 , N'@count int out', @cou_3 out


if  @cou_3> (2*@targetmembercount)
begin
	print(@cou_3)
	set @sql_nonum2_3 =
			'delete from DA_Tagging.v_events_hour_preference
			 where user_id not in (
				select master_id as user_id from '+@TagTable_nonum2_3+'
				where '+@TagName_nonum2_3+' in ('''+ @TagLabelMost_nonum2_3+''', '''+@TagLabelSecond_nonum2_3+''')
				)'
exec(@sql_nonum2_3)
end


print('Random Generate Master_id Start...')
delete from DA_Tagging.v_events_hour_preference
where user_id not in (
	select user_id
	from(
			select distinct user_id
			,row_number() over(order by rand()) rn
			from(
				select distinct user_id
				from DA_Tagging.v_events_hour_preference
				where user_id not in (select distinct user_id from #masteridlist)
			)tt
		)t where rn<=(@targetmembercount-(select count(distinct user_id) from #masteridlist))
)

insert into DA_Tagging.v_events_hour_preference(user_id,tag_value,tag_name)
select user_id, null as tag_value, null as tag_name
from #masteridlist


END
GO
