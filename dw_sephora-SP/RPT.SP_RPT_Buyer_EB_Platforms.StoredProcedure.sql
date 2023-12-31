/****** Object:  StoredProcedure [RPT].[SP_RPT_Buyer_EB_Platforms]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Buyer_EB_Platforms] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-06       litao        Initial Version
-- ========================================================================================


truncate table RPT.RPT_Buyer_EB_Platforms;
insert into RPT.RPT_Buyer_EB_Platforms
select 
       t.place_date,
       t.place_year,
       t.place_month_first_day,
       t.channel_code,
       t.sub_channel_code,
       t.super_id,
       t.member_card,
       t.member_card_grade, 
       case when t.member_monthly_seq=1 then min(t.member_card_grade) over (partition by t.super_id,t.place_month_first_day,t.member_monthly_seq) else null end as monthly_member_card_type,
       case when t.member_yearly_seq=1 then min(t.member_card_grade) over (partition by t.super_id,t.place_year,t.member_yearly_seq) else null end as yearly_member_card_type,
       t.member_status,
       t.daily_member_status,
       t.monthly_member_status,
       t.yearly_member_status,
       t.sales_order_number,
       t.item_sku_code,
       t.sku_name,
       t.item_brand_type,
       case when t1.eb_category in ('SKINCARE','SKINCARE ACC','BATH','WELLNESS') then 'SKINCARE'
            when t1.eb_category in ('MAKE UP','MAKE UP ACC') then 'MAKE UP'
            when t1.eb_category in ('FRAGRANCE','FRAGRANCE ACC') then 'FRAGRANCE'
            when t1.eb_category in ('HAIR','HAIR ACC') then 'HAIR'
            else t1.eb_category
       end as category,
       t1.eb_category as category_detail,
       trim(t1.eb_brand_name) as brand,
       t.item_apportion_amount,
       t.item_quantity,
       current_timestamp as insert_timestamp
from 
(
 select 
       place_date,
       year(place_date) as place_year,
       format(place_date, 'yyyy-MM-01') as place_month_first_day,
       case
         when channel_code = 'SOA' then
          'DRAGON'
         when channel_code = 'DOUYIN' then
          'TIK TOK'
         when channel_code = 'REDBOOK' then
          'RED BOOK'
         else
          channel_code
       end as channel_code, --参考SP_RPT_Order_Statistics_Monthly逻辑
       case
         when sub_channel_code in ('APP', 'APP(IOS)', 'APP(ANDROID)') then
          'APP'
         when sub_channel_code in ('MINIPROGRAM') and smartba_flag = 1 then --smartba单独拆开 
          'SMART_BA'
         when sub_channel_code in ('MINIPROGRAM', 'ANNYMINIPROGRAM','BENEFITMINIPROGRAM', 'WECHAT') then
          'MNP'  
         when sub_channel_code in ('PC', 'WCS') then
          'PC'
         when sub_channel_code in ('MOBILE') then
          'MOBILE'
         when sub_channel_code in ('JD001', 'JD002') then
          'JD SEPHORA'
         when sub_channel_code = 'JD003' then
          'JD FCS'
         when sub_channel_code = 'TMALL001' then
          'TMALL SEPHORA'
         when sub_channel_code = 'TMALL006' then
          'TMALL WEI'
         when sub_channel_code = 'TMALL004' then
          'TMALL CHALING'
         when sub_channel_code = 'TMALL005' then
          'TMALL PTR'
         when sub_channel_code = 'DOUYIN001' then
          'TIK TOK'
         when sub_channel_code = 'O2O' then
          'O2O'
         when sub_channel_code = 'REDBOOK001' then
          'RED BOOK'
         else
          sub_channel_code
       end as sub_channel_code,--参考SP_RPT_Order_Statistics_Monthly逻辑
       super_id,
       member_card,
       case when member_card_grade in ('WHITE','NEW') THEN '2.WHITE'
            when member_card_grade='PINK'  then '1.PINK'
            when member_card_grade='BLACK' then '3.BLACK'
            when member_card_grade='GOLD'  then '4.GOLD'
            else null
       end as member_card_grade,
       member_new_status as member_status,
       member_daily_new_status as daily_member_status,
       member_monthly_new_status as monthly_member_status,
       member_yearly_new_status as yearly_member_status,
       sales_order_number,
       item_sku_code,
       item_name as sku_name,
       case when item_brand_type = 'OTHERS' then null when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE' else item_brand_type end item_brand_type,--参考SP_RPT_Order_Statistics_Monthly逻辑
       item_apportion_amount,
       item_quantity,
       is_placed,
       dense_rank() over(partition by super_id,format(place_date, 'yyyy-MM') order by place_time) as member_monthly_seq,
       dense_rank() over(partition by super_id,year(place_time) order by place_time) as member_yearly_seq
  from RPT.RPT_Sales_Order_VB_Level
 where is_placed = 1
   and item_apportion_amount>0
 ) t  
left join 
      DWD.DIM_SKU_Info t1
on t.item_sku_code = t1.sku_code 
;

END
GO
