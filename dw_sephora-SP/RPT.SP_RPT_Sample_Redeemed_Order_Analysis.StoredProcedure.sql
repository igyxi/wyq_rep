/****** Object:  StoredProcedure [RPT].[SP_RPT_Sample_Redeemed_Order_Analysis]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sample_Redeemed_Order_Analysis] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-28       litao        Initial Version
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

truncate table [RPT].[RPT_Sample_Redeemed_Order_Analysis];
--活动正装商品，一对多
with dim_activity_normal_sku_info as
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
    a.normal_sku_id     
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
,
---指标逻辑计算
sample_redeemed as 
(
    select
         activity_id,
         activity_name,
         activity_type,
         sku_code,
         limit_count,
         start_time,
         end_time,
         category,
         brand,
         normal_skus,
         count(distinct member_card) as redeemed_user,
         sum(item_quantity) as redeemed_sample_quantity,
         count(distinct case when new_member_flag=1 then member_card end) as redeemed_new_user --New pink user
    from 
    [rpt].[rpt_sample_redeemed_order_detail]
    group by activity_id,
         activity_name,
         activity_type,
         sku_code,
         limit_count,
         start_time,
         end_time,
         category,
         brand,
         normal_skus
)  
,
sample_normal_skus_repurchase as --3M正装商品复购
(
    select
        t.activity_id,
        count(distinct t1.member_card) as sku_repurchase_user,
        count(distinct t1.sales_order_number) as sku_repurchase_order,
        sum(t1.item_apportion_amount) as sku_repurchase_amount,
        sum(t1.item_quantity) as sku_repurchase_quantity,
        count(distinct case when t.new_member_flag=1 then t1.member_card end) as sku_repurchase_new_user,
        sum(case when t.new_member_flag=1 then t1.item_apportion_amount else 0 end) as new_user_sku_repurchase_amount
    from
        (
        select
            distinct 
            activity_id,
            member_card,
            new_member_flag
        from
            [rpt].[rpt_sample_redeemed_order_detail]
        ) t
    left join 
    (
        select
            distinct 
            a.place_date,
            a.place_time,
            a.item_sku_code,
            a.member_card,
            a.item_quantity,
            a.sales_order_number,
            a.item_apportion_amount,
            b.activity_id
        from
            RPT.RPT_Sales_Order_VB_Level a
        inner join 
            (
             select
                 distinct activity_id,
                 normal_sku_id,
                 end_date,
                 end_date_3m
             from
                 dim_activity_normal_sku_info
            ) b 
        on a.item_sku_code = b.normal_sku_id
        where
            a.place_date >@min_end_date
            and a.place_date <= @max_end_date_3m
            and a.place_date>b.end_date
            and a.place_date <= b.end_date_3m
            and a.is_placed = 1 
      ) t1
    on
        t.activity_id = t1.activity_id
        and t.member_card = t1.member_card
    group by t.activity_id
) 
,
sample_brand_repurchase as --3M品牌复购
(
    select
        t.activity_id,
        count(distinct t1.member_card) as brand_repurchase_user,
        count(distinct t1.sales_order_number) as brand_repurchase_order,
        sum(t1.item_apportion_amount) as brand_repurchase_amount,
        sum(t1.item_quantity) as brand_repurchase_quantity
    from
        (
        select
            distinct 
            activity_id,
            brand,
            member_card,
            end_date,
            end_date_3m
        from
            [rpt].[rpt_sample_redeemed_order_detail]
        ) t
    left join 
       (
        select
            distinct 
            place_date,
            place_time,
            item_sku_code,
            member_card,
            item_quantity,
            sales_order_number,
            item_apportion_amount,
            item_brand_name as brand
        from
            RPT.RPT_Sales_Order_VB_Level
        where
             place_date >@min_end_date
            and place_date <= @max_end_date_3m
            and is_placed = 1 
         ) t1
    on  t.brand = t1.brand
    and t.member_card = t1.member_card
    and t1.place_date>t.end_date
    and t1.place_date<=t.end_date_3m
    group by t.activity_id
) 

insert into [RPT].[RPT_Sample_Redeemed_Order_Analysis] 
select
    t.activity_id,
    t.activity_name,
    t.activity_type,
    t.start_time,
    t.end_time,
    t.sku_code,
    t.limit_count, 
    t.category,
    t.brand,
    t.normal_skus,
    coalesce(t.redeemed_user,0) as redeemed_user,
    coalesce(t.redeemed_sample_quantity,0) as redeemed_sample_quantity,
    coalesce(t.redeemed_new_user,0) as redeemed_new_user,
    coalesce(t1.sku_repurchase_user,0) as sku_repurchase_user,
    coalesce(t1.sku_repurchase_order,0) as sku_repurchase_order,
    coalesce(t1.sku_repurchase_amount,0) as sku_repurchase_amount,
    coalesce(t1.sku_repurchase_quantity,0) as sku_repurchase_quantity,
    coalesce(t1.sku_repurchase_new_user,0) as sku_repurchase_new_user,
    coalesce(t1.new_user_sku_repurchase_amount,0) as new_user_sku_repurchase_amount,
    coalesce(t2.brand_repurchase_user,0) as brand_repurchase_user,
    coalesce(t2.brand_repurchase_order,0) as brand_repurchase_order,
    coalesce(t2.brand_repurchase_amount,0) as brand_repurchase_amount,
    coalesce(t2.brand_repurchase_quantity,0) as brand_repurchase_quantity,
    CURRENT_TIMESTAMP as insert_timestamp
from
    sample_redeemed t
left join 
   sample_normal_skus_repurchase t1 
on
    t.activity_id = t1.activity_id
left join 
   sample_brand_repurchase t2 
on
   t.activity_id = t2.activity_id;
;

END


 
GO
