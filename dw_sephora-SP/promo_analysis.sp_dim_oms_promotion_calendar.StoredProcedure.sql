/****** Object:  StoredProcedure [promo_analysis].[sp_dim_oms_promotion_calendar]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [promo_analysis].[sp_dim_oms_promotion_calendar] AS
--Created by Anne on 2022-11-22 for promotion analysis project
--Modify by yaozhipeng  change source table to ODS_Promotion
begin
truncate table promo_analysis.dim_promotion_step1;
insert into promo_analysis.dim_promotion_step1
select promotion.promotion_sys_id
      ,order_promotion.crm_coupon_code as used_coupon_code
	  ,coupon.crm_promotion_code as crm_coupon_code
      ,promotion.promotion_name
      ,case when promotion.promotion_type=1 then N'单品折扣'
			when promotion.promotion_type=2 then N'单品买赠'
			when promotion.promotion_type=3 then N'组合满减'
		    when promotion.promotion_type=4 then N'组合满赠'
			when promotion.promotion_type=5 then N'固定运费'
			when promotion.promotion_type=6 then N'订单满减'
			when promotion.promotion_type=7 then N'订单满赠'
			when promotion.promotion_type=8 then N'超值换购'
	    end as promotion_type
	  ,case when REL_TYPE=1 then 'SKU'
	        when REL_TYPE=2 then 'Category'
	        when REL_TYPE=3 then 'Brand'
	   end as promotion_rel_type
	  ,case when REL_TYPE=1 and group_level=1 then N'普通商品 '
			when REL_TYPE=1 and group_level=3 then N'预售商品 '
			when REL_TYPE=1 and group_level=4 then N'定金商品 '
			when REL_TYPE=1 and group_level=5 then N'赠品'
			when REL_TYPE=1 and group_level=6 then N'VS套装'
			when REL_TYPE=2 and group_level=1 then N'一级分类'
	        when REL_TYPE=2 and group_level=2 then N'二级分类'
			when REL_TYPE=2 and group_level=3 then N'三级分类'
			when REL_TYPE=3 and group_level=1 then N'品牌'
			when REL_TYPE=3 and group_level=1 then N'系列'			
		end as promotion_group_lvl
	  ,case when INCLUDE=0 then 0 else 1 end as include
	  ,case 
	        when promotion.promotion_type=5  then N'固定运费'
			when promotion.promotion_name like N'%生日%'  then N'生日'
			when promotion_offer.type=1--减
			     and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type')in (1,2) then N'满额减'--满额
			when promotion_offer.type=1--减
			     and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type')in (3,4) then N'满件减'--满件
			when promotion_offer.type=1 then N'减' 
			when promotion_offer.type=2 --折
			     and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type')=1--满额
			then N'满额折'
	        when promotion_offer.type=2 --折
			     and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type')=3
				 and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.minValue')>1--满1件以上
			then N'满件折'
			when promotion_offer.type=2 --折
			     and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type')=3
				 and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.minValue')<=1
			then N'无门槛折'
			when promotion.promotion_type=1 then N'单品折扣' --'单品折扣' 
			when promotion_offer.type=2 then N'折'
            when promotion.promotion_name like N'%折%' then N'折'
			when promotion_offer.type=3 --赠
			     and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type')=1--满额
			then N'满额赠'
			when promotion_offer.type=3 --赠
			     and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type')=2--满件
				 and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.minValue')>1
			then N'满件赠'	
			when promotion_offer.type=3 --赠
			     and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type')=2--满件
				 and JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.minValue')<=1
			then N'无门槛赠'	
			when promotion.promotion_type=2 then N'单品买赠' --'单品买赠'
			when promotion.promotion_type=8 then N'超值换购'
			else N'其它'
		end as promotion_tag
      --,promotion.order_type--1-普通，2-定金预售，3-全额预售
	  ,promotion.use_type--促销方法    - 限定购买（不试用coupon）--0    - 促销代码（公共Coupon）--1    - 赠券促销（私有coupon）--2
      ,promotion.exclude_discount --1  排除折扣 0  不排除折扣
      ,promotion.combination_type--组合促销间的关系：        1  同享       2  互斥
	  ,promotion.combination_coupon--是否与赠券促销共享:   0:不共享    1:共享
      ,promotion.priority
      ,promotion.start_time --Promotion开始时间
      ,promotion.end_time--Promotion结束时间
	  --适用卡别
	  ,case when convert(varchar(4000),promotion.customer_group,0) like '%PINK%' then 1
            else 0 
	   end as is_valid_pink
	  ,case when convert(varchar(4000),promotion.customer_group,0) like '%WHITE%' then 1
            else 0 
	   end as is_valid_white
	  ,case when convert(varchar(4000),promotion.customer_group,0) like '%BLACK%' then 1
            else 0 
	   end  as is_valid_black
	  ,case when convert(varchar(4000),promotion.customer_group,0) like '%GOLDEN%' then 1
            else 0 
	   end as is_valid_gold
	  ,case when convert(varchar(4000),promotion.customer_group,0) like '%EMPLOYEE%' then 1
            else 0 
	   end as is_valid_employee
	   --适用渠道
	  ,case when convert(varchar(4000),promotion.channel_id,0) like '%PC%' then 1
            else 0 
	   end as is_valid_pc
	  ,case when convert(varchar(4000),promotion.channel_id,0) like '%MOBILE%' then 1
            else 0 
	   end as is_valid_mobile
	   ,case when convert(varchar(4000),promotion.channel_id,0) like '%APP%' then 1
            else 0 
	   end as is_valid_app
	   ,case when convert(varchar(4000),promotion.channel_id,0) like '%WECHAT%' then 1
            else 0 
	   end as is_valid_wechat
	    ,case when convert(varchar(4000),promotion.channel_id,0) like '%O2O%' then 1
            else 0 
	   end as is_valid_ebo2o
	    ,case when convert(varchar(4000),promotion.channel_id,0) like '%MINIPROGRAM%' then 1
            else 0 
	     end as is_valid_miniprogram
	    ,case when convert(varchar(4000),promotion.channel_id,0) like '%ANNYMINIPROGRAM%' then 1
            else 0 
	     end as is_valid_annyminiprogram
      ,1 as is_soa
	  ,promotion.isAllProduct--1   是全场 0   不是全场
	  --,sku_discount.sku_code
	  --,sku_discount.sku_name
	  --,case when promotion.isAllProduct=1 then 'ALL' 
	  --      when promotion.isAllProduct=0 then sku_discount.sku_code
	  -- end as sku_code
	  ,isnull(promotion_rel.OUT_KEY,sku_discount.sku_code) as sku_code
	  --,case when promotion.isAllProduct=1 then 'ALL' 
	  --      when  promotion.isAllProduct=0 then sku_discount.range
	  -- end as range

	  ,promotion.status--0--草稿 1--待审核 2--审核失败 3--待处理 4--已发布 5--停止
      ,promotion.create_time
      ,promotion.update_time
      ,promotion.origin
      ,promotion.code_type
	  ,promotion.dt
      --,promotion.insert_timestamp
	  --Promotion机制
	  ,convert(varchar(4000),promotion_offer.promotion_condition,0)
	  ,case when JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.minValue')>0 then 1
	        when promotion.promotion_type=1 then 1--单品折扣 
			when promotion.promotion_type=2 then 1 --'单品买赠'
            else 0 
	   end as has_threshold
	  ,case when promotion_offer.type=1 then 1
            else 0 
	   end  as has_reduce
	  ,case when promotion_offer.type=2 then 1
            else 0 
	   end as has_pct
	  ,case when promotion_offer.type=3 then 1
            else 0 
	   end as has_gift
	  ,case when promotion_offer.type=1 then cast(replace(convert(varchar(4000),offer,0),'"','') as float)
            else 0.0 
	   end  as reduce
	  ,case when promotion_offer.type=2 then 1-cast(convert(varchar(4000),offer,0) as float)
         	else 1-cast (isnull(sku_discount.discount,10.0) as float)*0.1 
	   end as pct
	  --,case when promotion_offer.type=3 then JSON_query(promotion_offer.offer,'$.giftModels')
   --    else '' 
	  -- end as has_gift
	  ,promotion_offer.type as promotion_offer_type
	  ,JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.type') as promotion_condition_type
      ,JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.limit') as promotion_condition_limit
      ,JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.maxValue') as promotion_condition_maxValue
      ,case when JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.minValue')>0 then JSON_VALUE(convert(varchar(4000),promotion_offer.promotion_condition,0),'$.minValue')
	  	    when promotion.promotion_type=1 then 1--单品折扣 
			when promotion.promotion_type=2 then 1 --'单品买赠'
	   end as promotion_condition_minValue
      --,JSON_VALUE(promotion_offer.promotion_condition,'$.brandId') as brandId
      --,JSON_VALUE(promotion_offer.promotion_condition,'$.brandType') as brandType
      --,JSON_VALUE(promotion_offer.promotion_condition,'$.brandLimitType') as brandLimitType
      --,JSON_VALUE(promotion_offer.promotion_condition,'$.secondMaxValue') as secondMaxValue
      --,JSON_VALUE(promotion_offer.promotion_condition,'$.secondMinValue') as secondMinValue
      --,JSON_VALUE(promotion_offer.promotion_condition,'$.brandAmountValue') as brandAmountValue     
	  --  into   promo_analysis.dim_promotion_step1
 from ODS_Promotion.Promotion promotion
 left join ODS_Promotion.Promotion_Offer promotion_offer 
 on promotion.promotion_sys_id=promotion_offer.promotion_sys_id
 left join (
            select distinct sku_discount.promotion_sys_id,sku_discount.sku_code,sku.category,sku.range,discount
            from STG_Promotion.Promotion_Product_Discount_For_Promo sku_discount
            left join dwd.dim_sku_info sku on sku_discount.sku_code=sku.sku_code
			) sku_discount
 on promotion.promotion_sys_id=sku_discount.promotion_sys_id
  --CROSS APPLY STRING_SPLIT(replace(replace(channel_id,'',''),'',''), ',')
 left join (
             select case when crm_coupon_code is null then 0 else 1 end as coupon,promotion_name, promotion_id,crm_coupon_code,min(create_time) min_create_time,max(create_time) max_create_time,count(distinct order_id) order_count,sum(promotion_adjustment) promotion_adjustment_total
             from STG_Order.Order_Promotion
             where promotion_content not like N'%小卡%'
			 --and crm_coupon_code is null
			 and create_time>='2020-01-01'
			 and order_id in (select distinct sales_order_number from dwd.fact_sales_order )
			 group by case when crm_coupon_code is null then 0 else 1 end,promotion_name,promotion_id,crm_coupon_code 
			 ) order_promotion
 on promotion.promotion_sys_id=order_promotion.promotion_id
 left join ODS_Promotion.CRM_EB_REL coupon
 on promotion.promotion_sys_id=coupon.promotion_id
 left join [promo_analysis].promotion_rel promotion_rel
 on promotion.promotion_sys_id=promotion_rel.promotion_sys_id
 where  --promotion.promotion_sys_id='1060000002' and 
 end_time >='2020-01-01'
 --and promotion.promotion_sys_id='1010000001'
 and promotion.promotion_name not like N'%测试%'
 and promotion.promotion_name not like '%test%'
 --and promotion.publish_env=1--生产环境 
 --order by 4,3--promotion.start_time,promotion.end_time
 ;
--Step2 取有用字段，并去重
truncate table promo_analysis.dim_promotion_step2;
insert into promo_analysis.dim_promotion_step2

select distinct promotion_sys_id
      ,used_coupon_code
	  ,crm_coupon_code
	  ,sku_code
	  ,promotion_rel_type
	  ,promotion_group_lvl
	  ,[include]
	  ,concat_ws('-',promotion_sys_id,isnull(coalesce(used_coupon_code,crm_coupon_code),'NA'),isnull(sku_code,'ALL')) as promotion_coupon_sku_id
      ,promotion_name
	  ,start_time
      ,end_time
      ,promotion_type
	  ,case when
            (is_valid_white*is_valid_pink*is_valid_black*is_valid_gold = 1)                            -- 全会员
            or (is_valid_white|is_valid_pink|is_valid_black|is_valid_gold = 0)     --什么都没写，当作全场
       then 1 else 0
       end as is_valid_all_member
      ,is_valid_pink
      ,is_valid_white
      ,is_valid_black
      ,is_valid_gold
	  ,is_valid_employee
	  ,has_threshold
	  ,promotion_condition_minvalue
	  ,case when promotion_tag like N'满件%' then 1 else 0 end has_qty
	  ,has_reduce
      ,has_pct
      ,has_gift
      ,reduce
      ,pct
      ,promotion_tag
	  ,is_soa
      ,isAllProduct 
	  --into promo_analysis.dim_promotion_step2
  from promo_analysis.dim_promotion_step1;

end


GO
