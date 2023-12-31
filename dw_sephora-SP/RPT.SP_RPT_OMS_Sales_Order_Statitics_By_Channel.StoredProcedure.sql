/****** Object:  StoredProcedure [RPT].[SP_RPT_OMS_Sales_Order_Statitics_By_Channel]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_OMS_Sales_Order_Statitics_By_Channel] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-10       litao          Initial Version
-- 2023-03-07       litao          O2O订单合并到官网
-- ========================================================================================

--Split_SO_Orders
--SO_Orders
delete from [RPT].[RPT_OMS_Sales_Order_Statitics_By_Channel] where dt=@dt and order_flag in ('Split_SO_Orders','SO_Orders');
insert into [RPT].[RPT_OMS_Sales_Order_Statitics_By_Channel]
select 
  statistics_date 
  ,sum(case when sub_channel_code='DOUYIN001' then order_qty end) as tiktok_order_quantity
  ,sum(case when sub_channel_code in ('JD001','JD002') then order_qty end) as jd_fss_order_quantity
  ,sum(case when sub_channel_code='JD003' then order_qty end) as jd_fcs_order_quantity
  ,sum(case when sub_channel_code in ('ANNYMINIPROGRAM','APP','APP(ANDROID)','APP(IOS)','BENEFITMINIPROGRAM','MINIPROGRAM','MOBILE','PC','WCS','WECHAT','O2O') then order_qty end) as drogan_order_quantity
  ,null as o2o_order_quantity
  --,sum(case when sub_channel_code='O2O' then order_qty end) as o2o_order_quantity
  ,sum(case when sub_channel_code='TMALL001' then order_qty end) as tmall_order_quantity
  ,sum(case when sub_channel_code='TMALL004' then order_qty end) as tmall_chaling_order_quantity
  ,sum(case when sub_channel_code='TMALL005' then order_qty end) as tmall_ptr_order_quantity
  ,sum(case when sub_channel_code='TMALL006' then order_qty end) as tmall_wei_order_quantity 
  ,sum(order_qty) as total_order_quantity
  ,order_flag 
  ,@dt as dt
  ,current_timestamp as insert_timestamp
from 
  (select  
       format(place_time,'yyyy-MM-dd') as statistics_date
       ,channel_code
       ,sub_channel_code 
       ,count(distinct sales_order_number) as order_qty
       ,'Split_SO_Orders' as order_flag 
   from  
       [RPT].[RPT_Sales_Order_Basic_Level]
  where  
      format(place_time,'yyyy-MM-dd') = @dt
      -- format(place_time,'yyyy-MM-dd')>='2022-01-01'
      --and format(place_time,'yyyy-MM-dd')<'2023-03-06'
      and  is_placed = 1
      and  split_flag = 1
      and  sub_channel_code not in ('TMALL002','GWP001','REDBOOK001')
  group by 
        format(place_time,'yyyy-MM-dd'),
        channel_code,
        sub_channel_code
union  all
  select  
      format(place_time,'yyyy-MM-dd') as statistics_date
      ,channel_code
      ,sub_channel_code
      ,count(distinct sales_order_number) as order_qty
      ,'SO_Orders' as order_flag
  from  
     [RPT].[RPT_Sales_Order_Basic_Level]
  where  
      format(place_time,'yyyy-MM-dd') = @dt
      -- format(place_time,'yyyy-MM-dd')>='2022-01-01'
      --and format(place_time,'yyyy-MM-dd')<'2023-03-06'
      and  is_placed = 1
      and  sub_channel_code not in ('TMALL002','GWP001','REDBOOK001')
  group by 
         format(place_time,'yyyy-MM-dd'),
         channel_code,
         sub_channel_code
  ) SO 
group by  
      statistics_date
     ,order_flag
;

--Split_PO_Orders
--PO_Orders
delete from [RPT].[RPT_OMS_Sales_Order_Statitics_By_Channel] where dt=@dt and order_flag in ('Split_PO_Orders','PO_Orders');
insert into [RPT].[RPT_OMS_Sales_Order_Statitics_By_Channel]
select 
  statistics_date 
  ,sum(case when sub_channel_code='DOUYIN001' then order_qty end) as tik_tok_order_quantity
  ,sum(case when sub_channel_code in ('JD001','JD002') then order_qty end) as jd_fss_order_quantity
  ,sum(case when sub_channel_code='JD003' then order_qty end) as jd_fcs_order_quantity
  ,sum(case when sub_channel_code in ('ANNYMINIPROGRAM','APP','APP(ANDROID)','APP(IOS)','BENEFITMINIPROGRAM','MINIPROGRAM','MOBILE','PC','WECHAT','O2O') then order_qty end) as drogan_order_quantity
  ,null as o2o_order_quantity
  --,sum(case when sub_channel_code='O2O' then order_qty end) as o2o_order_quantity
  ,sum(case when sub_channel_code='TMALL001' then order_qty end) as tmall_order_quantity
  ,sum(case when sub_channel_code='TMALL004' then order_qty end) as tmall_chaling_order_quantity
  ,sum(case when sub_channel_code='TMALL005' then order_qty end) as tmall_ptr_order_quantity
  ,sum(case when sub_channel_code='TMALL006' then order_qty end) as tmall_wei_order_quantity
  ,sum(order_qty) as total_order_quantity
  ,order_flag
  ,@dt as dt
  ,current_timestamp as insert_timestamp
from 
  (
  select  
      format(p.place_time,'yyyy-MM-dd') as statistics_date
      ,p.channel_code
      ,p.sub_channel_code
      ,count(distinct p.purchase_order_number) as order_qty
      ,'Split_PO_Orders' as order_flag
  from  
     [DWD].[Fact_Sales_Order] p
  inner  join
  (
      select  distinct sales_order_number
      from  [RPT].[RPT_Sales_Order_Basic_Level]
      where  split_flag = 1
      and  is_placed = 1
      and  sub_channel_code not in ('TMALL002','GWP001','REDBOOK001')
  ) t
  on 
      p.sales_order_number = t.sales_order_number
  where  
      format(p.place_time,'yyyy-MM-dd') = @dt
      -- format(place_time,'yyyy-MM-dd')>='2022-01-01'
      --and format(place_time,'yyyy-MM-dd')<'2023-03-06'
      and p.sub_channel_code not in ('JDDJ','MEITUAN','GWP001','OFF_LINE','REDBOOK001','S001','TMALL002','DIANPING')
  group by 
        format(p.place_time,'yyyy-MM-dd'),
        p.channel_code,
        p.sub_channel_code
union all
  select  
      format(p.place_time,'yyyy-MM-dd') as statistics_date
      ,p.channel_code
      ,p.sub_channel_code
      ,count(distinct p.purchase_order_number) as order_qty
      ,'PO_Orders' as order_flag
  from  
     [DWD].[Fact_Sales_Order] p
  inner join
  (
      select  
           distinct sales_order_number
      from 
          [RPT].[RPT_Sales_Order_Basic_Level]
      where 
          is_placed = 1
          and  sub_channel_code not in ('TMALL002','GWP001','REDBOOK001')
  ) t
  on 
     p.sales_order_number = t.sales_order_number
  where   
      format(p.place_time,'yyyy-MM-dd') = @dt
      -- format(place_time,'yyyy-MM-dd')>='2022-01-01'
      --and format(place_time,'yyyy-MM-dd')<'2023-03-06'
      and p.sub_channel_code not in ('JDDJ','MEITUAN','GWP001','OFF_LINE','REDBOOK001','S001','TMALL002','DIANPING')
  group by 
        format(p.place_time,'yyyy-MM-dd'),
        p.channel_code,
        p.sub_channel_code
  ) PO
group by  
      statistics_date
     ,order_flag
;

END

GO
