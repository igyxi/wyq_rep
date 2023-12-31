/****** Object:  StoredProcedure [DA_Tagging].[SP_T2_2_CRM]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T2_2_CRM] AS
BEGIN

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','crm start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

-- 改为先建一张空的结果表 后续计算tag 然后update进去
--ODS_CRM.FactTrans  ODS_CRM.FactTrans
--ODS_CRM.DimStore   ODS_CRM.DimStore
--ODS_CRM.DimAccount   ODS_CRM.DimAccount
--ODS_CRM.DimTrans   ODS_CRM.DimTrans
--ODS_CRM.DimProduct ODS_CRM.DimProduct

--555432条数据
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Update, trans temp Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
TRUNCATE TABLE DA_Tagging.fact_trans_temp 
-- go
-- coding线上的店铺 筛选国内的、有效的、会员的交易数据 
insert into DA_Tagging.fact_trans_temp(account_id,trans_id,product_id,sap_time,sales,store_id,omni_member_status,week_name,hour_name,category,brand)
select account_id,trans_id,t1.product_id,sap_time,sales,t1.store_id,omni_member_status,datename(weekday, sap_time) as week_name
       ,case datepart(hour,sap_time) when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
                                          when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
                                          when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
                                          when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
                                          when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' end as hour_name
	,t3.category,t3.brand
from (
    select account_id,trans_id,product_id,sap_time,sales,store_id
    from ODS_CRM.FactTrans
    where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='true'
	group by account_id,trans_id,product_id,sap_time,sales,store_id
) t1
join (
    select store_id,country_code,case when region='EBUSINESS' then 'online' else 'offline' end as omni_member_status
    from ODS_CRM.DimStore
    where country_code='CN'
) as t2 on t1.store_id = t2.store_id
left join ODS_CRM.DimProduct t3 on t1.product_id = t3.product_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Update, coding order cnt Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
-- count会员的订单次数
IF OBJECT_ID('tempdb..#member_order_cnt','U')  IS NOT NULL
drop table #member_order_cnt;
create table #member_order_cnt
(
    account_id bigint,
	order_cnt int
)
insert into #member_order_cnt(account_id,order_cnt)
select account_id,count(0) as order_cnt
from (
	select account_id,trans_id
	from ODS_CRM.FactTrans
	where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='true'
	--20210714修改
	--and convert(date, sap_time) between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1) 
    group by account_id,trans_id
) as a
group by account_id	
;


--insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
--select 'T2_2','Tagging System CRM Update, coding order category &brand Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
---- go

---- 补充商品的brand、category信息 
--update DA_Tagging.fact_trans_temp
--set category = t2.category,
--    brand = t2.brand
--from DA_Tagging.fact_trans_temp as t1
--join ODS_CRM.DimProduct t2
--on t1.product_id = t2.product_id
---- go

 -- 建空的结果表

/*  crm reslut temp table
master_id bigint,
crm_account_id bigint,
sephora_card_no nvarchar(255),
crm_status nvarchar(255),
current_card_type nvarchar(255),
crm_registered_date nvarchar(255),
first_purchase_sales float,
member_register_channel nvarchar(255),
member_tenure_days int,
recency int,
omni_new_status nvarchar(255),
registered_day_type nvarchar(255),
member_tenure_days_group nvarchar(255),
first_purchase_category nvarchar(255),
crm_prefer_category nvarchar(255),
crm_prefer_brand nvarchar(255),      
frequency int,
monetary float,
online_sales float,
offline_sales float,
hour_preference nvarchar(255),
weekday_preference nvarchar(255),
omni_member_shift nvarchar(255),
omni_member_status nvarchar(255)
*/

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Update, Update result table id insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go 

TRUNCATE TABLE DA_Tagging.crm_membership;
-- go
 -- 取id mapping中会员卡与master id的对应关系
 insert into DA_Tagging.crm_membership(master_id,crm_account_id,sephora_card_no)
  select master_id,crm_account_id,sephora_card_no from DA_Tagging.id_mapping 
          where crm_account_id<>0 and invalid_date='9999-12-31'



/* ############ ############ ############ Weekly Update Crm Tag ############ ############ ############ 
first_purchase_category	// 丝芙兰会员全渠道首单购买的大类(按销售额最高)
hour_preference			// 全渠道最常消费的时段
weekday_preference		// 全渠道最常消费的星期
*/

DECLARE @WeekNum VARCHAR(50)= datename(weekday, DATEADD(hour,8,getdate()))
if @WeekNum='Saturday'  -- Sunday
begin 
	-- 丝芙兰会员全渠道首单购买的大类(按销售额最高)   // first_purchase_category 3441327条数据
	insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
	select 'T2_2','Tagging System CRM Membership, Weekly Update [first_purchase_category] start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	
	update DA_Tagging.tagging_weekly
	set first_purchase_category = tt2.first_purchase_category
	from DA_Tagging.tagging_weekly as tt1
	join (
		select account_id, first_purchase_category
		from(
			select account_id,category as first_purchase_category
			,row_number() over(partition by account_id order by sap_time,sales desc) as rn
			from DA_Tagging.fact_trans_temp
			)t1 
		where rn=1
	)tt2
	on tt1.crm_account_id=tt2.account_id

	insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
	select 'T2_2','Tagging System CRM Membership, Weekly Update preferred {hour_preference] start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	-- go

	;with hourTemp as (
	select account_id,hour_name
		from(
			select account_id,hour_name,row_number() over(partition by account_id order by orders desc) as rn
			from(
				select account_id,hour_name,count(distinct trans_id) as orders
				from DA_Tagging.fact_trans_temp
				group by account_id,hour_name
				)t0
		)t1 where rn=1
	)
	update DA_Tagging.tagging_weekly
	set crm_hour_preference = t2.hour_name
	from DA_Tagging.tagging_weekly tt1 
	join hourTemp t2 on tt1.crm_account_id=t2.account_id

	insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
	select 'T2_2','Tagging System CRM Membership, Weekly Update preferred [weekday_preference] start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	-- go

	;with weekTemp as (
		select account_id,week_name
			from(
				select account_id,week_name
				,row_number() over(partition by account_id order by orders desc) as rn
				from(
					select account_id,week_name,count(distinct trans_id) as orders
					from DA_Tagging.fact_trans_temp
					group by account_id,week_name
					)t0
			)t1 where rn=1
	)

	--3441327条数据 5min
	update DA_Tagging.tagging_weekly
	set crm_weekday_preference = t3.week_name
	from DA_Tagging.tagging_weekly tt1 
	join weekTemp t3 on tt1.crm_account_id=t3.account_id

end




/* ############ ############ ############ Daily Update Crm Tag ############ ############ ############ 
crm_status				// 丝芙兰会员状态
omni_new_status			// 全渠道新老客状态
omni_member_status		// 全渠道会员状态
omni_member_shift		// 全渠道会员流转状态
crm_registered_date		// 丝芙兰会员注册日期
member_tenure_days		// 丝芙兰会员持有天数
member_tenure_days_group// 丝芙兰会员持有时间段
registered_day_type		// 丝芙兰会员注册日期类型
member_register_channel	// 丝芙兰会员注册渠道
current_card_type		// 会员等级
online_sales			// 会员线上消费金额
offline_sales			// 会员线下消费金额
first_purchase_sales	// 丝芙兰会员全渠道首单消费的金额
recency					// 全渠道最近一次购买距今天数
frequency				// 全渠道消费频率
monetary				// 全渠道消费金额
crm_prefer_brand		// 偏好的品牌（销售额）
crm_prefer_category		// 偏好的大类（销售额）
*/

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Membership, Update [first_purchase_category],[hour_preference],[weekday_preference] start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

IF OBJECT_ID('tempdb..#weekly_crm','U')  IS NOT NULL
drop table #weekly_crm;
create table #weekly_crm(
	master_id bigint ,
	first_purchase_category nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	crm_hour_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	crm_weekday_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #weekly_crm(master_id,first_purchase_category,crm_hour_preference,crm_weekday_preference)
select master_id, first_purchase_category
	, crm_hour_preference
	, crm_weekday_preference
	from DA_Tagging.tagging_weekly 
	where crm_account_id<>0
	and (
		first_purchase_category is not null 
		or crm_hour_preference is not null 
		or crm_weekday_preference is not null
)


update DA_Tagging.crm_membership
set first_purchase_category = tt2.first_purchase_category
	,hour_preference = tt2.crm_hour_preference
	,weekday_preference  = tt2.crm_weekday_preference 
from DA_Tagging.crm_membership as tt1
join #weekly_crm tt2
on tt1.master_id=tt2.master_id


 -- 丝芙兰会员状态                    // crm_status
 -- 会员等级                         // current_card_type
 -- 丝芙兰会员注册日期                // crm_registered_date
 -- 丝芙兰会员全渠道首单消费的金额     // first_purchase_sales
 -- 丝芙兰会员注册渠道                // member_register_channel
 -- 丝芙兰会员持有天数                // member_tenure_days
 -- 全渠道最近一次购买距今天数         // recency

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Membership, Update crm basic info start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
 -- go
 update DA_Tagging.crm_membership 
 set crm_status=t2.crm_status
     , current_card_type = t2.current_card_type
     , crm_registered_date = t2.recruitment_date
     , first_purchase_sales = t2.first_purchase_amount
     , member_register_channel = t2.member_register_channel
     , member_tenure_days = datediff(day,t2.recruitment_date,convert(date,DATEADD(hour,8,getdate()))) --38537760条
     , recency = datediff(day,last_purchase_date,convert(date,DATEADD(hour,8,getdate())))
 from DA_Tagging.crm_membership as t1
 join(
     select account_id,account_number
     ,recruitment_date ,first_purchase_amount,last_purchase_date
	 ,case when member_register_channel is not null then member_register_channel else N'线下' end as member_register_channel
     ,case when member_status='1' and is_employee<>1 then N'会员' 
      when member_status in('0','2','3','4','5') then N'非会员' else N'未知' end as crm_status
     ,case when card_type = '0' then 'Pink' when card_type= '1' then 'White' when card_type='2' then 'Black'
     when card_type='3' then 'Gold' else N'未知' end as current_card_type
     from ODS_CRM.DimAccount t1 
     left outer join DA_Tagging.crm_store t2 on t1.register_store_code=t2.register_store_code
     )t2 
 on t1.crm_account_id=t2.account_id
 -- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Membership, Update crm register info start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
update DA_Tagging.crm_membership
set omni_new_status = tt.omni_new_status
from DA_Tagging.crm_membership tt1
join(
		select crm_account_id,case when (current_card_type='White' and tt2.order_cnt=1) then N'全渠道新客' 
		when (current_card_type in ('White','Black','Gold') and tt2.order_cnt>1) then N'全渠道老客' 
		when current_card_type='Pink' then N'未购买' end as omni_new_status
		from(
			select crm_account_id,current_card_type		
			from DA_Tagging.crm_membership
	)tt1 left join #member_order_cnt tt2  on tt1.crm_account_id=tt2.account_id
)tt on tt1.crm_account_id=tt.crm_account_id
-- go

update DA_Tagging.crm_membership --37780820条数据
set registered_day_type = case when t3.daytype in ('Sunday','Saturday') then 'Weekend' when t3.daytype in ('Friday','Thursday','Wednesday','Monday','Tuesday') then 'Working Day' when t3.daytype='campaign' then 'Private Sales'
    else UPPER(SUBSTRING(t3.daytype,1,1))+LOWER(SUBSTRING(t3.daytype,2,( SELECT LEN(t3.daytype)))) end
from DA_Tagging.crm_membership t1
join DA_Tagging.daytype t3  on t1.crm_registered_date=t3.dt
-- go

update DA_Tagging.crm_membership --38537760条数据
set member_tenure_days_group =case when datediff(day,convert(date,DATEADD(hour,8,getdate())),crm_registered_date)>0 and datediff(day,convert(date,DATEADD(hour,8,getdate())),crm_registered_date)<=360 then '(0,360]'
    when datediff(day,convert(date,DATEADD(hour,8,getdate())),crm_registered_date)<=720 then '(360,720]'
    when datediff(day,convert(date,DATEADD(hour,8,getdate())),crm_registered_date)<=1080 then '(720,1080]'
    else '>1080' end
-- go



-- 偏好的大类（销售额）   // crm_prefer_category
-- 偏好的品牌（销售额）   // crm_prefer_brand --3441327条数据 7min 
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Membership, Update preferred brand start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
;with brandTemp as(
    select account_id,brand
    from(
        select account_id,brand,row_number() over(partition by account_id order by sales desc) as rn
        from(
            select account_id,brand,sum(sales) as sales from DA_Tagging.fact_trans_temp
            group by account_id,brand
        )t1 
    )t0 where rn=1
)

update DA_Tagging.crm_membership
set crm_prefer_brand = t3.brand
from DA_Tagging.crm_membership tt1 
join brandTemp t3 on tt1.crm_account_id=t3.account_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Membership, Update preferred category start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
;with categoryTemp as(
    select account_id,category
    from(
        select account_id,category,row_number() over(partition by account_id order by sales desc) as rn
        from(
            select account_id,category,sum(sales) as sales from DA_Tagging.fact_trans_temp
            group by account_id,category
        )t1
    )t0 where rn=1
)

update DA_Tagging.crm_membership
set crm_prefer_category = t2.category
from DA_Tagging.crm_membership tt1 
join categoryTemp t2 on tt1.crm_account_id=t2.account_id
-- go



-- 全渠道消费频率       // frequency
-- 全渠道消费金额       // monetary
-- 会员线上消费金额     // online_sales 
-- 会员线下消费金额     // offline_sales  --3441327条数据 3min
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Membership, Update crm sales info start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
update DA_Tagging.crm_membership
set frequency = tt2.frequency
    , monetary = tt2.monetary
    , online_sales = tt2.online_sales
    , offline_sales = tt2.offline_sales
from DA_Tagging.crm_membership tt1 
join
(
    select account_id,sum(orders) as frequency,sum(sales) as monetary
    ,max(online_sales) as online_sales,max(offline_sales) as offline_sales
    from(
        select account_id,omni_member_status,sum(sales) as sales, count(distinct trans_id) as orders
        ,case when omni_member_status='online' then sum(sales) else 0 end as online_sales
        ,case when omni_member_status='offline' then sum(sales) else 0 end as offline_sales
        from DA_Tagging.fact_trans_temp
        group by account_id,omni_member_status
        )tt1
    group by account_id
)tt2
on tt1.crm_account_id=tt2.account_id
-- go

-- 全渠道会员状态  --3441327条数据 4min
-- ,STUFF(coalesce(','+online,'')+coalesce(','+offline,'') as omni_member_status
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Membership, Update omni member status start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
 -- go
 update DA_Tagging.crm_membership
 set omni_member_status =case when tt2.online>0 and tt2.offline>0 then N'最近12个月OMNI'
         when tt2.offline>0 then N'最近12个月仅线下购买'
         when tt2.online>0 then N'最近12个月仅线上购买' 
         else N'其他' end 
 from DA_Tagging.crm_membership tt1 
 join
 (
     select account_id
     ,sum (case omni_member_status when 'online' then 1 else 0 end ) online
     ,sum (case omni_member_status when 'offline' then 1 else 0 end ) offline
     from DA_Tagging.fact_trans_temp
     where DateDiff(dd,convert(date,sap_time),DATEADD(hour,8,getdate()))<361
     group by account_id
 )tt2 
 on tt1.crm_account_id=tt2.account_id
 -- go


 -- 全渠道会员流转状态 --212329条数据 5min
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','Tagging System CRM Membership, Update omni member shift start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
 -- go
 --20210521修改成注释之后那段
 -- update DA_Tagging.crm_membership
 --set omni_member_shift = case when ttt2.omni_member_status='offline' and ttt2.next_channel='online' then 'Offline to Online'
 --    when ttt2.omni_member_status='online' and ttt2.next_channel='offline' then 'Online to Offline'
 --    else 'Not Omni' end
 --from DA_Tagging.crm_membership tt1 
 --join (
 --   select account_id,omni_member_status,next_channel
 --   from(
 --        select account_id,omni_member_status
 --        ,lead(omni_member_status,1,null) over(partition by account_id order by sap_time) as next_channel
 --        ,row_number() over(partition by account_id order by sap_time) as rn --根据最近12个月的首单判定
 --        from DA_Tagging.fact_trans_temp
 --   )t1 where rn =1
 --)ttt2 
 --on tt1.crm_account_id=ttt2.account_id
 --WHERE tt1.omni_member_status=N'最近12个月OMNI'
 --go

--20210714修改注释
--;with omni_member_shift_temp as (
--	select account_id,case when omni_member_status='offline' and next_channel='online' then 'Offline to Online'
--						   when omni_member_status='online' and next_channel='offline' then 'Online to Offline'
--					  else 'Not Omni' end as omni_member_shift --,omni_member_status,next_channel,
--	from(
--			select account_id,omni_member_status
--			,lead(omni_member_status,1,null) over(partition by account_id order by sap_time) as next_channel
--			,row_number() over(partition by account_id order by sap_time) as rn --根据最近12个月的首单判定
--			from DA_Tagging.fact_trans_temp
--	)t1 
--	where rn =1
--)

--update DA_Tagging.crm_membership
--set omni_member_shift = ttt2.omni_member_shift
--from DA_Tagging.crm_membership tt1 
--join omni_member_shift_temp ttt2 
--on tt1.crm_account_id=ttt2.account_id
--WHERE tt1.omni_member_status=N'最近12个月OMNI'
-- -- go

select account_id,omni_member_status,next_member_status
into #omni_member_status
from(
	select account_id
	,max(case when rn=1 then omni_member_status else null end) as omni_member_status
	,max(case when rn=2 then omni_member_status else null end) as next_member_status
	from( 
		select distinct account_id,omni_member_status,rn
		from(
				select account_id,omni_member_status
				--,row_number() over(partition by account_id order by sap_time) as rn --根据最近12个月的首单判定
				,dense_rank() over(partition by account_id order by sap_time,trans_id) as rn --根据最近12个月的首单判定
				from DA_Tagging.fact_trans_temp
				where DateDiff(dd,convert(date,sap_time),DATEADD(hour,8,getdate()))<361
			)t1 where rn =1 or rn=2
	)tt group by account_id
 )ttt

 update DA_Tagging.crm_membership
 set omni_member_shift = case when ttt2.omni_member_status='offline' and ttt2.next_member_status='online' then 'Offline to Online'
     when ttt2.omni_member_status='online' and ttt2.next_member_status='offline' then 'Online to Offline' else 'Not Omni' end
 from DA_Tagging.crm_membership tt1 
 join #omni_member_status ttt2 on tt1.crm_account_id=ttt2 .account_id
 WHERE tt1.omni_member_status=N'最近12个月OMNI'
 

 update DA_Tagging.crm_membership
 set crm_ab = convert(float,monetary)/(case when frequency<>0 then convert(float,frequency) else null end)


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_2','agging System CRM Update, Daily Update end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go


END
GO
