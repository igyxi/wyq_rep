/****** Object:  StoredProcedure [RPT].[SP_RPT_OMS_Sales_Order_Statitics_By_Warehouse]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_OMS_Sales_Order_Statitics_By_Warehouse] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-10       litao          Initial Version
-- ========================================================================================

delete from [RPT].[RPT_OMS_Sales_Order_Statitics_By_Warehouse] where dt=@dt;
insert into [RPT].[RPT_OMS_Sales_Order_Statitics_By_Warehouse]
select 
  statistics_date  
  ,sum(case when warehouse='SH' then order_qty end) as sh_order_quantity
  ,sum(case when warehouse='BJ' then order_qty end) as bj_order_quantity 
  ,sum(case when warehouse='GZ' then order_qty end) as gz_order_quantity
  ,sum(case when warehouse='CD' then order_qty end) as cd_order_quantity
  ,sum(order_qty) as total_order_quantity
  ,order_flag
  ,@dt as dt
  ,current_timestamp as insert_timestamp
from 
  (select
       format(p.place_time,'yyyy-MM-dd') as statistics_date
      ,p.actual_warehouse as warehouse
      ,count(distinct p.purchase_order_number) as order_qty
      ,'Split_PO_Orders' as order_flag
  from 
      [DWD].[Fact_Sales_Order] p
  inner join
  (
      select 
          distinct sales_order_number
      from 
         [RPT].[RPT_Sales_Order_Basic_Level]
      where  
          split_flag = 1
      and is_placed = 1
      and sub_channel_code not in ('TMALL002','GWP001','REDBOOK001')
  ) t
  on 
    p.sales_order_number = t.sales_order_number
  where   
      format(p.place_time,'yyyy-MM-dd') = @dt
      -- format(place_time,'yyyy-MM-dd')>='2022-01-01'
      --and format(place_time,'yyyy-MM-dd')<'2023-01-01'
      and p.sub_channel_code not in ('JDDJ','MEITUAN','GWP001','OFF_LINE','REDBOOK001','S001','TMALL002','DIANPING')
      and p.actual_warehouse in ('SH','GZ','CD','BJ')
  group by 
        format(p.place_time,'yyyy-MM-dd'),
        p.actual_warehouse
union all
  select
       format(p.place_time,'yyyy-MM-dd') as statistics_date
      ,p.actual_warehouse as warehouse
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
      and sub_channel_code not in ('TMALL002','GWP001','REDBOOK001')
  ) t
  on 
    p.sales_order_number = t.sales_order_number
  where   
      format(p.place_time,'yyyy-MM-dd') = @dt
	  -- format(place_time,'yyyy-MM-dd')>='2022-01-01'
      --and format(place_time,'yyyy-MM-dd')<'2023-01-01'
      and p.sub_channel_code not in ('JDDJ','MEITUAN','GWP001','OFF_LINE','REDBOOK001','S001','TMALL002','DIANPING')
      and p.actual_warehouse in ('SH','GZ','CD','BJ')
  group by 
        format(p.place_time,'yyyy-MM-dd'),
        p.actual_warehouse 
  ) PO
  group by 
        statistics_date,
        order_flag
;

END
GO
