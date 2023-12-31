/****** Object:  StoredProcedure [DA_Tagging].[SP_T1_ID_Mapping]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T1_ID_Mapping] @datadate [date] AS
BEGIN
/**
20210630,新增字段 if_valid ( case when invalid_date = '9999-12-31 then 1 else 0 end )
				  phone_num ( 匹配规则待定 )
20210715,新增[STG_User].[User_Third_Party_Store]数据源 1. type = 'TMALL', 根据user_id 和 sephora_user_id 匹配, 对于所有能匹配上的user_id, 用union_id更新 tmall_member_id
													   2. type = 'JD', 根据user_id 和 sephora_user_id 匹配, union_id赋值给新增列 jd_union_id
**/
/******************************************** whole step1 id mapping update ***************************************************/

--print( CONVERT(varchar(100), DATEADD(hour,8,getdate()), 21) + ' id mapping update start...')
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id mapping update start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
/** ID Mapping Update **/

-- id_mapping_update_sensorid_filter, Sensor Id Filter Start...

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','selected_sensor_users_newdata,v_Users Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].selected_sensor_users_newdata
-- go

insert into [DW_Sephora].[DA_Tagging].selected_sensor_users_newdata
select id as sensor_user_id
,case second_id  when 'null' then null  when 'NULL' then null  when '' then null  else second_id end as sephora_user_id
from DW_Sephora.[STG_Sensor].[V_Users] 
where isnumeric(second_id) = 1
	----每天取v_users表新增数据，时间需要按照实际情况更改
	and convert(date,DATEADD(S,do_update_time/1000 + 8 * 3600,'1970-01-01 00:00:00')) = @datadate
group by id,second_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','selected_sensor_users_newdata,V_Events Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
--20210521修改成注释之后那段
--insert into [DW_Sephora].[DA_Tagging].selected_sensor_users_newdata
--select t1.sensor_user_id,t1.sephora_user_id
--from (
--	select user_id as sensor_user_id,null as sephora_user_id
--	from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
--	where ss_os in ('iOS','Android')
--		    and (ss_title =N'活动页面' or event ='viewCommodityDetail')
--			----每天取v_events表新增数据，时间需要按照实际情况更改
--            and dt = @datadate   
--	group by user_id
--) as t1
--left join [DW_Sephora].[DA_Tagging].selected_sensor_users_newdata as t2
--on t1.sensor_user_id = t2.sensor_user_id
--where t2.sensor_user_id is null
---- go

insert into [DW_Sephora].[DA_Tagging].selected_sensor_users_newdata(sensor_user_id)
select t1.sensor_user_id
from (
	select user_id as sensor_user_id
	from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
	where ss_os in ('iOS','Android')
		    and (ss_title =N'活动页面' or event ='viewCommodityDetail')
			----每天取v_events表新增数据，时间需要按照实际情况更改
            and dt = @datadate   
	group by user_id
) as t1
left join [DW_Sephora].[DA_Tagging].selected_sensor_users_newdata as t2
on t1.sensor_user_id = t2.sensor_user_id
where t2.sensor_user_id is null
-- go


-- DW_Sephora.[STG_OMS].[V_Sales_Order]  (tmall_member_id/jd_member_id)

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','oms_v_sales_order_newdata Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].oms_v_sales_order_newdata
-- go

insert into [DW_Sephora].[DA_Tagging].oms_v_sales_order_newdata
select distinct case store_id  when 'null' then null when '' then null  else store_id end as store_id
,case member_id  when 'null' then null when '' then null  else member_id end as member_id
,case member_card when 'null' then null when '' then null  else member_card end as member_card
,payment_time
from DW_Sephora.[STG_OMS].[V_Sales_Order]
----每天取v_sales_order表新增数据，时间需要按照实际情况更改
where convert(date,payment_time) = @datadate
-- go


-- DW_Sephora.[STG_Sensor].[V_Events]

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','dwd_v_events_newdata Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].dwd_v_events_newdata
-- go

insert into [DW_Sephora].[DA_Tagging].dwd_v_events_newdata
select user_id,distinct_id,ss_device_id,ss_os,dt,time
from (
	select distinct user_id
	,case distinct_id when 'null' then null when '' then null  else distinct_id end as distinct_id
	,case ss_device_id when 'null' then null when '' then null  else ss_device_id end as ss_device_id
	,case ss_os  when 'null' then null when '' then null  else ss_os  end as ss_os
	,dt,time
	from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
	----每天取v_events表新增数据，时间需要按照实际情况更改
	where dt = @datadate
)  as a
----join selected_sensor_users_newdata 表，取有过登录的 或 手机端有过浏览活动页面的 sensor_user_id
join [DW_Sephora].[DA_Tagging].selected_sensor_users_newdata as b
on a.user_id = b.sensor_user_id
-- go


-- id_mapping_update_memberid, Member Id - Sephora User Id
----jd and tm id 拓宽全量

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping_tm_jd,JD only Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].id_mapping_tm_jd
-- go

insert into [DW_Sephora].[DA_Tagging].id_mapping_tm_jd(jd_member_id,sephora_card_no)
select jd_member_id,sephora_card_no
from(
	select member_id as jd_member_id, 
	--case when regexp_replace(member_card,'JD','') rlike '^\\d+$' then regexp_replace(member_card,'JD','')  else null end as sephora_card_no,
	case when isnumeric(replace(member_card,'JD','')) = 1 then replace(member_card,'JD','')  else null end as sephora_card_no,
	row_number() over(partition by member_id order by payment_time desc) as rn
	from [DW_Sephora].[DA_Tagging].oms_v_sales_order_newdata
	where store_id in ('JD001','JD002')
)t1 
where rn=1 and jd_member_id is not null and sephora_card_no is null
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping_tm_jd,TM only Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].id_mapping_tm_jd(tmall_member_id,sephora_card_no)
select tmall_member_id,sephora_card_no
from(
    select member_id as tmall_member_id,
    --case when member_card rlike '^\\d+$' then member_card  else null end as sephora_card_no ,
    case when isnumeric(member_card) = 1 then member_card  else null end as sephora_card_no ,
    row_number() over(partition by member_id order by payment_time desc) as rn
    from [DW_Sephora].[DA_Tagging].oms_v_sales_order_newdata
    where store_id in ('TMALL001','TMALL002')
)t1 
where rn=1 and tmall_member_id is not null and sephora_card_no is null
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping_tm_jd,full join Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].id_mapping_tm_jd
select tt1.jd_member_id,tt2.tmall_member_id,
case when tt1.sephora_card_no is null then tt2.sephora_card_no else tt1.sephora_card_no end as sephora_card_no
from (
    select jd_member_id,sephora_card_no
    from(
        select member_id as jd_member_id, 
        --case when regexp_replace(member_card,'JD','') rlike '^\\d+$' then regexp_replace(member_card,'JD','')  else null end as sephora_card_no,
        case when isnumeric(replace(member_card,'JD','')) = 1 then replace(member_card,'JD','')  else null end as sephora_card_no,
        row_number() over(partition by member_id order by payment_time desc) as rn
        from [DW_Sephora].[DA_Tagging].oms_v_sales_order_newdata
        where store_id in ('JD001','JD002')
    )t1 
    where rn=1 and jd_member_id is not null and sephora_card_no is not null
)tt1 full join
(
    select tmall_member_id,sephora_card_no
    from(
        select member_id as tmall_member_id,
        --case when member_card rlike '^\\d+$' then member_card  else null end as sephora_card_no ,
        case when isnumeric(member_card) = 1 then member_card  else null end as sephora_card_no ,
        row_number() over(partition by member_id order by payment_time desc) as rn
        from[DW_Sephora].[DA_Tagging].oms_v_sales_order_newdata
        where store_id in ('TMALL001','TMALL002')
    )t1 
    where rn=1 and tmall_member_id is not null and sephora_card_no is not null
)tt2 on tt1.sephora_card_no=tt2.sephora_card_no
-- go



-- 小红书 id 拓宽全量(这段加在[DW_Sephora].[DA_Tagging].result_temp之前，最好是在处理[DW_Sephora].[DA_Tagging].id_mapping_tm_jd之后，连贯一点)

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping_red Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].id_mapping_red
-- go

insert into [DW_Sephora].[DA_Tagging].id_mapping_red
select red_member_id
from(
    select member_id as red_member_id
    from [DW_Sephora].[DA_Tagging].oms_v_sales_order_newdata
    where store_id = 'REDBOOK001' 
    group by member_id
)t1
where red_member_id is not null
-- go


-- id_mapping_update_deviceid, Sensor Id - Device Id
----sephora and sensor id 拓宽全量

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping_sephora_sensor,insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
-- go

insert into [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
select distinct case when tt2.user_id is not null then tt2.user_id else tt1.sephora_user_id end as sephora_user_id
,tt1.sensor_user_id as sensor_id
,tt2.card_no
,null as device_id_IDFA,null as device_id_IMEI,null as device_id_others
from [DW_Sephora].[DA_Tagging].selected_sensor_users_newdata tt1 
full join (
	select * 
	from (
		select distinct user_id
		,case card_no  when 'null' then null when '' then null  else card_no end as card_no
		from DW_Sephora.[STG_User].[V_User_Profile]
		----每天取v_user_profile表新增数据，时间需要按照实际情况更改
		where convert(date,last_update) = @datadate
	) temp
	where user_id<>0
) tt2 
on tt1.sephora_user_id=tt2.user_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping_sephora_sensor,device_id Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
set device_id_IDFA = tt3.device_id_IDFA,
	device_id_IMEI = tt3.device_id_IMEI,
	device_id_others = tt3.device_id_others
from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor as t
join (
    select user_id 
    ,case when ss_os in ('iOS','ios') then ss_device_id else null end as device_id_IDFA
    ,case when ss_os in ('Android','android') then ss_device_id else null end as device_id_IMEI
    ,case when ss_os not in ('iOS','ios','Android','android') then ss_device_id else null end as device_id_others
    from (
        select user_id,ss_device_id,ss_os
        ,row_number() over(partition by user_id order by time desc) as rn
        from [DW_Sephora].[DA_Tagging].dwd_v_events_newdata )t1
	where rn=1
) as tt3
on t.sensor_id=tt3.user_id
-- go


-- id_mapping_update_result_temp, Result Temp

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_sephora_sensor step1 Start insert',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].result_temp
-- go

-----update id_mapping_sephora_sensor new data

--20210521修改成注释之后那段（拆分成两段）
--insert into [DW_Sephora].[DA_Tagging].result_temp 
--select t.master_id,t.sephora_user_id,t.sensor_id
--,t.tmall_member_id,t.jd_member_id,t.red_member_id
--,case when s.card_no is not null then s.card_no else t.sephora_card_no end as sephora_card_no--cardno需要更新为最新状态
--,t.crm_account_id,t.wechat_union_id,t.wechat_open_id
--,case when s.device_id_IDFA is not null then s.device_id_IDFA else t.device_id_IDFA end as device_id_IDFA
--,case when s.device_id_IMEI is not null then s.device_id_IMEI else t.device_id_IMEI end as device_id_IMEI
--,case when s.device_id_others is not null then s.device_id_others else t.device_id_others end as device_id_others
--from ( 
--    select *
--    from [DW_Sephora].[DA_Tagging].id_mapping
--    where invalid_date = '9999-12-31'
--)t
--left join (
--    select *
--    from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
--    where sephora_user_id is not null and sensor_id is not null
--) s
--on t.sephora_user_id=s.sephora_user_id and t.sensor_id = s.sensor_id
---- go

insert into [DW_Sephora].[DA_Tagging].result_temp
select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id,sephora_card_no,crm_account_id
	  ,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others,update_date
from [DW_Sephora].[DA_Tagging].id_mapping
where invalid_date = '9999-12-31'
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_sephora_sensor step1 Start update',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].result_temp
set sephora_card_no = case when s.card_no is not null then s.card_no else t.sephora_card_no end,  --cardno需要更新为最新状态
	device_id_IDFA = case when s.device_id_IDFA is not null then s.device_id_IDFA else t.device_id_IDFA end,
	device_id_IMEI = case when s.device_id_IMEI is not null then s.device_id_IMEI else t.device_id_IMEI end,
	device_id_others = case when s.device_id_others is not null then s.device_id_others else t.device_id_others end
from [DW_Sephora].[DA_Tagging].result_temp as t
join (
    select *
    from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
    where sephora_user_id is not null and sensor_id is not null
) s
on t.sephora_user_id=s.sephora_user_id and t.sensor_id = s.sensor_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_sephora_sensor step1.1 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].result_temp(sephora_user_id,sensor_id,sephora_card_no,device_id_IDFA,device_id_IMEI,device_id_others,update_date)
select s.sephora_user_id,s.sensor_id,s.card_no,s.device_id_IDFA,s.device_id_IMEI,s.device_id_others,convert(date,DATEADD(hour,8,getdate())) as update_date
from ( 
    select *
    from [DW_Sephora].[DA_Tagging].result_temp
    where sephora_user_id is not null and sensor_id is not null
)t
right join (
    select *
    from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
    where sephora_user_id is not null and sensor_id is not null
) s
on t.sephora_user_id=s.sephora_user_id and t.sensor_id = s.sensor_id
where t.sephora_user_id is null
-- go

--insert into [DW_Sephora].[DA_Tagging].result_temp 
--select t.master_id
--,case when t.sephora_user_id is not null then t.sephora_user_id else s.sephora_user_id end as sephora_user_id
--,case when t.sensor_id is not null then t.sensor_id else s.sensor_id end as sensor_id
--,t.tmall_member_id,t.jd_member_id,t.red_member_id
--,case when s.card_no is not null then s.card_no else t.sephora_card_no end as sephora_card_no--cardno需要更新为最新状态
--,t.crm_account_id,t.wechat_union_id,t.wechat_open_id
--,case when s.device_id_IDFA is not null then s.device_id_IDFA else t.device_id_IDFA end as device_id_IDFA
--,case when s.device_id_IMEI is not null then s.device_id_IMEI else t.device_id_IMEI end as device_id_IMEI
--,case when s.device_id_others is not null then s.device_id_others else t.device_id_others end as device_id_others
--from ( 
--    select *
--    from [DW_Sephora].[DA_Tagging].id_mapping
--    where invalid_date = '9999-12-31'
--)t
--full join (
--    select *
--    from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
--    where sephora_user_id is not null and sensor_id is not null
--) s
--on t.sephora_user_id=s.sephora_user_id and t.sensor_id = s.sensor_id
---- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_sephora_sensor step2 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].result_temp
set sephora_card_no = case when s.card_no is not null then s.card_no else t.sephora_card_no end  --cardno需要更新为最新状态
	,device_id_IDFA = case when s.device_id_IDFA is not null then s.device_id_IDFA else t.device_id_IDFA end  
	,device_id_IMEI = case when s.device_id_IMEI is not null then s.device_id_IMEI else t.device_id_IMEI end  
	,device_id_others = case when s.device_id_others is not null then s.device_id_others else t.device_id_others end  
from [DW_Sephora].[DA_Tagging].result_temp as t
join (
    select *
    from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
    where sephora_user_id is not null and sensor_id is null
) as s
on t.sephora_user_id = s.sephora_user_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_sephora_sensor step3 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].result_temp(sephora_user_id,sephora_card_no,device_id_IDFA,device_id_IMEI,device_id_others,update_date)
select s.sephora_user_id,s.card_no,s.device_id_IDFA,s.device_id_IMEI,s.device_id_others,convert(date,DATEADD(hour,8,getdate())) as update_date
from [DW_Sephora].[DA_Tagging].result_temp as t
right join (
    select *
    from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
    where sephora_user_id is not null and sensor_id is null
) as s
on t.sephora_user_id = s.sephora_user_id
where t.sephora_user_id is null
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_sephora_sensor step4 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].result_temp
set device_id_IDFA = case when s.device_id_IDFA is not null then s.device_id_IDFA else t.device_id_IDFA end  
	,device_id_IMEI = case when s.device_id_IMEI is not null then s.device_id_IMEI else t.device_id_IMEI end  
	,device_id_others = case when s.device_id_others is not null then s.device_id_others else t.device_id_others end  
from [DW_Sephora].[DA_Tagging].result_temp as t
join (
    select *
    from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
    where sephora_user_id is null and sensor_id is not null
) as s
on t.sensor_id = s.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_sephora_sensor step5 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].result_temp(sensor_id,device_id_IDFA,device_id_IMEI,device_id_others,update_date)
select s.sensor_id,s.device_id_IDFA,s.device_id_IMEI,s.device_id_others,convert(date,DATEADD(hour,8,getdate())) as update_date
from [DW_Sephora].[DA_Tagging].result_temp as t
right join (
    select *
    from [DW_Sephora].[DA_Tagging].id_mapping_sephora_sensor
    where sephora_user_id is null and sensor_id is not null
) as s
on t.sensor_id = s.sensor_id
where t.sensor_id is null
-- go


-----update id_mapping_tm_jd new data,jd and tm 账号可能换cardno,需要纪录最新组合
-----1、id_mapping_tm_jd表jd和tm id都不为null
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_tm_jd step1 update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].result_temp
set sephora_card_no = case when s.sephora_card_no is not null then s.sephora_card_no else t.sephora_card_no end  
from [DW_Sephora].[DA_Tagging].result_temp as t
join (
    select *
    from [DW_Sephora].[DA_Tagging].id_mapping_tm_jd 
    where jd_member_id is not null and tmall_member_id is not null
) as s
on t.tmall_member_id=s.tmall_member_id and t.jd_member_id=s.jd_member_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_tm_jd step1 insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].result_temp(tmall_member_id,jd_member_id,sephora_card_no,update_date)
select s.tmall_member_id,s.jd_member_id,s.sephora_card_no,convert(date,DATEADD(hour,8,getdate())) as update_date
from [DW_Sephora].[DA_Tagging].result_temp as t
right join (
    select *
    from [DW_Sephora].[DA_Tagging].id_mapping_tm_jd 
    where jd_member_id is not null and tmall_member_id is not null
) as s
on t.tmall_member_id=s.tmall_member_id and t.jd_member_id=s.jd_member_id
where t.tmall_member_id is null
-- go


-----2、id_mapping_tm_jd表jd is not null和tm id is null
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_tm_jd step2 update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].result_temp
set sephora_card_no = case when s.sephora_card_no is not null then s.sephora_card_no else t.sephora_card_no end  
from [DW_Sephora].[DA_Tagging].result_temp as t
join (
    select distinct jd_member_id,sephora_card_no
    from [DW_Sephora].[DA_Tagging].id_mapping_tm_jd 
    where jd_member_id is not null and tmall_member_id is null
) as s
on t.jd_member_id = s.jd_member_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_tm_jd step2 insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].result_temp(jd_member_id,sephora_card_no,update_date)
select s.jd_member_id,s.sephora_card_no,convert(date,DATEADD(hour,8,getdate())) as update_date
from [DW_Sephora].[DA_Tagging].result_temp as t
right join (
    select distinct jd_member_id,sephora_card_no
    from [DW_Sephora].[DA_Tagging].id_mapping_tm_jd 
    where jd_member_id is not null and tmall_member_id is null
) as s
on t.jd_member_id = s.jd_member_id
where t.jd_member_id is null
-- go


-----3、id_mapping_tm_jd表jd is null和tm id is not null
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_tm_jd step3 update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].result_temp
set sephora_card_no = case when s.sephora_card_no is not null then s.sephora_card_no else t.sephora_card_no end  
from [DW_Sephora].[DA_Tagging].result_temp as t
join (
    select distinct tmall_member_id,sephora_card_no
    from [DW_Sephora].[DA_Tagging].id_mapping_tm_jd 
    where jd_member_id is null and tmall_member_id is not null
) as s
on t.tmall_member_id = s.tmall_member_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_tm_jd step3 insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].result_temp(tmall_member_id,sephora_card_no,update_date)
select s.tmall_member_id,s.sephora_card_no,convert(date,DATEADD(hour,8,getdate())) as update_date
from [DW_Sephora].[DA_Tagging].result_temp as t
right join (
    select distinct tmall_member_id,sephora_card_no
    from [DW_Sephora].[DA_Tagging].id_mapping_tm_jd 
    where jd_member_id is null and tmall_member_id is not null
) as s
on t.tmall_member_id = s.tmall_member_id
where t.tmall_member_id is null
-- go


-----update id_mapping_red new data ，小红书只有member_id，只需要判断是否已存在
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,id_mapping_tm_jd step4 insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].result_temp(red_member_id,update_date)
select s.red_member_id,convert(date,DATEADD(hour,8,getdate())) as update_date
from [DW_Sephora].[DA_Tagging].result_temp as t
right join [DW_Sephora].[DA_Tagging].id_mapping_red as s
on t.red_member_id = s.red_member_id
where t.red_member_id is null
-- go


-----update crm_v_dim_account_newdata and oms_v_wechat_user_info_newdata 最新id
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,DimAccount_temp Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

IF OBJECT_ID(N'tempdb..#DimAccount_temp', N'U') IS NOT NULL 
DROP TABLE #DimAccount_temp
-- go

create table #DimAccount_temp(account_id int,account_number nvarchar(255) collate Chinese_PRC_CS_AI_WS)
-- go

insert into #DimAccount_temp
select account_id,account_number
from (
	select account_id,case account_number when 'null' then null when '' then null  else account_number end as account_number
	from DW_Sephora.ODS_CRM.DimAccount
	where account_id<>0
	----每天取v_dim_account表新增数据，时间需要按照实际情况更改
	and convert(date,process_time) = @datadate
) temp
where account_id is not null
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,crm_account_id update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].result_temp
set crm_account_id = s.account_id
from [DW_Sephora].[DA_Tagging].result_temp as t
join #DimAccount_temp as s
on t.sephora_card_no = s.account_number
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,V_Wechat_User_Info update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].result_temp
set wechat_union_id = s.union_id
	,wechat_open_id = s.open_id
from [DW_Sephora].[DA_Tagging].result_temp as t
join (
	select user_id,open_id,union_id
	from (
		select distinct user_id,case open_id when 'null' then null when '' then null  else open_id end as open_id
		,case union_id when 'null' then null when '' then null  else union_id end as union_id
		from DW_Sephora.[DW_WechatCenter].[V_Wechat_User_Info]
		----每天取v_wechat_user_info表新增数据，时间需要按照实际情况更改
		where convert(date,last_access_time) = @datadate
	) as a
	where user_id is not null and (open_id is not null or union_id is not null)
) as s
on t.sephora_user_id = s.user_id
-- go


-----1/同一个sephora_card_no(不为null的数据)，使用非空填充空值 sephora_user_id/sensor_id/tmall_member_id/jd_member_id
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','result_temp,final update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update statistics [DA_Tagging].result_temp	--Add by Joey Shen 20210609

update [DW_Sephora].[DA_Tagging].result_temp
set sephora_user_id = s.sephora_user_id
	,sensor_id = s.sensor_id
	,tmall_member_id = s.tmall_member_id
	,jd_member_id = s.jd_member_id
from [DW_Sephora].[DA_Tagging].result_temp as t
join (
	select  master_id,sephora_card_no
	--,COALESCE(sephora_user_id,First_VALUE(sephora_user_id) over(partition by sephora_card_no order by sephora_user_id desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) sephora_user_id
	--,COALESCE(sensor_id,First_VALUE(sensor_id) over(partition by sephora_card_no order by sensor_id desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) sensor_id
	--,COALESCE(tmall_member_id,First_VALUE(tmall_member_id) over(partition by sephora_card_no order by tmall_member_id desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) tmall_member_id
	--,COALESCE(jd_member_id,First_VALUE(jd_member_id) over(partition by sephora_card_no order by jd_member_id desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) jd_member_id
	--from [DW_Sephora].[DA_Tagging].result_temp 
	--where sephora_card_no is not null	
	--20211223，修改为以下方案
	,First_VALUE(sephora_user_id) over(partition by sephora_card_no order by sephora_user_id_ranking desc,update_date desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) sephora_user_id
	,First_VALUE(sensor_id) over(partition by sephora_card_no order by sensor_id_ranking desc,update_date desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) sensor_id
	,First_VALUE(tmall_member_id) over(partition by sephora_card_no order by tmall_member_id_ranking desc,update_date desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) tmall_member_id
	,First_VALUE(jd_member_id) over(partition by sephora_card_no order by jd_member_id_ranking desc,update_date desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) jd_member_id
	from (
			select *,case when sephora_user_id is null then 0 else 1 end as sephora_user_id_ranking
					,case when sensor_id is null then 0 else 1 end as sensor_id_ranking
					,case when tmall_member_id is null then 0 else 1 end as tmall_member_id_ranking
					,case when jd_member_id is null then 0 else 1 end as jd_member_id_ranking
			from [DW_Sephora].[DA_Tagging].result_temp
			where sephora_card_no is not null
		) as a
) as s
on t.master_id = s.master_id
-- go


-----2/根据sephora_user_id/sensor_id/tmall_member_id/jd_member_id,red_member_id 去重,同一组保留masterid最小的一条纪录
--   delete from t
----select *
--   from(
--       select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
--       ,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others
--       ,ROW_NUMBER()over(partition by sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
--                         order by case when master_id is not null then 0 else 1 end,master_id) as ranking
--       from [DW_Sephora].[DA_Tagging].result_temp 
--   )t
--   where ranking <> 1

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','#result_temp Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

IF OBJECT_ID(N'tempdb..#result_temp', N'U') IS NOT NULL 
DROP TABLE #result_temp
-- go

create table #result_temp
(
	master_id bigint,
	sephora_user_id bigint,
	sensor_id bigint,
	tmall_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	jd_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	red_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	sephora_card_no nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	crm_account_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	wechat_union_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	wechat_open_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	device_id_IDFA nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	device_id_IMEI nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	device_id_others nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	jd_union_id nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
-- go

----20210615修改为后面那段
--insert into #result_temp 
--select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others
--from(
--	select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
--	,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others
--	,ROW_NUMBER()over(partition by sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
--						order by case when master_id is not null then 0 else 1 end,master_id) as ranking
--	from [DW_Sephora].[DA_Tagging].result_temp 
--)t
--where ranking = 1

;with result_temp_MD5 as (
	select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
	,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others
	,concat(isnull(convert(nvarchar(255),sephora_user_id),''),isnull(convert(nvarchar(255),sensor_id),''),isnull(tmall_member_id,''),isnull(jd_member_id,''),isnull(red_member_id,'')) as MDid
	from [DW_Sephora].[DA_Tagging].result_temp
)

insert into #result_temp(master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others)
select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others
from(
	select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
	,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others
	,ROW_NUMBER()over(partition by MDid
						order by case when master_id is not null then 0 else 1 end,master_id) as ranking
	from result_temp_MD5 
)t
where ranking = 1
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','#result_temp jd_union_id Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
--go
--20210715新增逻辑
update #result_temp
set tmall_member_id = b.union_id
from #result_temp as a
join (
	select user_id,union_id
	from [DW_Sephora].[STG_User].[User_Third_Party_Store] as a
	where convert(date,bind_time) = @datadate
	      and type = 'TMALL'
	group by user_id,union_id
) as b
on a.sephora_user_id = b.user_id
--go

update #result_temp
set jd_union_id = b.union_id
from #result_temp as a
join (
	select user_id,union_id
	from [DW_Sephora].[STG_User].[User_Third_Party_Store] as a
	where convert(date,bind_time) = @datadate
	      and type = 'JD'
	group by user_id,union_id
) as b
on a.sephora_user_id = b.user_id
--go
	

-- id_mapping_update_resave, Re-save Id Mapping

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping_resave Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].id_mapping_resave
-- go

insert into [DW_Sephora].[DA_Tagging].id_mapping_resave
select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id,sephora_card_no,crm_account_id,wechat_union_id 
    ,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others,update_date,invalid_date,if_valid,jd_union_id
from [DW_Sephora].[DA_Tagging].id_mapping
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','cardno_sephoraid_mapping_resave Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping_resave
-- go

insert into [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping_resave
select master_id, sephora_card_no,sephora_user_id, last_update, dt
from  [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping
-- go


-- id_mapping_update_result, Result Start...')
-----id_mapping
-----使用[DW_Sephora].[DA_Tagging].result_temp 最新记录覆盖[DW_Sephora].[DA_Tagging].id_mapping,masterid为null的数据，使用row_number填充

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping,existed Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go	
truncate table [DW_Sephora].[DA_Tagging].id_mapping
-- go

insert into [DW_Sephora].[DA_Tagging].id_mapping
select t2.master_id,t2.sephora_user_id,t2.sensor_id,t2.tmall_member_id,t2.jd_member_id,t2.red_member_id
    ,t2.sephora_card_no,t2.crm_account_id,t2.wechat_union_id,t2.wechat_open_id,t2.device_id_IDFA,t2.device_id_IMEI,t2.device_id_others
    ,case when t1.compare_column_old = t2.compare_column_new then t1.update_date_old else t2.update_date_new end as update_date
    ,t1.invalid_date,1 as if_valid,t2.jd_union_id
from (
        select master_id,update_date as update_date_old,invalid_date
        ,concat(isnull(convert(nvarchar(255),sephora_user_id),''),isnull(convert(nvarchar(255),sensor_id),''),isnull(tmall_member_id,''),isnull(jd_member_id,''),isnull(red_member_id,''),isnull(sephora_card_no,''),isnull(crm_account_id,''),isnull(wechat_union_id,''),isnull(wechat_open_id,''),isnull(device_id_IDFA,''),isnull(device_id_IMEI,''),isnull(device_id_others,''),isnull(jd_union_id,'')) as compare_column_old
        from [DW_Sephora].[DA_Tagging].id_mapping_resave 
)as t1
join (
        select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
        ,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others,convert(date,DATEADD(hour,8,getdate())) as update_date_new,jd_union_id
        ,concat(isnull(convert(nvarchar(255),sephora_user_id),''),isnull(convert(nvarchar(255),sensor_id),''),isnull(tmall_member_id,''),isnull(jd_member_id,''),isnull(red_member_id,''),isnull(sephora_card_no,''),isnull(crm_account_id,''),isnull(wechat_union_id,''),isnull(wechat_open_id,''),isnull(device_id_IDFA,''),isnull(device_id_IMEI,''),isnull(device_id_others,''),isnull(jd_union_id,'')) as compare_column_new
        from #result_temp
        where master_id is not null
) as t2
on t1.master_id = t2.master_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping,added Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go	

declare @maxid bigint = (select max(master_id) from [DW_Sephora].[DA_Tagging].id_mapping_resave)

insert into [DW_Sephora].[DA_Tagging].id_mapping
select @maxid + ranking as master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others,update_date,cast('9999-12-31' as nvarchar(255)) as invalid_date
,if_valid,jd_union_id
from(
    select cast(row_number() over(order by sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id) as bigint) ranking
    ,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id
    ,sephora_card_no,crm_account_id,wechat_union_id,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others,convert(date,DATEADD(hour,8,getdate())) as update_date
    ,1 as if_valid,jd_union_id
	from #result_temp
    where master_id is null 
)newdata
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping,valid Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go	

insert into [DW_Sephora].[DA_Tagging].id_mapping
select t1.master_id,t1.sephora_user_id,t1.sensor_id,t1.tmall_member_id,t1.jd_member_id,t1.red_member_id,t1.sephora_card_no,t1.crm_account_id,t1.wechat_union_id 
    ,t1.wechat_open_id,t1.device_id_IDFA,t1.device_id_IMEI,t1.device_id_others
    ,case when t1.invalid_date <> '9999-12-31' then t1.update_date else convert(date,DATEADD(hour,8,getdate())) end as update_date
    ,case when t1.invalid_date <> '9999-12-31' then t1.invalid_date else convert(date,DATEADD(hour,8,getdate())) end as invalid_date
	,0 as if_valid,t1.jd_union_id
from [DW_Sephora].[DA_Tagging].id_mapping_resave as t1
left join [DW_Sephora].[DA_Tagging].id_mapping as t2
on t1.master_id = t2.master_id
where t2.master_id is null
-- go

--20211223新增
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping,update only sensor_id valid Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go	

update [DW_Sephora].[DA_Tagging].id_mapping
set update_date = convert(date,DATEADD(hour,8,getdate())),
	invalid_date = convert(date,DATEADD(hour,8,getdate())),
	if_valid = 0
from [DW_Sephora].[DA_Tagging].id_mapping as a
join (
	select sensor_id,count(*) as cn
	from (
		select distinct sensor_id,sephora_user_id,sephora_card_no,tmall_member_id,jd_member_id,red_member_id
		from [DW_Sephora].[DA_Tagging].id_mapping
		where invalid_date='9999-12-31'
	) as a
	group by sensor_id having count(*) > 1
) as b
on a.sensor_id = b.sensor_id
where sephora_user_id is null and sephora_card_no is null and tmall_member_id is null and jd_member_id is null and red_member_id is null 

--20210715新增
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id_mapping_resave_new Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
truncate table [DW_Sephora].[DA_Tagging].id_mapping_resave_new
-- go

insert into [DW_Sephora].[DA_Tagging].id_mapping_resave_new
select master_id,sephora_user_id,sensor_id,tmall_member_id,jd_member_id,red_member_id,sephora_card_no,crm_account_id,wechat_union_id 
    ,wechat_open_id,device_id_IDFA,device_id_IMEI,device_id_others,update_date,invalid_date,if_valid,jd_union_id
from [DW_Sephora].[DA_Tagging].id_mapping
-- go


-- id_mapping_update_card_bind, Bind Card

----需要纪录所有card_no，以及切换绑定Sephora_id的时间
----思路 把每天的card_no is not null的数据拿出来，和结果表中的前一天的数据对比，有变化/新增卡片则新增进去，无变化的则不管
----历史数据需要从开始按天循环执行

----取出 DW_Sephora.[STG_User].[V_User_Profile] 表最新数据

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','mapping_temp,insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go	
truncate table [DW_Sephora].[DA_Tagging].mapping_temp
-- go

insert into [DW_Sephora].[DA_Tagging].mapping_temp(sephora_card_no,sephora_user_id,last_update)
select distinct case card_no  when 'null' then null when '' then null  else card_no end as card_no,user_id,convert(date,last_update) as last_update
from DW_Sephora.[STG_User].[V_User_Profile]
where card_no is not null 
--where to_date(last_update)='2020-10-09'
and convert(date,last_update) = @datadate
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','mapping_temp,master_id update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].mapping_temp
set master_id = t2.master_id
from [DW_Sephora].[DA_Tagging].mapping_temp as t1
join (
    select sephora_user_id,master_id
    from (
        select sephora_user_id,master_id,row_number() over(partition by sephora_user_id order by master_id) as ranking
        from [DW_Sephora].[DA_Tagging].id_mapping
		where invalid_date = '9999-12-31') as a
        where ranking = 1
) as t2
on t1.sephora_user_id = t2.sephora_user_id
-- go


----最新数据和mapping已存在数据比较，mapping表中card_no不存在的新增进去，已存在的对比sephora_user_id是否有变化，有变化则新增，无变化则不需要
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','cardno_sephoraid_mapping,added Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping(master_id,sephora_card_no,sephora_user_id,last_update,dt)
----新增card_no
select t.master_id,t.sephora_card_no,t.sephora_user_id,t.last_update,t.last_update as dt
from [DW_Sephora].[DA_Tagging].mapping_temp t
left join [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping_resave m
on t.sephora_card_no=m.sephora_card_no
where m.sephora_card_no is null
-- go

----card_no对应sephora_id有变化，且t.sephora_user_id不是null
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','cardno_sephoraid_mapping,sephora_user_id update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping(master_id,sephora_card_no,sephora_user_id,last_update,dt)
select master_id_new,sephora_card_no,sephora_user_id_new,last_update_new,last_update_new as dt
from(
    select m.*,t.master_id as master_id_new,t.sephora_user_id as sephora_user_id_new,t.last_update as last_update_new
    ,case when case when m.sephora_user_id is null then '' else m.sephora_user_id end=case when t.sephora_user_id is null then '' else t.sephora_user_id end then N'sephora_user_id 未更改' else N'sephora_user_id 有更改' end as sephora_user_id_tag
    from (
		select a.* 
        from [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping_resave as a
        where dt = convert(date,DATEADD(day,- 1,@datadate))
		) m
    join [DW_Sephora].[DA_Tagging].mapping_temp t
    on m.sephora_card_no=t.sephora_card_no 
)temp
where sephora_user_id_tag=N'sephora_user_id 有更改' and sephora_user_id_new is not null
-- go

--insert into [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping(master_id,sephora_card_no,sephora_user_id,last_update,dt)
--select master_id_new,sephora_card_no,sephora_user_id_new,last_update_new,last_update_new as dt
--from(
--    select m.*,t.master_id as master_id_new,t.sephora_user_id as sephora_user_id_new,t.last_update as last_update_new
--    ,case when case when m.sephora_user_id is null then '' else m.sephora_user_id end=case when t.sephora_user_id is null then '' else t.sephora_user_id end then N'sephora_user_id 未更改' else N'sephora_user_id 有更改' end as sephora_user_id_tag
--    from (select a.* 
--            from [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping_resave as a
--        join (select max(dt) as dt_temp from [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping_resave) as b
--        on dt = dt_temp) m
--    join [DW_Sephora].[DA_Tagging].mapping_temp t
--    on m.sephora_card_no=t.sephora_card_no 
--)temp
--where sephora_user_id_tag=N'sephora_user_id 有更改' and sephora_user_id_new is not null
---- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','cardno_sephoraid_mapping,dt update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with cardno_sephoraid_mapping_temp as (
    select rid,master_id,sephora_card_no,sephora_user_id,last_update,dt
    from (
            select rid,master_id,sephora_card_no,sephora_user_id,last_update,dt,ROW_NUMBER() over(partition by sephora_card_no order by last_update desc) as ranking
            from [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping
    ) as a
    where ranking = 1
)

update [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping
set dt = @datadate
from [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping as t1
join cardno_sephoraid_mapping_temp as t2
on t1.rid = t2.rid
-- go

--declare @maxdt nvarchar(255) = (select max(dt) as dt from [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping)

--update [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping
--set dt = @maxdt
--from [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping as t1
--join (
--    select rid,master_id,sephora_card_no,sephora_user_id,last_update,dt
--    from (
--            select rid,master_id,sephora_card_no,sephora_user_id,last_update,dt,ROW_NUMBER() over(partition by sephora_card_no order by last_update desc) as ranking
--            from [DW_Sephora].[DA_Tagging].cardno_sephoraid_mapping
--    ) as a
--    where ranking = 1
--) as t2
--on t1.rid = t2.rid
---- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T1','id mapping update end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go


/* ############ ############ ############ Weekly Update Tag Table Initialize ############ ############ ############ */


DECLARE @WeekNum VARCHAR(50)= datename(weekday, DATEADD(hour,8,getdate()))
if @WeekNum='Saturday'  -- Sunday
	begin 
		
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T1','Tagging System Weekly Update,Truncate Table start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())


		truncate table DA_Tagging.tagging_weekly
		insert into DA_Tagging.tagging_weekly(master_id,crm_account_id,sensor_id,sephora_user_id,device_id_IDFA,device_id_IMEI,sephora_card_no)
		select master_id,crm_account_id,sensor_id,sephora_user_id,device_id_IDFA,device_id_IMEI,sephora_card_no
		from DA_Tagging.id_mapping
		where invalid_date='9999-12-31'


		update DA_Tagging.tagging_weekly
		set sales_member_id = t2.sales_member_id
		from DA_Tagging.tagging_weekly t1
		join DA_Tagging.sales_id_mapping t2 on t1.master_id=t2.master_id
		
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T1','Tagging System Weekly Update,Truncate Table end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	end

end
-- go
GO
