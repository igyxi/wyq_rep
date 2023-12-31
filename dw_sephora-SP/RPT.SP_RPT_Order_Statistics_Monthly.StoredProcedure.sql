/****** Object:  StoredProcedure [RPT].[SP_RPT_Order_Statistics_Monthly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Order_Statistics_Monthly] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-30       houshuangqiang        Initial Version
-- 2023-02-02       houshuangqiang        MNP渠道指标统计包含SMART_BA统计指标，SMART_BA统计指标单独计算
-- 2023-02-10       litao                 add column brand_type、Item_quantiy
-- 2023-02-28       litao                 add sub_channel_brand_month、sub_channel_brand_status_month、sub_channel_brand_membership_month 
-- 2023-03-23       litao                 add item_type <> 'GWP'
-- ========================================================================================
 

delete from [RPT].[RPT_Order_Statistics_Monthly] where format(dt, 'yyyy-MM') = format(@dt, 'yyyy-MM');
insert  into [RPT].[RPT_Order_Statistics_Monthly]
-- 1.1 by channel 统计
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,null as sub_channel_code
        ,null as brand_type
        ,null as member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'channel_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
-- 1.2 by channel by card type 统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,null as sub_channel_code
        ,null as brand_type
        ,null as member_monthly_new_status
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
        end as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'channel_membership_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
        end
-- 1.3 by channel by buyer status 统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,null as sub_channel_code
        ,null as brand_type
        ,member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'channel_status_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM'),member_monthly_new_status
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end
-- 1.4 by channel by brand type by month 统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,null as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,null as member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'channel_brand_type_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM')
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end
-- 1.5 by channel by brand type by month by member_monthly_new_status 统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,null as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'channel_brand_type_status_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM'),member_monthly_new_status
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end
-- 1.6 by channel by brand type by membership  by month 统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,null as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,null as member_monthly_new_status
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
         end as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'channel_brand_type_membership_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM')
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
         end       
-- 2.1 by sub_channel  统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
         end as sub_channel_code
        ,null as brand_type
        ,null as member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
        end
-- 2.2 by sub_channel by card type  统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
         end as sub_channel_code
        ,null as brand_type
        ,null as member_monthly_new_status
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
        end as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_membership_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
        end
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
        end
-- 2.3 by sub_channel by buyer status
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
         end as sub_channel_code
        ,null as brand_type
        ,member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_status_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
group   by format(place_date, 'yyyy-MM'),member_monthly_new_status
        ,case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
        end

------------------------------------------------------------------------------
--  3. 单独计算 SMART_BA的统计指标, 属于2.x中 MNP的子集
--  3.1 smart_ba by sub_channel  统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,'SMART_BA' as sub_channel_code
        ,null as brand_type
        ,null as member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     sub_channel_code = 'MINIPROGRAM'
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
and     is_placed = 1
and     smartba_flag = 1
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
-- 3.2 smart_ba by sub_channel by card type  统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,'SMART_BA' as sub_channel_code
        ,null as brand_type
        ,null as member_monthly_new_status
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
        end as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_membership_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     sub_channel_code = 'MINIPROGRAM'
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
and     is_placed = 1
and     smartba_flag = 1
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
        end
-- 3.3 smart_ba by sub_channel by buyer status
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,'SMART_BA' sub_channel_code
        ,null as brand_type
        ,member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_status_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     sub_channel_code = 'MINIPROGRAM'
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
and     is_placed = 1
and     smartba_flag = 1
group   by format(place_date, 'yyyy-MM'),member_monthly_new_status
        ,case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
---------------------------------20230228新增-------------------------------------------------------
-- 2.4 by sub_channel by brand
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
         end as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,null as member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_brand_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and item_type <> 'GWP'
and     sub_channel_code not in ('TMALL002','GWP001')
group   by format(place_date, 'yyyy-MM')
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
        ,case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
        end
-- 2.5 by sub_channel by brand by status
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
         end as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,member_monthly_new_status as member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_brand_status_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and item_type <> 'GWP'
and     sub_channel_code not in ('TMALL002','GWP001')
group   by format(place_date, 'yyyy-MM')
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
        ,case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
        ,member_monthly_new_status
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
        end
-- 2.6 by sub_channel by brand by membership
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
         end as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,null as member_monthly_new_status
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
         end as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_brand_membership_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     is_placed = 1
and item_type <> 'GWP'
and     sub_channel_code not in ('TMALL002','GWP001')
group   by format(place_date, 'yyyy-MM')
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
        ,case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
        end
        ,case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
              when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP' -- -- 包含smartba中的订单数据
              when sub_channel_code in ('PC','WCS') then 'PC'
              when sub_channel_code in ('MOBILE') then 'MOBILE'
              when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
              when sub_channel_code ='JD003' then 'JD FCS'
              when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
              when sub_channel_code = 'TMALL006' then 'TMALL WEI'
              when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
              when sub_channel_code = 'TMALL005' then 'TMALL PTR'
              when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
              when sub_channel_code = 'O2O' then 'O2O'
              when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
              else sub_channel_code
        end 
--  3.4 smart_ba by sub_channel by brand  统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,'SMART_BA' as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,null as member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_brand_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     sub_channel_code = 'MINIPROGRAM'
and     sub_channel_code not in ('TMALL002','GWP001')
and     is_placed = 1
and item_type <> 'GWP'
and     smartba_flag = 1
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end,
        case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end
--  3.5 smart_ba by sub_channel by brand by status 统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,'SMART_BA' as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,member_monthly_new_status as member_monthly_new_status
        ,null as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_brand_status_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     sub_channel_code = 'MINIPROGRAM'
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
and     is_placed = 1
and     smartba_flag = 1
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end,
        member_monthly_new_status,
        case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end
--  3.6 smart_ba by sub_channel by brand by membership 统计
union   all
select  format(place_date, 'yyyy-MM') as statistics_month
        ,case when channel_code = 'SOA' then 'DRAGON'
              when channel_code = 'DOUYIN' then 'TIK TOK'
              when channel_code = 'REDBOOK' then 'RED BOOK'
              else channel_code
        end as channel_code
        ,'SMART_BA' as sub_channel_code
        ,case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
         else item_brand_type end brand_type
        ,null as member_monthly_new_status
        ,case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
         end as member_card_grade
        ,count(distinct super_id) as buyers_number
        ,count(distinct sales_order_number) as orders_number
        ,sum(item_apportion_amount) as sales_amount
        ,sum(item_quantity) as item_quantity
        ,'sub_channel_brand_membership_month' as metric_flag
        ,@dt as dt
        ,current_timestamp as insert_timestamp
from    RPT.RPT_Sales_Order_VB_Level
where   format(place_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
and     sub_channel_code = 'MINIPROGRAM'
and     sub_channel_code not in ('TMALL002','GWP001')
and item_type <> 'GWP'
and     is_placed = 1
and     smartba_flag = 1
group   by format(place_date, 'yyyy-MM'),
        case when channel_code = 'SOA' then 'DRAGON'
             when channel_code = 'DOUYIN' then 'TIK TOK'
             when channel_code = 'REDBOOK' then 'RED BOOK'
             else channel_code
        end,
        case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
              when member_card_grade in ('PINK', 'BLACK', 'GOLD') then member_card_grade
              else null  -- 存在EMPLOYEE和TEST的类型
        end,
        case when item_brand_type= 'OTHERS' then null 
              when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end

END
GO
