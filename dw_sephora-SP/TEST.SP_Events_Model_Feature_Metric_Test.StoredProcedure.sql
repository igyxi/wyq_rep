/****** Object:  StoredProcedure [TEST].[SP_Events_Model_Feature_Metric_Test]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_Events_Model_Feature_Metric_Test] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-16       wangzhichun           Initial Version
-- ========================================================================================


--8. 去年登录次数(unique天数)+map 到年龄，性别，城市，卡别，注册时长
delete from  [Test].[Events_Model_Feature_Metric_Test] where source='login_times';
insert into Test.Events_Model_Feature_Metric_Test
select 
  t2.member_card, 
  login_times as com_metric, 
  gender, 
  age, 
  prefer_city, 
  card_type, 
  register_length,
  'login_times' as source,
  CURRENT_TIMESTAMP as insert_timestamp
from 
(
  select 
    vip_card, 
    count(distinct(date)) as login_times 
  from 
    [DW_Sensor].[DWS_Events_Session_Cutby30m]
  where 
    event is not null 
    and vip_card is not null 
    and date is not null 
    and date between '2021-01-01' and '2021-12-31' 
  group by 
    vip_card
) t1 
left join 
(
  SELECT 
    member_card, 
    gender, 
    datediff(year,birth_date,GETDATE ()) as age, 
    prefer_city, 
    card_type, 
    datediff(day,register_date,GETDATE ()) as register_length 
  FROM 
    DWD.DIM_Member_Info 
  where 
    card_type != 9
) t2 on t1.vip_card = t2.member_card


--9距离上次登录天数+map 到年龄，性别，城市，卡别，注册时长
delete from  [Test].[Events_Model_Feature_Metric_Test] where source='last_login_date_diff';
insert into Test.Events_Model_Feature_Metric_Test
select 
  t2.member_card, 
  last_login_date_diff as com_metric, 
  gender, 
  age, 
  prefer_city, 
  card_type, 
  register_length,
  'last_login_date_diff' as source,
  CURRENT_TIMESTAMP as insert_timestamp
from 
(
  select 
    vip_card, 
    datediff(day,max(date),GETDATE ()) as last_login_date_diff 
  from 
    [DW_Sensor].[DWS_Events_Session_Cutby30m] 
  where 
    event is not null 
    and vip_card is not null 
    and date is not null 
    and date between '2021-01-01' and '2021-12-31' 
  group by 
    vip_card
) t1 
left join (
  SELECT 
    member_card, 
    gender, 
    datediff(year,birth_date,GETDATE ()) as age, 
    prefer_city, 
    card_type, 
    datediff(day,register_date,GETDATE ()) as register_length 
  FROM 
    DWD.DIM_Member_Info 
  where 
    card_type != 9
) t2 on t1.vip_card = t2.member_card


--10.看过商品详情页次数 (unique天数)+map 到年龄，性别，城市，卡别，注册时长
delete from  [Test].[Events_Model_Feature_Metric_Test] where source='pdpview_times';
insert into Test.Events_Model_Feature_Metric_Test
select 
    t2.member_card, 
    pdpview_times as com_metric, 
    gender, 
    age, 
    prefer_city, 
    card_type, 
    register_length,
    'pdpview_times' as source,
    CURRENT_TIMESTAMP as insert_timestamp
from 
(
  SELECT 
    vip_card, 
    count(distinct(date)) as pdpview_times 
  from 
    [DW_Sensor].[DWS_Events_Session_Cutby30m]
  where 
    event ='ViewCommodityDetail' 
    and date between '2021-01-01' 
    and '2021-12-31' 
    and vip_card is not null 
    and date is not null 
  group by 
    vip_card
) t1 
left join 
(
  SELECT 
    member_card, 
    gender, 
    datediff(year,birth_date,GETDATE ()) as age, 
    prefer_city, 
    card_type, 
    datediff(day,register_date,GETDATE ()) as register_length 
  FROM 
    DWD.DIM_Member_Info 
  where 
    card_type != 9
) t2 on t1.vip_card = t2.member_card


--11加购物车次数by 种类拆开sap_department_description='COLOUR'+map 到年龄，性别，城市，卡别，注册时长
--12. 加购物车次数by 种类拆开sap_department_description='FRAGRANCE'+map 到年龄，性别，城市，卡别，注册时长
--13. 加购物车次数by 种类拆开sap_department_description='OTHERS' or is null+map 到年龄，性别，城市，卡别，注册时长 
--14. 加购物车次数by 种类拆开sap_department_description='SKINCARE'+map 到年龄，性别，城市，卡别，注册时长
delete from  [Test].[Events_Model_Feature_Metric_Test] where source NOT IN ('login_times','last_login_date_diff','pdpview_times','add_to_cart_count_exclusive');
insert into Test.Events_Model_Feature_Metric_Test
select 
    t2.member_card, 
    add_to_cart_count_colour as com_metric, 
    gender, 
    age, 
    prefer_city, 
    card_type, 
    register_length,
    coalesce(category,'NULL') as source,
    CURRENT_TIMESTAMP as insert_timestamp
from 
(
    SELECT 
        a.vip_card, 
        b.category,
        count(vip_card) as add_to_cart_count_colour 
    from 
        [STG_Sensor].[Events] a 
    left join 
    (
        select 
            sku_code,
            coalesce(category,'OTHERS') as category
        from DWD.DIM_SKU_Info 
    )b
    on a.commodity_sku collate SQL_Latin1_General_CP1_CI_AS = b.sku_code 
    where 
        vip_card is not null 
        and [event] in ('AddToShoppingcart','startAddToShoppingcart') 
        and a.date between '2021-01-01' and '2021-12-31' 
        and a.vip_card is not null 
    group by 
        a.vip_card ,category
) t1 
left join 
(
  SELECT 
    member_card, 
    gender, 
    datediff(year,birth_date,GETDATE()) as age, 
    prefer_city, 
    card_type, 
    datediff(day,register_date,GETDATE()) as register_length 
  FROM 
    DWD.DIM_Member_Info 
  where 
    card_type != 9
) t2 on t1.vip_card collate SQL_Latin1_General_CP1_CI_AS = t2.member_card

--15. 独家商品加购物车次数+map 到年龄，性别，城市，卡别，注册时长
delete from  [Test].[Events_Model_Feature_Metric_Test] where source='add_to_cart_count_exclusive';
insert into Test.Events_Model_Feature_Metric_Test
select 
    t2.member_card, 
    add_to_cart_count_exclusive as com_metric, 
    gender, 
    age, 
    prefer_city, 
    card_type, 
    register_length,
    'add_to_cart_count_exclusive' as source,
    CURRENT_TIMESTAMP as insert_timestamp
from 
(
  SELECT 
    a.vip_card, 
    count(vip_card) as add_to_cart_count_exclusive 
  from 
    STG_Sensor.Events a 
  left join 
  	dwd.DIM_SKU_Info b 
  on a.commodity_sku collate SQL_Latin1_General_CP1_CI_AS = b.sku_code 
  where 
    vip_card is not null 
    and [event] in ('AddToShoppingcart','startAddToShoppingcart')  
    and a.date between '2021-01-01' 
    and '2021-12-31' 
    and a.vip_card is not null 
    and SAP_Market_description = 'EXCLUSIVE' 
  group by 
    a.vip_card
) t1 
left join (
  SELECT 
    member_card, 
    gender, 
    datediff(year, birth_date, GETDATE ()) as age, 
    prefer_city, 
    card_type, 
    datediff(day, register_date,GETDATE ()) as register_length 
  FROM 
    DWD.DIM_Member_Info 
  where 
    card_type != 9
) t2 on t1.vip_card collate SQL_Latin1_General_CP1_CI_AS= t2.member_card
;
end 
GO
