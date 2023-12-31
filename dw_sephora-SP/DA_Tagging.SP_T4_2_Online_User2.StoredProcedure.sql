/****** Object:  StoredProcedure [DA_Tagging].[SP_T4_2_Online_User2]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T4_2_Online_User2] AS
BEGIN

/* ############ ############ ############ Channel Tag ############ ############ ############ */
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Channel','Tagging System Channel, Generate Channel Tab',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
/*[RPT_EDW].[v_oms_sales_order_vb_level_df] 对应[DW_OMS].[V_Sales_Order_VB_Level] 364.365.366 或者 [DA_Tagging].[sales_order_vb_temp] 353.362.363 */
;

TRUNCATE table DA_Tagging.CHANNEL
insert into [DA_Tagging].[CHANNEL](channel_id,channel_name)
select 1,'app' union all 
select 2,'MiniProgram' union all 
select 3,'mobile' union all 
select 4,'web' union all 
select 5,'REDBOOK' union all 
select 6,'DOUYIN' union all 
select 7,'JD' union all 
select 8,'O2O' union all 
select 9,'OFF_LINE' union all 
select 10,'TMALL' union all 
select 11,'TMALL_CHALING' union all 
select 12,'TMALL_PTR' union all 
select 13,'TMALL_WEI' union all 
select 14,'WCS' union all 
select 15,'WECHAT' 
;

 -- 353.总访客人数
/*
分渠道，计算近90天各channel访问人数，输出字段：channel,访问人数
对event做限制: 限制为各种view
*/
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Channel','Tagging System Channel, Generate Channel Total Traffic',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;        
UPDATE [DA_Tagging].[CHANNEL]
SET total_traffic = z.Total_Traffic
FROM (
    SELECT platform_type AS channel_name, COUNT(DISTINCT user_id) AS Total_Traffic
    FROM DA_Tagging.v_events_media_session
    WHERE dt BETWEEN CONVERT(varchar(100), DATEADD(day, -90, GETDATE()), 23) AND CONVERT(varchar(100), GETDATE(), 23)
        AND ((platform_type = 'app'
                AND event = '$AppViewScreen')
            OR (platform_type = 'MiniProgram'
                AND event = '$MPViewScreen')
            OR (platform_type = 'mobile'
                AND event = '$pageview')
            OR (platform_type = 'web'
                AND event = '$pageview'))
    GROUP BY platform_type
) z
WHERE [DA_Tagging].[CHANNEL].channel_name = z.channel_name
;

-- 362. 总消费金额
/*分渠道，计算近90天消费金额，输出字段：channel,amount*/
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Channel','Tagging System Channel, Generate Channel Total Sales',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;          

update [DA_Tagging].[CHANNEL]
SET total_sales = z.total_sales
from (
SELECT channel_cd,sum(total_sales) as total_sales
FROM (
    SELECT CASE 
            WHEN channel_cd = 'APP' THEN 'app'
            WHEN channel_cd = 'APP(ANDROID)' THEN 'app'
            WHEN channel_cd = 'APP(IOS)' THEN 'app'
            WHEN channel_cd = 'ANNYMINIPROGRAM' THEN 'MiniProgram'
            WHEN channel_cd = 'MINIPROGRAM' THEN 'MiniProgram'
            WHEN channel_cd = 'BENEFITMINIPROGRAM' THEN 'MiniProgram'
            WHEN channel_cd = 'MOBILE' THEN 'mobile'
            WHEN channel_cd = 'PC' THEN 'web'
            ELSE channel_cd
        END AS channel_cd, SUM(order_amount) AS total_sales
    FROM [DW_OMS].[V_Sales_Order_Basic_Level]
    WHERE place_date BETWEEN CONVERT(varchar(100), DATEADD(day, -90, GETDATE()), 23) AND CONVERT(varchar(100), GETDATE(), 23)
        AND channel_cd IS NOT NULL
    GROUP BY channel_cd
) t1
GROUP BY channel_cd
)z
where [DA_Tagging].[CHANNEL].channel_name COLLATE SQL_Latin1_General_CP1_CI_AS= z.channel_cd
;
-- 363.新客消费金额：
/*分渠道，计算近90天,新客的消费金额,输出字段：channel,amount
定义新客:BRAND_NEW+CONVERT_NEW*/
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Channel','Tagging System Channel, Generate Channel Newly Sales',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;        
update [DA_Tagging].[CHANNEL]
SET newly_regestered  = z.newly_regestered
from (
SELECT channel_cd, SUM(amount) AS newly_regestered
FROM (
    SELECT CASE 
            WHEN channel_cd = 'APP' THEN 'app'
            WHEN channel_cd = 'APP(ANDROID)' THEN 'app'
            WHEN channel_cd = 'APP(IOS)' THEN 'app'
            WHEN channel_cd = 'ANNYMINIPROGRAM' THEN 'MiniProgram'
            WHEN channel_cd = 'MINIPROGRAM' THEN 'MiniProgram'
            WHEN channel_cd = 'BENEFITMINIPROGRAM' THEN 'MiniProgram'
            WHEN channel_cd = 'MOBILE' THEN 'mobile'
            WHEN channel_cd = 'PC' THEN 'web'
            ELSE channel_cd
        END AS channel_cd, SUM(order_amount) AS amount
    FROM [DW_OMS].[V_Sales_Order_Basic_Level]
    WHERE place_date BETWEEN CONVERT(varchar(100), DATEADD(day, -90, GETDATE()), 23) AND CONVERT(varchar(100), GETDATE(), 23)
        AND channel_cd IS NOT NULL
        AND member_new_status IN ('BRAND_NEW', 'CONVERT_NEW')
    GROUP BY channel_cd
) t1  GROUP BY channel_cd
)z
where [DA_Tagging].[CHANNEL].channel_name COLLATE SQL_Latin1_General_CP1_CI_AS = z.channel_cd
;
-- 364.EB Brand New消费金额:BRAND_NEW_amount  
/*分渠道，计算近90天member_new_status ='BRAND_NEW' 的order_amount之和*/
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Channel','Tagging System Channel, Generate Channel Brand New Sales',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

UPDATE [DA_Tagging].[CHANNEL]
SET BRAND_NEW_to_EB = z.BRAND_NEW_to_EB
FROM (
    SELECT channel_cd, SUM(BRAND_NEW_amount) AS BRAND_NEW_to_EB
    FROM (
        SELECT CASE 
                WHEN channel_cd = 'APP' THEN 'app'
                WHEN channel_cd = 'APP(ANDROID)' THEN 'app'
                WHEN channel_cd = 'APP(IOS)' THEN 'app'
                WHEN channel_cd = 'ANNYMINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'MINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'BENEFITMINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'MOBILE' THEN 'mobile'
                WHEN channel_cd = 'PC' THEN 'web'
                ELSE channel_cd
            END AS channel_cd, SUM(order_amount) AS BRAND_NEW_amount
        FROM (
            SELECT channel_cd, place_date, order_amount
            FROM [DW_OMS].[V_Sales_Order_Basic_Level]
            WHERE place_date BETWEEN convert(date, DATEADD(hour, 8, getdate()) - 90) AND convert(date, DATEADD(hour, 8, getdate()) - 1)
                AND member_new_status = 'BRAND_NEW'
        ) t1
        GROUP BY channel_cd
    ) tt1
    GROUP BY channel_cd
) z
WHERE [DA_Tagging].[CHANNEL].channel_name COLLATE SQL_Latin1_General_CP1_CI_AS = z.channel_cd
;

-- 365.EB Convert New消费金额
/*CONVERT_NEW_amount  分渠道，计算近90天member_new_status ='CONVERT_NEW' 的order_amount之和*/
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Channel','Tagging System Channel, Generate Channel Convert New Sales',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

UPDATE [DA_Tagging].[CHANNEL]
SET CONVERT_NEW_to_EB = z.CONVERT_NEW_to_EB
FROM (
    SELECT channel_cd, SUM(CONVERT_NEW_amount) AS CONVERT_NEW_to_EB
    FROM (
        SELECT CASE 
                WHEN channel_cd = 'APP' THEN 'app'
                WHEN channel_cd = 'APP(ANDROID)' THEN 'app'
                WHEN channel_cd = 'APP(IOS)' THEN 'app'
                WHEN channel_cd = 'ANNYMINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'MINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'BENEFITMINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'MOBILE' THEN 'mobile'
                WHEN channel_cd = 'PC' THEN 'web'
                ELSE channel_cd
            END AS channel_cd, SUM(order_amount) AS CONVERT_NEW_amount
        FROM (
            SELECT channel_cd, place_date, order_amount
            FROM [DW_OMS].[V_Sales_Order_Basic_Level]
            WHERE place_date BETWEEN convert(date, DATEADD(hour, 8, getdate()) - 90) AND convert(date, DATEADD(hour, 8, getdate()) - 1)
                AND member_new_status = 'CONVERT_NEW'
        ) t1
        GROUP BY channel_cd
    ) tt1
    GROUP BY channel_cd
) z
WHERE [DA_Tagging].[CHANNEL].channel_name COLLATE SQL_Latin1_General_CP1_CI_AS= z.channel_cd
;

-- 366.EB老客消费金额:
/*RETURN_amount  分渠道，计算近90天member_new_status ='RETURN' 的order_amount之和*/
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Channel','Tagging System Channel, Generate Channel Existing Sales',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

UPDATE [DA_Tagging].[CHANNEL]
SET EXISTING_EB = z.EXISTING_EB
FROM (
    SELECT channel_cd, SUM(RETURN_amount) AS EXISTING_EB
    FROM (
        SELECT CASE 
                WHEN channel_cd = 'APP' THEN 'app'
                WHEN channel_cd = 'APP(ANDROID)' THEN 'app'
                WHEN channel_cd = 'APP(IOS)' THEN 'app'
                WHEN channel_cd = 'ANNYMINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'MINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'BENEFITMINIPROGRAM' THEN 'MiniProgram'
                WHEN channel_cd = 'MOBILE' THEN 'mobile'
                WHEN channel_cd = 'PC' THEN 'web'
                ELSE channel_cd
            END AS channel_cd, SUM(order_amount) AS RETURN_amount
        FROM (
            SELECT channel_cd, place_date, order_amount
            FROM [DW_OMS].[V_Sales_Order_Basic_Level]
            WHERE place_date BETWEEN convert(date, DATEADD(hour, 8, getdate()) - 90) AND convert(date, DATEADD(hour, 8, getdate()) - 1)
                AND member_new_status = 'RETURN'
        ) t1
        GROUP BY channel_cd
    ) tt1
    GROUP BY channel_cd
) z
WHERE [DA_Tagging].[CHANNEL].channel_name COLLATE SQL_Latin1_General_CP1_CI_AS= z.channel_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Channel','Tagging System Channel, Generate Channel End',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

/* ############ ############ ############ Campaign Tag ############ ############ ############ */

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Campaign','Tagging System Campaign, Generate Campaign Tag',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

TRUNCATE table DA_Tagging.campaign
insert into DA_Tagging.campaign(campaign_id,Campaign_Name,start_date,end_date,channel,Campaign_Type,Campaign_type_Dtail)
select  distinct  campaign_id,Campaign_Name,Campaign_Start_Time,Campaign_End_Time,Platform,Campaign_Type,Campaign_Detail
from DA_Tagging.coding_campaign_name
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Campaign','Tagging System Campaign, Generate Campaign Tag End',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;


/* ############ ############ ############ Media Tag ############ ############ ############ */
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System Media, Generate Media Tab',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
--投放渠道
--投放名称
--投放组
--投放媒介
--投放渠道

TRUNCATE TABLE DA_Tagging.media
insert into DA_Tagging.media(campaign_channel,campaign_name,campaign_group,campaign_group_id)
select distinct channelName as campaign_channel
, campaignName
, campaignGroupName as campaign_group
, campaignGroupID as campaign_group_id
from [DW_TD].[Tb_Dim_CampaignMapping]


insert into DA_Tagging.media(utm_source,utm_medium)
select distinct ss_utm_source as utm_source,ss_utm_medium as utm_medium 
from DW_Sensor.DWS_Sensor_UTM_Traffic
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System media, Generate PcMoblileMnp Uv & Visit & Ctr',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
--PC/MOBLILE/MNP UV	    独立访客数: 根据不同utm_scoure,utm_media,取Traffic表中UV均值
--PC/MOBLILE/MNP Visit	浏览次数:   根据不同utm_scoure,utm_media,取Traffic表中PV
--PC/MOBLILE/MNP CTR	引流点击率: 根据不同utm_scoure,utm_media,取Traffic表中分media的 pdp_uv/PV 

update DA_Tagging.media
set  PcMoblileMnp_uv = t1.PcMoblileMnp_uv
    , PcMoblileMnp_visit = t1.PcMoblileMnp_visit
from DA_Tagging.media t
join (
		select ss_utm_medium ,ss_utm_source 
		,avg(uv) as PcMoblileMnp_uv 
		,avg(pv) as PcMoblileMnp_visit
		from DW_Sensor.DWS_Sensor_UTM_Traffic 
		group by ss_utm_source,ss_utm_medium	
)t1 on t.utm_source =t1.ss_utm_source collate Chinese_PRC_CS_AI_WS 
	and t.utm_medium=t1.ss_utm_medium collate Chinese_PRC_CS_AI_WS
;                


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System media, Generate PcMoblileMnp CVR',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
--PC/MOBLILE/MNP CVR	下单转化率: 根据不同utm_scoure,utm_media,Attribution表计算下单人数，除以Traffic表的UV

update DA_Tagging.media
set PcMoblileMnp_cvr = case when tt.order_user_cn<>0 then tt.order_user_cn else 0 end/t.PcMoblileMnp_uv
from DA_Tagging.media t
join (
    select ss_utm_source,ss_utm_medium
    ,avg(order_user) as order_user_cn
    from(
        select place_date,ss_utm_source,ss_utm_medium
        ,count(distinct sephora_user_id) as order_user
        from DW_Sensor.DWS_Sensor_Order_UTM_Attribution
        where attribution_type='1D' and payed_amount>0 and payed_amount is not null and is_placed_flag=1
        group by  place_date,ss_utm_source,ss_utm_medium
    )t
    group by ss_utm_source,ss_utm_medium
)tt on t.utm_source =tt.ss_utm_source collate Chinese_PRC_CS_AI_WS
and t.utm_source=tt.ss_utm_source collate Chinese_PRC_CS_AI_WS
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System media, Generate PcMoblileMnp Order Sales',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
--PC/MOBLILE/MNP Order	转化订单数
--PC/MOBLILE/MNP Sales	转化金额

update DA_Tagging.media
set PcMoblileMnp_order = tt.PcMoblileMnp_order
    ,PcMoblileMnp_sales = tt.PcMoblileMnp_sales
from DA_Tagging.media t
join (
    select ss_utm_source,ss_utm_medium
    ,count(distinct sales_order_number) as PcMoblileMnp_order
    ,sum(payed_amount) as PcMoblileMnp_sales
    from(
        select ss_utm_source,ss_utm_medium ,payed_amount,sales_order_number
        from [DW_Sensor].[DWS_Sensor_Order_UTM_Attribution]
        where payed_amount>0 and payed_amount is not null and is_placed_flag=1 and attribution_type='1D' 
    )t group by ss_utm_source,ss_utm_medium
)tt on t.utm_source =tt.ss_utm_source collate Chinese_PRC_CS_AI_WS
and t.utm_source=tt.ss_utm_source collate Chinese_PRC_CS_AI_WS
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System media, Generate App Activation',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

IF OBJECT_ID('tempdb..#td_temp_install','U')  IS NOT NULL
drop table #td_temp_install;
create table #td_temp_install
(	
    Campaign_Name nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    Channel_Name nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    device_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    active_time nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #td_temp_install
select Campaign_Name,Channel_Name,device_id,active_time
from(
    select Campaign_Name,Channel_Name,android_id as device_id,active_time
    from [ODS_TD].[Tb_Android_Install]
    where android_id is not null 
    and (Campaign_Name is not null or Channel_Name is not null )
    union all
    select Campaign_Name,Channel_Name,idfa as device_id,active_time
    from [ODS_TD].[Tb_IOS_Install]
    where idfa is not null
    and (Campaign_Name is not null or Channel_Name is not null )
)t
;


update DA_Tagging.media
set app_activation= tt.app_activation
from DA_Tagging.media t
join (
        select Campaign_Name,Channel_Name,count(distinct device_id) as app_activation
        from(
            select Campaign_Name,Channel_Name,device_id,active_time
            ,row_number() over (partition by device_id order by active_time) as rn
            from #td_temp_install
            )t1 where rn=1
            group by Campaign_Name,Channel_Name
)tt on t.campaign_name=tt.campaign_name collate Chinese_PRC_CS_AI_WS
and t.campaign_channel=tt.Channel_Name collate Chinese_PRC_CS_AI_WS
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System media, Generate TD Temp Tab',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

IF OBJECT_ID('tempdb..#td_temp','U')  IS NOT NULL
drop table #td_temp;
create table #td_temp
(
    CampaignName nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    ChannelName nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    device_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    IsPlacedFlag int,
    PayedAmount float,
    OrderID nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    UVFlag nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #td_temp
                
select CampaignName,ChannelName,AndroidId as device_id, IsPlacedFlag,PayedAmount,OrderID,UVFlag from [DW_TD].[Tb_Fact_Android_Ascribe] 
union all
select CampaignName,ChannelName,IDFA as device_id,IsPlacedFlag,PayedAmount,OrderID,UVFlag from [DW_TD].[Tb_Fact_IOS_Ascribe]
                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System media, Generate App Order & Sales',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

-- APP Order	转化订单数	1,2,3,4….
-- APP Sales	转化金额	100,200,300…
update DA_Tagging.media
set app_order = tt.app_order
    ,app_sales = tt.app_sales
from DA_Tagging.media t
join (
    select ChannelName,CampaignName
        ,count(distinct OrderID) as app_order
        ,sum(PayedAmount) as app_sales
    from(
        select distinct CampaignName,ChannelName,OrderID,PayedAmount
        from #td_temp
        where PayedAmount>0 and PayedAmount is not null and IsPlacedFlag=1
    )t1 
    group by ChannelName,CampaignName
)tt on t.campaign_name=tt.CampaignName and t.campaign_channel=tt.ChannelName
;                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System media, Generate App UV',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.media
set app_uv = tt.app_uv 
from DA_Tagging.media t
join (
    select channelname,CampaignName, avg(uv) as app_uv
    from(
        select channelname,CampaignName, uv 
        from dw_td.tb_fact_ios_report where uv is not null 
        union all
        select channelname,CampaignName, uv 
        from dw_td.tb_fact_android_report where uv is not null 
    )t
    group by channelname,CampaignName
)tt on t.campaign_name=tt.CampaignName collate Chinese_PRC_CS_AI_WS
and t.campaign_channel=tt.ChannelName collate Chinese_PRC_CS_AI_WS
;

alter table DA_Tagging.media DROP COLUMN media_id
alter table DA_Tagging.media ADD media_id BIGINT identity(1,1)
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Media','Tagging System media, Generate media tag end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

;
/* ############ ############ ############ Online User Tag ############ ############ ############ */
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online User','Tagging System Online User, Generate Online User Tab',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

TRUNCATE TABLE  DA_Tagging.online_user2
insert into DA_Tagging.online_user2(master_id,sales_member_id,sephora_user_id,sensor_id,sephora_card_no, device_id_IDFA, device_id_IMEI)
select t1.master_id, t2.sales_member_id, t1.sephora_user_id, t1.sensor_id, t1.sephora_card_no, t1.device_id_IDFA, t1.device_id_IMEI
from(
    select master_id, sephora_user_id, sensor_id, sephora_card_no, device_id_IDFA, device_id_IMEI
    from DA_Tagging.id_mapping
    where invalid_date='9999-12-31'
)t1
left outer join DA_Tagging.sales_id_mapping t2 on t1.master_id=t2.master_id
;

/* ############ ############ ############ Online User Weekly Update Tag ############ ############ ############ */
DECLARE @WeekNum VARCHAR(10)= datename(weekday, DATEADD(hour,8,getdate()))

if @WeekNum='Saturday'
begin 
	--app_activation_status: APP激活状态
	insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
	select 'Online User','Tagging System Online User, Weekly Update Online User [app_activation_status]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	;

	IF OBJECT_ID('tempdb..#app_sensor','U')  IS NOT NULL
	drop table #app_sensor;
	create table #app_sensor(
		user_id bigint
	)
	insert into #app_sensor(user_id)
	select distinct user_id 
	from STG_Sensor.V_Events
	where platform_type in ('app','APP')


	update DA_Tagging.tagging_weekly
	set app_activation_status= N'已激活APP'
	from DA_Tagging.tagging_weekly t1
	join #app_sensor tt on t1.sensor_id = tt.user_id
	where t1.sephora_user_id is not null
end

/* ############ ############ ############ Online User Daily Update Tag ############ ############ ############ */
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online User','Tagging System Online User, Update Online User [app_activation_status]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
IF OBJECT_ID('tempdb..#weekly_online_user2','U')  IS NOT NULL
drop table #weekly_online_user2;
create table #weekly_online_user2(
	master_id bigint ,
	app_activation_status nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #weekly_online_user2(master_id,app_activation_status)
select master_id, app_activation_status
from DA_Tagging.tagging_weekly 
where sephora_user_id is not null



update DA_Tagging.online_user2
set app_activation_status= tt.app_activation_status
from DA_Tagging.online_user2 t1
join #weekly_online_user2 tt on t1.master_id = tt.master_id
where t1.sephora_user_id is not null


-- tenure_days_group: 丝芙兰官网注册用户持有时间段
-- registered_day_type: 丝芙兰官网注册用户注册日期类型
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online User','Tagging System Online User, Generate Online User [tenure_days_group],[registered_day_type] ',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
 ;
-- 0915改 先建temp表再做update --6min
IF OBJECT_ID('tempdb..#registered_day_type','U')  IS NOT NULL
drop table #registered_day_type;
create table #registered_day_type(
	sephora_user_id bigint ,
	tenure_days_group nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	registered_day_type nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #registered_day_type(sephora_user_id,tenure_days_group,registered_day_type)
select sephora_user_id
    ,case when tenure_days<30 then '[0,30)'
            when tenure_days>=30 and tenure_days<60 then '[30,60)'
            when tenure_days>=60 and tenure_days<90 then '[60,90)'
            when tenure_days>=90 and tenure_days<180 then '[90,180)'
            when tenure_days>=180 and tenure_days<365 then '[180,365)'
            when tenure_days>=365 and tenure_days<1095 then N'1年-3年'
            when tenure_days>=1095 then N'3年以上' end as tenure_days_group
    ,case when daytype='Holidays and Festivals' then 'Holiday' else daytype end as registered_day_type
    from(
        select sephora_user_id,card_no,register_date
            ,datediff(day,register_date,convert(date,getdate())) as tenure_days
        from(
            select user_id as sephora_user_id,t2.card_no,convert(date,register_time) as register_date
            from DW_User.V_User_Info t1
            join STG_User.V_Card t2 on t1.card_no=t2.card_no
            where t2.source<>'Offline' and isnumeric(user_id)=1
            )t1
        )t
    left outer join DA_Tagging.coding_daytype tt on t.register_date= tt.[date]
;

update DA_Tagging.online_user2
set tenure_days_group = tt2.tenure_days_group,
    registered_day_type = tt2.registered_day_type
from DA_Tagging.online_user2 tt1
join #registered_day_type tt2 on tt1.sephora_user_id=tt2.sephora_user_id
;


-- city_tier: 用户常住城市等级
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online User','Tagging System Online User, Generate Online User [city_tier]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 0915改 先建temp表再做update --3min
IF OBJECT_ID('tempdb..#city_tier','U')  IS NOT NULL
drop table #city_tier;
create table #city_tier(
	master_id bigint ,
	city_tier nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #city_tier(master_id,city_tier)
select master_id, CONCAT('Tier ' collate Chinese_PRC_CS_AI_WS ,t2.citytiercode) as city_tier
from(
    select master_id, city
    from DA_Tagging.online_user
)t1
left join DA_Tagging.city_list t2 on replace(t1.city,N'市','')= replace(t2.city,N'市','')
where t2.citytiercode is not null
;

update  DA_Tagging.online_user2
set city_tier = tt2.city_tier
from  DA_Tagging.online_user2 tt1
join #city_tier tt2 on tt1.master_id=tt2.master_id
;



-- offline_bunded: 是否线下绑定小程序 : 根据注册表记录的店铺筛选线下注册的用户
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online User','Tagging System Online User, Generate Online User [offline_bunded]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
select distinct store_code
into #offline_store
from ODS_CRM.DimStore
where is_eb_store<>2 and region<>'EBUSINESS'
;

update DA_Tagging.online_user2
set offline_bunded = (case when tt2.offline_bunded is not null then 1 else 0 end)
from DA_Tagging.online_user2 tt1
left join (
    select user_id,register_store as offline_bunded
            from DW_WechatCenter.V_Wechat_User_Info  t1
    join #offline_store t2 on t1.register_store = t2.store_code  collate Chinese_PRC_CS_AI_WS
) tt2 on tt1.sephora_user_id =tt2.user_id
;



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online User','Tagging System Online User, Generate Online User Tag End',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

END
GO
