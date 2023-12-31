/****** Object:  StoredProcedure [RPT].[SP_RPT_Sample_Redeemed_Order_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sample_Redeemed_Order_Detail] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-28       litao        Initial Version
-- 2023-05-06       litao        Sampling中redeem如果是从VB_Level表中取数的，将is_placed=1调整为payment_status=1 and payment_time is not null and order_status <> 'CANCELLED'（复购不做调整，仍用is_placed=1）
-- ========================================================================================


---获取活动开始&结束时间参数

DECLARE @start_date DATE
DECLARE @end_date DATE
DECLARE @max_end_date_3m DATE
DECLARE @min_end_date DATE

select 
    @start_date=min(cast(start_time as date)),--活动最早开始时间
    @end_date=max(cast(end_time as date)),--活动最晚结束时间
    @max_end_date_3m=max(dateadd(mm,3,cast(end_time as date))), --活动结束最晚3M后日期
    @min_end_date=min(cast(end_time as date)) --活动结束最早日期
from 
  dwd.dim_gift_event
where normal_skus is not null
and normal_skus<>''
and limit_count is not null;


truncate table [RPT].[RPT_Sample_Redeemed_Order_Detail];
--活动信息处理 
with dim_activity_info as 
(
select
    distinct 
    a.activity_id,      --活动id
    a.activity_name,    --活动名称 
    a.activity_type,    --活动类型
    a.start_time,       --活动开始时间
    a.end_time,         --活动结束时间
    a.end_date,         --活动结束日期
    a.end_date_3m,      --结束后3个月
    a.sku_code,         --活动小样sku_code 
    a.normal_skus,      --活动正装商品
    coalesce(b.eb_category,b.sap_category_description) as category,--正装商品对应的品类
    coalesce(b.eb_brand_name,b.sap_brand_name) as brand, --正装商品对应的品牌  
    a.limit_count       --活动商品份数
from 
(
  select
      event_id as activity_id,
      event_name as activity_name,
      case 
          when event_type = 1 then N'分享'
          when event_type = 0 then N'直接领取'
      end as activity_type,
      start_time,
      end_time,
      cast(end_time as date) as end_date,
      dateadd(mm,3,cast(end_time as date)) as end_date_3m,
      sku_code,
      limit_count,
      replace(normal_skus,char(10),'') as normal_skus,
      trim(trim(replace(v.value,char(10),''))) as normal_sku_id
  from
      dwd.dim_gift_event
      cross apply string_split(coalesce(replace(normal_skus,char(10),''),''),';') as v 
  where normal_skus is not null
  and normal_skus<>''
  and limit_count is not null
) a
left join 
      dwd.dim_sku_info b 
on 
  a.normal_sku_id=b.sku_code
)

--活动小样订单
insert into RPT.RPT_Sample_Redeemed_Order_Detail
select
      distinct
      t.activity_id,
      t.activity_name,
      t.activity_type,
      t.sku_code,
      t.limit_count,
      t.start_time,
      t.end_time,
      t.end_date,
      t.end_date_3m, 
      t.category,
      t.brand,
      t.normal_skus,
      t1.member_card,
      t1.place_date,
      t1.sales_order_number,
      t1.item_quantity,
      case when t2.register_date>=cast(t.start_time as date) and t2.register_date<=cast(t.end_time as date) then 1 else 0 end as new_member_flag,
      CURRENT_TIMESTAMP as insert_timestamp
  from
      dim_activity_info t 
  left join 
  (
      select
          distinct 
          place_date,
          place_time,
          item_sku_code,
          member_card,
          item_quantity,
          sales_order_number
      from
          RPT.RPT_Sales_Order_VB_Level --小样订单
      where
          place_date >= @start_date
          and place_date <= @end_date
          --and is_placed = 1 
		  and payment_status=1 
		  and payment_time is not null
		  and order_status <> 'CANCELLED'
  ) t1
      on t.sku_code = t1.item_sku_code
      and t1.place_time >= t.start_time
      and t1.place_time <= t.end_time 
  left join 
      DWD.DIM_Member_Info t2  --判断小样订单用户注册时间是否在活动期间
  on t1.member_card=t2.member_card
;

END




GO
