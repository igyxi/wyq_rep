/****** Object:  StoredProcedure [RPT].[SP_RPT_AIPL_Purchase_Member]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_AIPL_Purchase_Member] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By           Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-08       wangzhichun          Initial Version
-- 2023-02-13       litao                Modify logic 
-- ========================================================================================

declare @statistics_date date 
SET @statistics_date = (select dateadd(day,1,@dt));

delete from [RPT].[RPT_AIPL_Purchase_Member] where statistics_month=format(@statistics_date,'yyyy-MM'); 
with sales_order_member_info as
(
select 
    distinct
     member_card
    ,case when sub_channel_name in (N'APP',N'APP(IOS)',N'APP(ANDROID)') then 'APP'
        when sub_channel_name in (N'ANNYMINIPROGRAM',N'MINIPROGRAM', N'WECHAT',N'BENEFITMINIPROGRAM') then 'MP'
        when sub_channel_name in (N'PC', N'MOBILE') then 'Web'
        when sub_channel_name in (N'抖音丝芙兰旗舰店') then 'Douyin'
        when sub_channel_name in (N'京东官方旗舰店', N'京东Gift',N'京东ECLP') then 'JD'
        when sub_channel_name in (N'天猫官方旗舰店', N'天猫WEI旗舰店',N'天猫国际',N'彼得罗夫官方旗舰店',N'天猫茶灵旗舰店') then 'Tmall'
        when sub_channel_name in (N'美团', N'O2O',N'点评',N'京东到家') then 'O2O'
        when sub_channel_name in (N'线下') then 'Offline'
        when sub_channel_name in (N'小红书旗舰店') then 'Red_Book'
        end as channel 
    ,case when sub_channel_name in (N'APP',N'APP(IOS)',N'APP(ANDROID)') then 'Purchase_App'
        when sub_channel_name in (N'ANNYMINIPROGRAM',N'MINIPROGRAM', N'WECHAT',N'BENEFITMINIPROGRAM') then 'Purchase_MP'
        when sub_channel_name in (N'PC', N'MOBILE') then 'Purchase_Web'
        when sub_channel_name in (N'抖音丝芙兰旗舰店') then 'Purchase_DY'
        when sub_channel_name in (N'京东官方旗舰店', N'京东Gift',N'京东ECLP') then 'Purchase_JD'
        when sub_channel_name in (N'天猫官方旗舰店', N'天猫WEI旗舰店',N'天猫国际',N'彼得罗夫官方旗舰店',N'天猫茶灵旗舰店') then 'Purchase_TM'
        when sub_channel_name in (N'美团', N'O2O',N'点评',N'京东到家') then 'Purchase_O2O'
        when sub_channel_name in (N'线下') then 'Purchase_Offline'
        when sub_channel_name in (N'小红书旗舰店') then 'Purchase_Red_Book'
        end as table_name 
from 
    DWD.Fact_Sales_Order 
where 
    format(payment_time,'yyyy-MM-dd') between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
    and member_card is not null
    and item_apportion_amount>0
    and is_smartba = 0
    and is_placed=1
    and sub_channel_name in (N'APP(IOS)',N'APP(ANDROID)',N'MINIPROGRAM', N'WECHAT',N'BENEFITMINIPROGRAM',N'PC', N'MOBILE',N'抖音丝芙兰旗舰店',N'京东官方旗舰店', N'京东Gift',N'京东ECLP',N'天猫官方旗舰店', N'天猫WEI旗舰店',N'天猫国际',N'彼得罗夫官方旗舰店',N'天猫茶灵旗舰店',N'美团', N'O2O',N'点评',N'京东到家',N'线下',N'APP',N'ANNYMINIPROGRAM',N'小红书旗舰店')
union all 
select 
distinct  
    member_card,
    'SmartBA' as channel,  
    'Purchase_SBA' as table_name
from 
    DWD.Fact_Sales_Order
where  format(payment_time,'yyyy-MM-dd') between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
    and member_card is not null
    and item_apportion_amount>0
    and is_smartba = 1
    and is_placed=1
)

insert into [RPT].[RPT_AIPL_Purchase_Member]
select 
  format(@statistics_date,'yyyy-MM') as statistics_month,
  t1.member_card,
  t1.channel,
  case when t2.card_type=0 then 'PINK' 
       when t2.card_type=1 then 'WHITE'
  end as card_type,
  t1.table_name,
  current_timestamp as insert_timestamp
from
   sales_order_member_info t1
left join
  (select 
       member_card,
       card_type 
     from
        (
         select 
              member_card,
              card_type,
              row_number() over (partition by member_card order by start_time desc) as ro
         from [DWD].[DIM_Member_Card_Grade_SCD]
         where 
             format(start_time,'yyyy-MM-dd') <= EOMONTH(DATEADD(month,-1,@statistics_date))
         ) temp
     where ro=1 
     and member_card is not null
     and card_type in (0,1)
  ) t2
on t1.member_card=t2.member_card
where t2.card_type is not null
;

END
GO
