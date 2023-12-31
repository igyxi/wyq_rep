/****** Object:  StoredProcedure [TEST].[SP_Model_Feature_Metric_Test]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_Model_Feature_Metric_Test] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-16       litao          Initial Version
-- ========================================================================================


--总表
--create table [Test].[Model_Feature_Metric_Test]
--(
--member_card [nvarchar](512) NULL,
--com_metric int NULL,
--[gender] [int] NULL,
--age int NULL,
--[prefer_city] [nvarchar](512) NULL,
--[card_type] [int] NULL,
--register_length int NULL,
--source [nvarchar](512) NULL,
--[insert_timestamp] [datetime] NOT NULL
--)
--


--1.工作日活跃次数(unique天数)+map 到年龄，性别，城市，卡别，注册时长
--Sensor.User_Workday_Active_Days
--create table [Sensor].[User_Workday_Active_Days]
--(
--member_card [nvarchar](512) NULL,
--weekday_active_times int NULL,
--[gender] [int] NULL,
--age int NULL,
--[prefer_city] [nvarchar](512) NULL,
--[card_type] [int] NULL,
--register_length int NULL, 
--[insert_timestamp] [datetime] NOT NULL
--)
--;



delete from [Test].[Model_Feature_Metric_Test] where source=N'工作日活跃';
insert into [Test].[Model_Feature_Metric_Test]
select t2.member_card,
       weekday_active_times,
       gender,
       age,
       prefer_city,
       card_type,
       register_length,
       N'工作日活跃' as source,
       CURRENT_TIMESTAMP insert_timestamp
  from (SELECT vip_card, count(distinct(date)) as weekday_active_times
          from [DW_Sensor].[DWS_Events_Session_Cutby30m]
         where date between '2021-01-01' and '2021-12-31'
           and DATENAME(dw, date) not in ('Saturday', 'Sunday')
           and vip_card is not null
           and date is not null
         group by vip_card) t1
  left join (SELECT member_card,
                    gender,
                    datediff(year, birth_date, GETDATE()) as age,
                    prefer_city,
                    card_type,
                    datediff(day, register_date, GETDATE()) as register_length
               FROM DWD.DIM_Member_Info
              where card_type != 9) t2 
 on t1.vip_card = t2.member_card
;

  
--2.周末活跃次数(unique天数)+map 到年龄，性别，城市，卡别，注册时长
--Sensor.User_Weekend_Active_Days
--create table [Sensor].[User_Weekend_Active_Days]
--(
--member_card [nvarchar](512) NULL,
--weekend_active_times int NULL,
--[gender] [int] NULL,
--age int NULL,
--[prefer_city] [nvarchar](512) NULL,
--[card_type] [int] NULL,
--register_length int NULL, 
--[insert_timestamp] [datetime] NOT NULL
--)
--;

delete from [Test].[Model_Feature_Metric_Test] where source=N'周末活跃';
insert into [Test].[Model_Feature_Metric_Test]
select t2.member_card,
       weekend_active_times,
       gender,
       age,
       prefer_city,
       card_type,
       register_length,
       N'周末活跃' as source,
       CURRENT_TIMESTAMP insert_timestamp
  from (SELECT vip_card, count(distinct(date)) as weekend_active_times
          from [DW_Sensor].[DWS_Events_Session_Cutby30m]
         where date between '2021-01-01' and '2021-12-31'
           and DATENAME(dw, date) in ('Saturday', 'Sunday')
           and vip_card is not null
           and date is not null
         group by vip_card) t1
  left join (SELECT member_card,
                    gender,
                    datediff(year, birth_date, GETDATE()) as age,
                    prefer_city,
                    card_type,
                    datediff(day, register_date, GETDATE()) as register_length
               FROM DWD.DIM_Member_Info
              where card_type != 9) t2 
  on t1.vip_card = t2.member_card
;


--3.点击次数(unique天数)+map 到年龄，性别，城市，卡别，注册时长
--Sensor.User_Click_Days
--create table [Sensor].[User_Click_Days]
--(
--member_card [nvarchar](512) NULL,
--click_times int NULL,
--[gender] [int] NULL,
--age int NULL,
--[prefer_city] [nvarchar](512) NULL,
--[card_type] [int] NULL,
--register_length int NULL, 
--[insert_timestamp] [datetime] NOT NULL
--)
--;

delete from [Test].[Model_Feature_Metric_Test] where source=N'点击次数';
insert into [Test].[Model_Feature_Metric_Test]
select t2.member_card,
       click_times,
       gender,
       age,
       prefer_city,
       card_type,
       register_length,
       N'点击次数' as source,
       CURRENT_TIMESTAMP insert_timestamp
  from (SELECT vip_card, count(distinct(date)) as click_times
          from [DW_Sensor].[DWS_Events_Session_Cutby30m]
         where event like '%click%'
           and vip_card is not null
           and date between '2021-01-01' and '2021-12-31'
         group by vip_card) t1
  left join (SELECT member_card,
                    gender,
                    datediff(year, birth_date, GETDATE()) as age,
                    prefer_city,
                    card_type,
                    datediff(day, register_date, GETDATE()) as register_length
               FROM DWD.DIM_Member_Info
              where card_type != 9) t2 
  on t1.vip_card = t2.member_card
;


--4.页面浏览次数(unique天数)+map 到年龄，性别，城市，卡别，注册时长
--Sencor.User_Browse_Days
--create table [Sensor].[User_Browse_Days]
--(
--member_card [nvarchar](512) NULL,
--pageview_times int NULL,
--[gender] [int] NULL,
--age int NULL,
--[prefer_city] [nvarchar](512) NULL,
--[card_type] [int] NULL,
--register_length int NULL, 
--[insert_timestamp] [datetime] NOT NULL
--)
--;

delete from [Test].[Model_Feature_Metric_Test] where source=N'页面浏览';
insert into [Test].[Model_Feature_Metric_Test]
select t2.member_card,
       pageview_times,
       gender,
       age,
       prefer_city,
       card_type,
       register_length,
       N'页面浏览' as source,
       CURRENT_TIMESTAMP insert_timestamp
  from (SELECT vip_card, count(distinct(date)) as pageview_times
          from [DW_Sensor].[DWS_Events_Session_Cutby30m]
         where event like '%pageview%'
           and vip_card is not null
           and date between '2021-01-01' and '2021-12-31'
         group by vip_card) t1
  left join (SELECT member_card,
                    gender,
                    datediff(year, birth_date, GETDATE()) as age,
                    prefer_city,
                    card_type,
                    datediff(day, register_date, GETDATE()) as register_length
               FROM DWD.DIM_Member_Info
              where card_type != 9) t2 
   on t1.vip_card = t2.member_card
;


--5.加购物车次数(unique天数)+map 到年龄，性别，城市，卡别，注册时长
---Sencor.User_Add_Shopping_Cart_Days

--create table [Sensor].[User_Add_Shopping_Cart_Days]
--(
--member_card [nvarchar](512) NULL,
--add_to_cart_times int NULL,
--[gender] [int] NULL,
--age int NULL,
--[prefer_city] [nvarchar](512) NULL,
--[card_type] [int] NULL,
--register_length int NULL, 
--[insert_timestamp] [datetime] NOT NULL
--)
--;


delete from [Test].[Model_Feature_Metric_Test] where source=N'加购物车';
insert into [Test].[Model_Feature_Metric_Test]
select t2.member_card,
       add_to_cart_times,
       gender,
       age,
       prefer_city,
       card_type,
       register_length,
	   N'加购物车' as source,
       CURRENT_TIMESTAMP insert_timestamp
  from (SELECT vip_card, count(distinct(date)) as add_to_cart_times
          from [DW_Sensor].[DWS_Events_Session_Cutby30m]
         where event like '%addToShoppingcart%'
           and date between '2021-01-01' and '2021-12-31'
           and vip_card is not null
           and date is not null
         group by vip_card) t1
  left join (SELECT member_card,
                    gender,
                    datediff(year, birth_date, GETDATE()) as age,
                    prefer_city,
                    card_type,
                    datediff(day, register_date, GETDATE()) as register_length
               FROM DWD.DIM_Member_Info
              where card_type != 9) t2 
   on t1.vip_card = t2.member_card
;

--6.搜索次数(unique天数)+map 到年龄，性别，城市，卡别，注册时长
--Sencor.User_Search_Days

--create table [Sensor].[User_Search_Days]
--(
--member_card [nvarchar](512) NULL,
--search_times int NULL,
--[gender] [int] NULL,
--age int NULL,
--[prefer_city] [nvarchar](512) NULL,
--[card_type] [int] NULL,
--register_length int NULL, 
--[insert_timestamp] [datetime] NOT NULL
--)
--;


delete from [Test].[Model_Feature_Metric_Test] where source=N'搜索次数';
insert into [Test].[Model_Feature_Metric_Test]
select t2.member_card,
       search_times,
       gender,
       age,
       prefer_city,
       card_type,
       register_length,
	   N'搜索次数' as source,
       CURRENT_TIMESTAMP insert_timestamp
  from (SELECT vip_card, count(distinct(date)) as search_times
          from STG_Sensor.Events
         where event in ('clickBanner_App_Mob_New', 'clickBanner_MP','clickBanner_web')
           and banner_belong_area = 'searchview'
           and date between '2021-01-01' and '2021-12-31'
           and vip_card is not null
           and date is not null
         group by vip_card) t1
  left join (SELECT member_card,
                    gender,
                    datediff(year, birth_date, GETDATE()) as age,
                    prefer_city,
                    card_type,
                    datediff(day, register_date, GETDATE()) as register_length
               FROM DWD.DIM_Member_Info
              where card_type != 9) t2 
  on t1.vip_card collate SQL_Latin1_General_CP1_CI_AS = t2.member_card
;




--7.产品页面分享次数(unique天数)+map 到年龄，性别，城市，卡别，注册时长
--Sencor.User_Share_Page_Days


--create table [Sensor].[User_Share_Page_Days]
--(
--member_card [nvarchar](512) NULL,
--share_times int NULL,
--[gender] [int] NULL,
--age int NULL,
--[prefer_city] [nvarchar](512) NULL,
--[card_type] [int] NULL,
--register_length int NULL, 
--[insert_timestamp] [datetime] NOT NULL
--)
--;


delete from [Test].[Model_Feature_Metric_Test] where source=N'产品页面分享';
insert into [Test].[Model_Feature_Metric_Test]
select t2.member_card,
       share_times,
       gender,
       age,
       prefer_city,
       card_type,
       register_length,
	   N'产品页面分享' as source,
       CURRENT_TIMESTAMP insert_timestamp
  from (SELECT vip_card, count(distinct(date)) as share_times
          from [DW_Sensor].[DWS_Events_Session_Cutby30m]
         where Action_id in ('1000401_995', '1000401_996')
            or page_id = '1000401'
           and date between '2021-01-01' and '2021-12-31'
           and vip_card is not null
           and date is not null
         group by vip_card) t1
  left join (SELECT member_card,
                    gender,
                    datediff(year, birth_date, GETDATE()) as age,
                    prefer_city,
                    card_type,
                    datediff(day, register_date, GETDATE()) as register_length
               FROM DWD.DIM_Member_Info
              where card_type != 9) t2 
on t1.vip_card = t2.member_card
;

END



GO
