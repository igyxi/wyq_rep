/****** Object:  StoredProcedure [DA_Tagging].[SP_T4_3_Online_Purchase3]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T4_3_Online_Purchase3] AS
BEGIN

/* ############ ############ ############ Online Purchase3 Inferrd Tag ############ ############ ############ */

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase Tab',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

TRUNCATE table DA_Tagging.online_purchase3
insert into DA_Tagging.online_purchase3(master_id,sales_member_id)
select distinct master_id,sales_member_id from DA_Tagging.sales_id_mapping
where master_id is not null
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase [dragon_sales_ab],[tmall_sales_ab],[jd_sales_ab]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

-- 官网
update DA_Tagging.online_purchase3
set dragon_sales_ab = tt2.dragon_sales
    ,tmall_sales_ab = tt2.tmall_sales
    ,jd_sales_ab = tt2.jd_sales
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id
    ,max(case when platform = N'丝芙兰官网' then platform_sales/platform_orders else 0 end) as dragon_sales
    ,max(case when platform = N'天猫' then platform_sales/platform_orders else 0 end) as tmall_sales
    ,max(case when platform = N'京东' then platform_sales/platform_orders else 0 end) as jd_sales
        from(
            select sales_member_id,store as platform
            ,sum(product_amount) as platform_sales
            ,count(distinct sales_order_number) as platform_orders
            from DA_Tagging.sales_order_basic_temp
            group by sales_member_id,store
    )t1 group by sales_member_id
)tt2
on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase [monetary_ab]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

-- 线上全渠道客单价
update DA_Tagging.online_purchase3
set monetary_ab = tt2.monetary_ab
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id, monetary_sales/monetary_orders as monetary_ab
        from(
            select sales_member_id
            ,sum(product_amount) as monetary_sales
            ,count(distinct sales_order_number) as monetary_orders
            from DA_Tagging.sales_order_basic_temp 
            group by sales_member_id
    )t1
)tt2
on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase [conversion_trigger]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

-- 购买动机  --need prod model tag results                                  
-- 按照线上产品定位，计算不同定位产品的订单比率（含有多种定位产品则多种定位产品的订单都计入），根据用户订单中订单比率最高的产品定位种类定义用户购买动机
-- Conversion Trigger
select sales_member_id,online_product_role as conversion_trigger
into #conversion_trigger
from(
    select sales_member_id,online_product_role
        ,row_number() over(partition by sales_member_id order by order_cnt desc) as rn
    from(
        select sales_member_id,online_product_role,count(sales_order_number) as order_cnt
        from DA_Tagging.sales_order_sku_temp t1
        left outer join DA_Tagging.product t2 on t1.item_sku_cd=t2.sku_cd
        group by sales_member_id,online_product_role
        )t1
)tt1 where rn=1
;


update DA_Tagging.online_purchase3
set conversion_trigger = tt2.conversion_trigger
from DA_Tagging.online_purchase3 tt1
join #conversion_trigger tt2 on tt1.sales_member_id=tt2.sales_member_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase [new_product_prefer] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())            
-- 新品偏好  --sample date 跑通                               
-- 计算订单中含有新品的订单占总订单的比率，按该比率将用户排序，比率高的top 30%为新品偏好1的用户
-- New Product Prefer
;
select count(distinct sales_member_id) as member_cnt
into #total_member_cnt
from DA_Tagging.sales_order_sku_temp
--where convert(date,place_time) between convert(date,getdate() - 90) and convert(date,getdate() - 1)  --调试脚本阶段用90天交易数据
;


select sales_member_id,round(new_prod_orders/cast(orders as float), 2) as new_prod_order_rate
,row_number() over(order by round(new_prod_orders/cast(orders as float), 2) desc) as rn
into #new_prod_order
from(
select sales_member_id
    ,count(distinct case when t2.sku_cd is not null then sales_order_number else null end) as new_prod_orders
    ,count(distinct sales_order_number) as orders
from DA_Tagging.sales_order_sku_temp t1
left outer join(
    select sku_cd
    from [DW_Product].[V_SKU_Profile]
    where isnew=1
    ) t2 on t1.item_sku_cd =t2.sku_cd collate Chinese_PRC_CS_AI_WS
    --where convert(date,place_time) between convert(date,getdate() - 90) and convert(date,getdate() - 1) --调试脚本阶段用90天交易数据
group by sales_member_id
)tt
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase [new_product_prefer]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())            
;

update DA_Tagging.online_purchase3
set new_product_prefer = case when round(t2.rn/cast(t3.member_cnt as float), 2)<=0.3 then 1 else 0 end
from DA_Tagging.online_purchase3 t1
left join #new_prod_order t2 on t1.sales_member_id=t2.sales_member_id
cross join #total_member_cnt t3
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase [price_tier_type]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())            
;
-- 价格段偏好                               
-- 分品类和价格将产品按价格分组（按上30%为高价，中间40%为中价，下30%为低价进行区分），例如高价面膜和高价面霜属于高价组，计算线上订单最多的价格组
-- Price Tier Type
select distinct sku_cd,category,sap_price
into #sku_price
from DW_Product.V_SKU_Profile 
where sap_price<>0 and sap_price is not null
;



select sku_cd,category,sap_price
,case when rn>=0 and rn<0.3 then N'低价'
when rn>=0.3 and rn<0.7 then N'中价'
when rn>=0.7 and rn<=1 then N'高价' else null end as  price_tier_type
into #sku_price_tier
from(
    select sku_cd,category,sap_price
    ,round(PERCENT_RANK() OVER( partition by category ORDER BY sap_price), 5) as rn
    from #sku_price
    where category is not null
)t1

select sales_member_id,price_tier_type
into #price_tier_type
    from(
        select sales_member_id,price_tier_type
            ,row_number() over(partition by sales_member_id order by order_cn desc) as rn
        from(
            select sales_member_id,price_tier_type,count(distinct sales_order_number) as order_cn
            from DA_Tagging.sales_order_sku_temp t1 
            join #sku_price_tier t2 on t1.item_sku_cd COLLATE SQL_Latin1_General_CP1_CI_AS = t2.sku_cd 
            group by sales_member_id,price_tier_type
        )t
    )tt
where rn=1
;


update DA_Tagging.online_purchase3
set price_tier_type = tt2.price_tier_type
from DA_Tagging.online_purchase3 tt1
join  #price_tier_type tt2 on tt1.sales_member_id=tt2.sales_member_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [upgrade_timing] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

-- 上月是否升级                             
-- 对前4个月均有购买的老客 计算每个月花费的增长率，
-- 上月增长率超过过去3个月平均增长率均值的30%则判定为上个月升级
-- Upgrade Timing
-- 前四个月均有购买的人
select distinct sales_member_id
into #pre4_purchase_member
from(
    select sales_member_id,count(distinct place_month) as month_cn
    from(
        select distinct sales_member_id,month(place_time) as place_month
        from DA_Tagging.sales_order_basic_temp
        where DATEDIFF(MM, place_time, getdate()) in (1,2,3,4) --筛选4个月内的订单
    )tt group by sales_member_id
)ttt where month_cn>=4
;

-- 计算前4月有消费的人 前4个月的消费金额
select sales_member_id
,max(case when place_month=4 then online_sales_month end) as pre4_sales
,max(case when place_month=3 then online_sales_month end) as pre3_sales
,max(case when place_month=2 then online_sales_month end) as pre2_sales
,max(case when place_month=1 then online_sales_month end) as pre1_sales
into #pre4_purchase_sales
from(
    select distinct t2.sales_member_id
    ,DATEDIFF(MM, place_time, getdate()) as place_month
    ,sum(product_amount) as online_sales_month
    from DA_Tagging.sales_order_basic_temp t1
    join #pre4_purchase_member t2  on t1.sales_member_id = t2.sales_member_id
    group by t2.sales_member_id, DATEDIFF(MM, place_time, getdate())
)tt1
group by sales_member_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [upgrade_timing]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 前四月有消费的人 前四个月的消费金额增长率
update DA_Tagging.online_purchase3
set upgrade_timing=ttt.upgrade_timing 
from DA_Tagging.online_purchase3 t1
join(
    select sales_member_id,upgrade_timing
    from(
        select sales_member_id
        , case when (pre1_sales_growth-pre3_growth_avg)/(case when pre3_growth_avg<>0 then pre3_growth_avg else null end) >0.3 then 1 else 0 end as upgrade_timing
        from(
            select sales_member_id
            ,((pre3_sales_growth + pre2_sales_growth + pre1_sales_growth)/3) as pre3_growth_avg, pre1_sales_growth
            from(
                select sales_member_id
                , (pre4_sales-pre3_sales)/pre3_sales as pre3_sales_growth
                , (pre3_sales-pre2_sales)/pre2_sales as pre2_sales_growth
                , (pre2_sales-pre1_sales)/pre1_sales as pre1_sales_growth
                from #pre4_purchase_sales
                )t1
            )tt1
    )ttt1
)ttt on t1.sales_member_id = ttt.sales_member_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [upgrade_driver] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 升级原因                                 
-- 计算升级前一月和升级当月的不同产品定位的订单比率的增长率，根据订单比率增长率最高的产品定位种类来定义用户升级原因
-- Upgrade Driver
select distinct sales_member_id
into #last_month_upgrade
from(
    select sales_member_id, upgrade_timing
    from DA_Tagging.online_purchase3 
    where upgrade_timing=1
)t
;


-- 升级的人在前两个月的不同产品类型的订单量
--drop table #pre2_month_upgrade_order
select sales_member_id,order_month,online_product_role
,count(distinct sales_order_number) as order_cn
into #pre2_month_upgrade_order
from(
    select t1.sales_member_id,t1.item_sku_cd,t1.sales_order_number
    ,month(place_time) as order_month
    ,t2.online_product_role
    from (
        select t01.sales_member_id,item_sku_cd,sales_order_number ,place_time
        from DA_Tagging.sales_order_sku_temp t01
        join #last_month_upgrade t02 on t01.sales_member_id = t02.sales_member_id
        where DATEDIFF(MM, place_time, getdate()) in (1,2,3)
        )t1
    join (
        select sku_cd,online_product_role
        from DA_Tagging.product where online_product_role is not null
        )t2 on t1.item_sku_cd=t2.sku_cd
)tt
group by sales_member_id,order_month,online_product_role
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [upgrade_driver]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
update DA_Tagging.online_purchase3
set upgrade_driver = tt2.upgrade_driver
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id,online_product_role as upgrade_driver
    from(
        select sales_member_id,online_product_role
        ,row_number() over(partition by sales_member_id order by round(order_cn/cast(last_orders as float), 2) desc) as rn
        from(
            select sales_member_id,order_month,online_product_role,order_cn,last_orders
            from(
                select sales_member_id,order_month,online_product_role,order_cn
                ,lead(order_cn,1) over(partition by sales_member_id,online_product_role order by order_month) as last_orders
                from #pre2_month_upgrade_order
            )tt
        )ttt where last_orders is not null
    )tttt where rn=1
)tt2 on tt1.sales_member_id=tt2.sales_member_id
;



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [purchase_pattern] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- Purchase Pattern ：购买模式                                              
select sales_member_id,order_cnt,brand_cnt,category_cnt
into #temp1
from(
    select sales_member_id
    ,count(distinct sales_order_number) as order_cnt
    ,count(distinct item_brand_name) as brand_cnt
    ,count(distinct item_category) as category_cnt
    from DA_Tagging.sales_order_vb_temp
    group by sales_member_id
)tt where  order_cnt>=5
;

select avg(brand_cnt) as avg_brand_cnt
,avg(category_cnt) as avg_category_cnt
into #temp2
from #temp1 t0
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [purchase_pattern]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.online_purchase3
set purchase_pattern = tt2.purchase_pattern
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id
    ,case 
    when brand_cnt>=avg_brand_cnt and category_cnt>=avg_category_cnt then 'Exploer'
    when brand_cnt<avg_brand_cnt and category_cnt>=avg_category_cnt then 'Brand Loyalty'
    when brand_cnt<avg_brand_cnt and category_cnt>=avg_category_cnt then 'Category Loyalty'
    when brand_cnt<avg_brand_cnt and category_cnt<avg_category_cnt then 'Repeat Buyer'
    end as purchase_pattern
    from(
        select sales_member_id,brand_cnt,category_cnt
        ,t2.avg_brand_cnt,t2.avg_category_cnt
        from #temp1 t1 
        cross join #temp2 t2
    )t1
)tt2 on tt1.sales_member_id=tt2.sales_member_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate promotion behavior temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- private_sale_sensitivity：大促及订单综合价格敏感程度                   
select distinct sales_member_id,sales_order_number
,case when datediff(ss,promotion_start_time,place_time)/3600 <= promotion_hours 
and datediff(ss,promotion_start_time,place_time)/3600 >=0 then N'大促时购买' else N'非大促时购买' end as promotion_behavior
into #promotion_behavior_temp
from(
    select sales_member_id,sales_order_number,place_time,year(place_time) as order_year,month(place_time) as order_month 
    from DA_Tagging.sales_order_basic_temp
    ) t1
left join (
        select promotion_start_time,promotion_hours,year(promotion_start_time) as promotion_year,month(promotion_start_time) as promotion_month
        from DA_Tagging.promotion_time 
) t2 on order_year=promotion_year and order_month=promotion_month
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [private_sale_sensitivity]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.online_purchase1
set private_sale_sensitivity = tt2.private_sale_sensitivity
from DA_Tagging.online_purchase1 tt1
join(
    select sales_member_id
    ,case 
    when dacu=N'大促时购买' and no_dacu= N'非大促时购买' then N'大促及非大促都购买'
    when dacu=N'大促时购买' and no_dacu is null then N'只在大促购买' else N'只在非大促购买' end as private_sale_sensitivity
    from(
        select sales_member_id,
            max (case promotion_behavior when N'大促时购买' then N'大促时购买' else null end) dacu,
            max (case promotion_behavior when N'非大促时购买' then N'非大促时购买' else null end ) no_dacu
        from #promotion_behavior_temp tt group by sales_member_id
    )ttt
)tt2 on tt1.sales_member_id=tt2.sales_member_id

;

update DA_Tagging.online_purchase1
set private_sale_sensitivity = tt2.private_sale_sensitivity
from DA_Tagging.online_purchase1 tt1
join(
    select sales_member_id
    ,case when no_dacu_cnt >= dacu_cnt then N'大促非大促均购买偏好非大促' else N'大促非大促均购买偏好大促' end as private_sale_sensitivity
    from(
        select t1.sales_member_id
        ,max(case when promotion_behavior=N'非大促时购买' then order_cnt end) as no_dacu_cnt
        ,max(case when promotion_behavior=N'大促时购买' then order_cnt end) as dacu_cnt
        from(
            select sales_member_id, promotion_behavior, count(distinct sales_order_number) as order_cnt 
            from #promotion_behavior_temp 
            group by sales_member_id, promotion_behavior
        )t1
        inner join (
            select distinct sales_member_id, private_sale_sensitivity
            from DA_Tagging.online_purchase1
            where private_sale_sensitivity=N'大促及非大促都购买'
        )t2 on t1.sales_member_id = t2.sales_member_id
        group by t1.sales_member_id
    )tt1 
)tt2 on tt1.sales_member_id=tt2.sales_member_id
where tt1.private_sale_sensitivity=N'大促及非大促都购买'

;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [price_sensitivity]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 综合考虑大促敏感程度和折扣敏感程度，根据大促敏感程度和折扣订单占比将用户分组
-- ，只在大促购买      或偏好大促购买      且折扣订单占比高  的用户为[高],
-- ，只在非大促购买    或偏好非大促购买   且折扣订单占比低    的用户为[低]
-- ，其余为[中]
-- Price Sensitivity [高], [中], [低]
-- Private Sale Sensitivity  [只在大促][只在非大促][大促非大促均购买偏好大促][大促非大促均购买偏好非大促]
update DA_Tagging.online_purchase3
set price_sensitivity = tt2.syn_price_sensitivity
from DA_Tagging.online_purchase1 tt1
join(
    select sales_member_id
    ,case when price_sensitivity=N'高' and private_sale_sensitivity in(N'只在大促购买',N'大促非大促均购买偏好大促') then N'高'
            when price_sensitivity=N'低' and private_sale_sensitivity in(N'只在非大促购买',N'大促非大促均购买偏好非大促') then N'低'
            else N'中'
            end as syn_price_sensitivity
    from(
        select sales_member_id,price_sensitivity,private_sale_sensitivity
        from DA_Tagging.online_purchase1
        where price_sensitivity is not null
            or private_sale_sensitivity is not null 
    )t1
)tt2 on tt1.sales_member_id=tt2.sales_member_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [app_mnp_shift] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- APP MNP Shift：APP MNP流转人群    
select distinct sales_member_id,app_mnp_shift
into #app_mnp_shift
from(
    select sales_member_id
    ,case when channel='APP' and  next_channel=N'小程序' then 'APP to MNP'
            when channel=N'小程序' and  next_channel='APP' then 'MNP to APP'
            when (channel=N'小程序' and  next_channel=N'小程序')
            or (channel='APP' and  next_channel='APP') then N'无APP和MNP流转' end as app_mnp_shift
    from(
        select sales_member_id,channel,place_time
        ,lead(channel,1,null) over(partition by sales_member_id order by place_time) as next_channel
        from DA_Tagging.sales_order_basic_temp
        where channel in ('APP',N'小程序')
    )t1
)tt1
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [app_mnp_shift]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.online_purchase3
set app_mnp_shift = tt2.app_mnp_shift
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id
    ,case when AppToMnp=1 and MnpToApp=0 and NoShift=0 then 'APP to MNP'
            when AppToMnp=0 and MnpToApp=1 and NoShift=0 then 'MNP to APP'
            when AppToMnp=1 and MnpToApp=1 and (NoShift=0 or NoShift=1) then 'Both Pattern'
            else N'无APP和MNP流转'
            end as app_mnp_shift
    from(
        select sales_member_id
        ,max(case when app_mnp_shift='APP to MNP' then 1 else 0 end) as AppToMnp
        ,max(case when app_mnp_shift='MNP to APP' then 1 else 0 end) as MnpToApp
        ,max(case when app_mnp_shift=N'无APP和MNP流转' then 1 else 0 end) as NoShift
        from #app_mnp_shift
        group by sales_member_id
    )t1
)tt2 on tt1.sales_member_id=tt2.sales_member_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [tmall_fs_store_shift] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- tmall_fs_store_shift :天猫店铺流转人群           
select sales_member_id, sales_order_number , tmall_cd, rn
into #tmall_shift_temp
from(
    select sales_member_id
    , sales_order_number , tmall_cd
    , dense_rank() over (partition by sales_member_id order by sales_order_number desc, place_time desc) rn
    from(
        select sales_order_number
        ,case when t2.member_id COLLATE SQL_Latin1_General_CP1_CI_AS is not null then t2.member_card COLLATE SQL_Latin1_General_CP1_CI_AS else t1.member_id end as sales_member_id
        ,tmall_cd,place_time
        from(
            select sales_order_number, member_id, place_time
            , case when store_cd = 'TMALL001' and channel_cd = 'TMALL' then N'丝芙兰天猫店'
            when store_cd = 'TMALL001' and channel_cd = 'TMALL_WEI' then N'蔚蓝之美天猫店'
            when store_cd = 'TMALL004' and channel_cd = 'TMALL_CHALING' then N'茶灵天猫店' 
            when store_cd = 'TMALL005' and channel_cd = 'TMALL_PTR' then N'彼得罗夫天猫店'
            end as tmall_cd
            from DW_OMS.V_Sales_Order_Basic_Level
            where is_placed_flag=1 and product_amount>0
            and store_cd in ('TMALL001','TMALL004','TMALL005') and channel_cd in ('TMALL','TMALL_WEI','TMALL_CHALING','TMALL_PTR')
        )t1 left outer join DA_Tagging.sales_member_id t2 on t1.member_id=t2.member_id COLLATE SQL_Latin1_General_CP1_CI_AS
    )tt1
)ttt1
where rn=1 or rn=2
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [tmall_fs_store_shift]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.online_purchase3
set tmall_fs_store_shift = tt2.tmall_fs_store_shift
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id
    ,case 
    when tmall_cd1= N'丝芙兰天猫店' and tmall_cd2=N'蔚蓝之美天猫店' then N'丝芙兰天猫店转到蔚蓝之美天猫店'
    when tmall_cd1= N'蔚蓝之美天猫店' and tmall_cd2=N'丝芙兰天猫店' then N'蔚蓝之美天猫店转到丝芙兰天猫店'
    when tmall_cd1= N'丝芙兰天猫店' and tmall_cd2=N'茶灵天猫店' then N'丝芙兰天猫店转到茶灵天猫店'
    when tmall_cd1= N'茶灵天猫店' and tmall_cd2=N'丝芙兰天猫店' then N'茶灵天猫店转到丝芙兰天猫店'
    when tmall_cd1= N'蔚蓝之美天猫店' and tmall_cd2=N'茶灵天猫店' then N'蔚蓝之美天猫店转到茶灵天猫店'
    when tmall_cd1= N'茶灵天猫店' and tmall_cd2=N'蔚蓝之美天猫店' then N'茶灵天猫店转到蔚蓝之美天猫店'
    when tmall_cd1=N'丝芙兰天猫店' and tmall_cd2=N'彼得罗夫天猫店' then N'丝芙兰天猫店转到彼得罗夫天猫店'
    when tmall_cd1=N'蔚蓝之美天猫店' and tmall_cd2=N'彼得罗夫天猫店' then N'蔚蓝之美天猫店转到彼得罗夫天猫店'
    when tmall_cd1=N'茶灵天猫店' and tmall_cd2=N'彼得罗夫天猫店' then N'茶灵天猫店转到彼得罗夫天猫店'
    when tmall_cd1=N'彼得罗夫天猫店' and tmall_cd2=N'丝芙兰天猫店' then N'彼得罗夫天猫店转到丝芙兰天猫店'
    when tmall_cd1=N'彼得罗夫天猫店' and tmall_cd2=N'蔚蓝之美天猫店' then N'彼得罗夫天猫店转到蔚蓝之美天猫店'
    when tmall_cd1=N'彼得罗夫天猫店' and tmall_cd2=N'茶灵天猫店' then N'彼得罗夫天猫店转到茶灵天猫店'
    else N'无天猫店流转' end as tmall_fs_store_shift
    from(
        select sales_member_id
        , max(case when rn=2 then tmall_cd else null end) as tmall_cd1
        , max(case when rn=1 then tmall_cd else null end) as tmall_cd2
        from #tmall_shift_temp
        group by sales_member_id
    )t1
)tt2 on tt1.sales_member_id COLLATE SQL_Latin1_General_CP1_CI_AS=tt2.sales_member_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [value_segment] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- value_segment:价值分组           
select avg(cast(purchase_recency as bigint)) as avg_purchase_recency, 
avg(cast(purchase_frequency as bigint)) as avg_purchase_frequency,
avg(cast(purchase_monetary as bigint)) as avg_purchase_monetary
into #temp_avg
from(   
    select sales_member_id, purchase_recency, purchase_frequency, purchase_monetary
    from DA_Tagging.online_purchase2
)t1
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [value_segment]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.online_purchase3
set value_segment = tt2.value_segment
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id
    ,case 
    when purchase_frequency>=avg_purchase_frequency and purchase_monetary>=avg_purchase_monetary and purchase_recency< avg_purchase_recency then 'High Value'
    when purchase_frequency>=avg_purchase_frequency and purchase_monetary>=avg_purchase_monetary and purchase_recency>=avg_purchase_recency then 'Key Retain'
    when purchase_frequency< avg_purchase_frequency and purchase_monetary>=avg_purchase_monetary and purchase_recency< avg_purchase_recency then 'Key Develop'
    when purchase_frequency< avg_purchase_frequency and purchase_monetary>=avg_purchase_monetary and purchase_recency>=avg_purchase_recency then 'Key Recall'
    when purchase_frequency>=avg_purchase_frequency and purchase_monetary< avg_purchase_monetary and purchase_recency< avg_purchase_recency then 'Hign Potential'
    when purchase_frequency>=avg_purchase_frequency and purchase_monetary< avg_purchase_monetary and purchase_recency>=avg_purchase_recency then 'Retain'
    when purchase_frequency< avg_purchase_frequency and purchase_monetary< avg_purchase_monetary and purchase_recency< avg_purchase_recency then 'Develop'
    when purchase_frequency< avg_purchase_frequency and purchase_monetary< avg_purchase_monetary and purchase_recency>=avg_purchase_recency then 'Churn'
    end as value_segment
    from(
        select sales_member_id, purchase_recency, purchase_frequency, purchase_monetary
        ,avg_purchase_recency, avg_purchase_frequency, avg_purchase_monetary
        from(
            select sales_member_id, purchase_recency, purchase_frequency, purchase_monetary
            from DA_Tagging.online_purchase2
                )t1
        cross join #temp_avg
    )tt1
)tt2 on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [category_and_category_maturity]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- category_and_category_maturity: 偏好品类和品类成熟度                       
update DA_Tagging.online_purchase3
set category_and_category_maturity = tt2.category_maturity
from DA_Tagging.online_purchase3 tt1
join(
    select  sales_member_id 
    ,case when preferred_category='Skincare' then skincare_maturity 
    when preferred_category='Makeup' then makeup_maturity
    when preferred_category='Fragrances' then N'香水用户'
    when preferred_category='Wellness' then N'肤食用户'
    end as category_maturity
    from(
        select sales_member_id,preferred_category
        ,case when skincare_maturity ='Level I' then N'护肤成熟用户' else N'护肤新手' end as skincare_maturity
        ,case when makeup_maturity ='Level I'then N'彩妆成熟用户' else N'彩妆新手' end as makeup_maturity
        from DA_Tagging.online_purchase1
        where preferred_category is not null
            or skincare_maturity is not null
            or makeup_maturity is not null
        )t1
)tt2 on tt1.sales_member_id=tt2.sales_member_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [preferred_detailcategory]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- preferred_detailcategory : 偏好的三级品类（销售额）                  
update DA_Tagging.online_purchase3
set preferred_detailcategory = tt2.preferred_detailcategory_sales
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id,level3_name as preferred_detailcategory_sales
    from(
        select sales_member_id,level3_name,row_number() over(partition by sales_member_id order by item_sales desc) as rn
        from(
            select sales_member_id,level3_name,sum(item_apportion_amount) as item_sales
            from(
                select sales_member_id,item_sku_cd,item_apportion_amount
                from DA_Tagging.sales_order_sku_temp --[RPT_EDW].[v_oms_sales_order_sku_level_df]
					)t1
            left outer join DW_Product.V_SKU_Profile t2 on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS=t2.sku_cd collate Chinese_PRC_CS_AI_WS--oms.sku_profile t2 on t1.sku=t2.product_id
            group by sales_member_id,level3_name
        ) t1
    )tt1 
    where rn=1
)tt2 on tt1.sales_member_id COLLATE SQL_Latin1_General_CP1_CI_AS=tt2.sales_member_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [preferred_productline]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- preferred_productline: 偏好的系列（销售额）                        
update DA_Tagging.online_purchase3
set preferred_productline = tt2.preferred_productline_sales
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id,productline as preferred_productline_sales
    from(
        select sales_member_id,productline,row_number() over(partition by sales_member_id order by item_sales desc) as rn
        from(
            select sales_member_id,productline,sum(item_apportion_amount) as item_sales
            from(
                select sales_member_id,item_sku_cd,item_apportion_amount
                from DA_Tagging.sales_order_sku_temp --[RPT_EDW].[v_oms_sales_order_sku_level_df]
                    )t1
            left outer join DA_Tagging.coding_sephoraproductlist t2 
            on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS = t2.sku_code collate Chinese_PRC_CS_AI_WS
            group by sales_member_id,productline
        )t1
    )tt1 --oms.sales_order_sku_level_df t1
    where rn=1
)tt2 on tt1.sales_member_id=tt2.sales_member_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [segment_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- segment_preference:偏好的细分品类（销售额）                  
update DA_Tagging.online_purchase3
set segment_preference = tt2.segment_preference_sales
from DA_Tagging.online_purchase3 tt1
join(
    select sales_member_id,segment as segment_preference_sales
    from(
        select sales_member_id,segment,row_number() over(partition by sales_member_id order by item_sales desc) as rn
        from(
            select sales_member_id,segment,sum(item_apportion_amount) as item_sales
            from(
                select sales_member_id,item_sku_cd,item_apportion_amount
                from DA_Tagging.sales_order_sku_temp
                )t1
            left outer join DA_Tagging.coding_sephoraproductlist t2 on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS = t2.sku_code collate Chinese_PRC_CS_AI_WS
            group by sales_member_id,segment
        ) t1
    )tt1
    where rn=1
)tt2 on tt1.sales_member_id=tt2.sales_member_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [preferred_detailcategory_order] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- preferred_detailcategory_order: 偏好的三级品类（订单数）                 
select sales_member_id,level3_name as preferred_detailcategory_order
into #preferred_detailcategory_order
from(
    select sales_member_id,level3_name
    ,row_number() over(partition by sales_member_id order by order_cnt desc) as rn
    from(
        select sales_member_id,level3_name,count(distinct sales_order_number) as order_cnt
        from(
            select sales_member_id,item_sku_cd,sales_order_number
            from DA_Tagging.sales_order_sku_temp
                )t1
        left outer join DW_Product.V_SKU_Profile t2 
        on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS=t2.sku_cd collate Chinese_PRC_CS_AI_WS
        group by sales_member_id,level3_name
        ) t1
    )tt1
where rn=1
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [preferred_detailcategory_order]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.online_purchase3
set preferred_detailcategory_order = tt2.preferred_detailcategory_order
from DA_Tagging.online_purchase3 tt1
join #preferred_detailcategory_order tt2  on tt1.sales_member_id=tt2.sales_member_id
;



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [preferred_productline_order] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- preferred_productline_order: 偏好的系列（订单数）                      
select sales_member_id,productline as preferred_productline_order
into #preferred_productline_order
from(
    select sales_member_id,productline,row_number() over(partition by sales_member_id order by order_cnt desc) as rn
    from(
        select sales_member_id,productline,count(distinct sales_order_number) as order_cnt
        from(
            select sales_member_id,item_sku_cd,sales_order_number
            from DA_Tagging.sales_order_sku_temp
                )t1
        left outer join DA_Tagging.coding_sephoraproductlist t2 
        on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS = t2.sku_code collate Chinese_PRC_CS_AI_WS
        group by sales_member_id,productline
    )t1
)tt1
where rn=1
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [preferred_productline_order]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.online_purchase3
set preferred_productline_order = tt2.preferred_productline_order
from DA_Tagging.online_purchase3 tt1
join #preferred_productline_order tt2 on tt1.sales_member_id=tt2.sales_member_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [segment_preference_sales] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- segment_preference_sales: 偏好的细分品类（订单数）                   
select sales_member_id,segment as segment_preference_order
into #segment_preference_sales
from(
    select sales_member_id,segment,row_number() over(partition by sales_member_id order by order_cnt desc) as rn
    from(
        select sales_member_id,segment,count(distinct sales_order_number) as order_cnt
        from(
            select sales_member_id,item_sku_cd,sales_order_number
            from DA_Tagging.sales_order_sku_temp
            where convert(date,place_time) between convert(date,getdate() - 90) and convert(date,getdate() - 1)
                )t1
        left outer join DA_Tagging.coding_sephoraproductlist t2 
        on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS = t2.sku_code collate Chinese_PRC_CS_AI_WS
        group by sales_member_id,segment
    )t1
)tt1 
where rn=1
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [segment_preference_order]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.online_purchase3
set segment_preference_order = tt2.segment_preference_order
from DA_Tagging.online_purchase3 tt1
join #segment_preference_sales tt2 on tt1.sales_member_id=tt2.sales_member_id



/* ############ ############ ############ Online Purchase3 Fact Tag ############ ############ ############ */


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [first_purchase_sales]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 110.丝芙兰官网首单消费的金额
-- 计算每个用户store_cd=’S001‘的订单按时间排序取第一条销售额所在的金额
update DA_Tagging.online_purchase3
set first_purchase_sales=z.amount
from (
    select distinct sales_member_id
	,first_value(item_apportion_amount)over(partition by sales_member_id order by place_time) AS amount
    FROM DA_Tagging.sales_order_vb_temp  
    where store=N'丝芙兰官网'
)z
where DA_Tagging.online_purchase3.sales_member_id=z.sales_member_id
;
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [selective_sales_ranking]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 127.线上Selective购买金额在所有消费者中的排名
/*
    item_apportion_amount/item_brand_type/store_cd
    计算每个人 item_brand_type='Selective' ,SUM消费金额并排序，获得所在的排名区间
    已有字段：线上Selective购买金额，在表中：[DA_Tagging].[online_purchase2]
*/
update DA_Tagging.online_purchase3
set selective_sales_ranking=z.sales_ranking
from (
    select master_id,selective_sales
        ,case when sales_rk> 0 and sales_rk<=0.20 then '(0,20%]'
        when sales_rk> 0.20 and sales_rk<=0.40 then '(20%,40%]'
        when sales_rk> 0.40 and sales_rk<=0.60 then '(40%,60%]' 
        when sales_rk> 0.60 and sales_rk<=0.80 then '(60%,80%]'
        when sales_rk> 0.80 and sales_rk<=1.00 then '(80%,100%]'
        else null end as sales_ranking
    from (
        select master_id,selective_sales,convert(float,(row_number() over (order by selective_sales desc))/user_cnt)  as sales_rk
        from (
            select *
            from(
                select master_id,[selective_sales]
                from [DA_Tagging].[online_purchase2]
                where [selective_sales]>0
            )t1
            cross join 
            (
                select convert(float,count(distinct sales_member_id)) as user_cnt
                from [DA_Tagging].[online_purchase2]
                where [selective_sales] > 0 
            )t2
        ) t3
    ) t4
)z
where DA_Tagging.online_purchase3.master_id=z.master_id
;                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [exclusive_sales_ranking]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 128.线上Exclusive购买金额在所有消费者中的排名
;

update DA_Tagging.online_purchase3
set exclusive_sales_ranking=z.sales_ranking
from (
select master_id,exclusive_sales
    ,case when sales_rk> 0 and sales_rk<=0.20 then '(0,20%]'
    when sales_rk> 0.20 and sales_rk<=0.40 then '(20%,40%]'
    when sales_rk> 0.40 and sales_rk<=0.60 then '(40%,60%]' 
    when sales_rk> 0.60 and sales_rk<=0.80 then '(60%,80%]'
    when sales_rk> 0.80 and sales_rk<=1.00 then '(80%,100%]'
    else null end as sales_ranking
from(
    select master_id,exclusive_sales,convert(float,(row_number() over (order by exclusive_sales desc))/user_cnt)  as sales_rk
    from(
        select *
        from(
            select master_id,[exclusive_sales]
            from [DA_Tagging].[online_purchase2]
            where [exclusive_sales]>0
        )t1
        cross join(
            select convert(float,count(distinct sales_member_id)) as user_cnt
            from [DA_Tagging].[online_purchase2]
            where [exclusive_sales] > 0 
        )t2
    ) t3
) t4
)z
where DA_Tagging.online_purchase3.master_id=z.master_id
;                
                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [sephora_sales_ranking]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 129.线上Sephora购买金额在所有消费者中的排名

update DA_Tagging.online_purchase3
set sephora_sales_ranking=z.sales_ranking
from (
    select master_id,sephora_sales
        ,case when sales_rk> 0 and sales_rk<=0.20 then '(0,20%]'
        when sales_rk> 0.20 and sales_rk<=0.40 then '(20%,40%]'
        when sales_rk> 0.40 and sales_rk<=0.60 then '(40%,60%]' 
        when sales_rk> 0.60 and sales_rk<=0.80 then '(60%,80%]'
        when sales_rk> 0.80 and sales_rk<=1.00 then '(80%,100%]'
        else null end as sales_ranking
    from(
        select master_id,sephora_sales,convert(float,(row_number() over (order by sephora_sales desc))/user_cnt)  as sales_rk
        from(
            select *
            from(
                select master_id,[sephora_sales]
                from [DA_Tagging].[online_purchase2] 
                where [sephora_sales]>0
            )t1
            cross join(
                select convert(float,count(distinct sales_member_id)) as user_cnt
                from [DA_Tagging].[online_purchase2]
                where [sephora_sales] > 0 
            )t2
        ) t3
    ) t4
)z
where DA_Tagging.online_purchase3.master_id=z.master_id
;               
                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [media_related_order]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 523.Media Related Order :投放相关订单数
;
update DA_Tagging.online_purchase3
set [media_related_order]=z.[Media_Related_Order_#]
from (
    select  isnull(A.master_id,isnull(B.master_id,C.master_id)) as master_id,
            isnull([Media_Related_Order_#1],0)+isnull([Media_Related_Order_#2],0)+isnull([Media_Related_Order_#3],0) AS [Media_Related_Order_#]
        from(
        SELECT b.master_id,[Media_Related_Order_#] AS [Media_Related_Order_#1]
        FROM (
            select [member_card],count(distinct sales_order_number) as [Media_Related_Order_#]
            FROM [DW_Sensor].[DWS_Sensor_Order_UTM_Attribution] 
            where attribution_type='1D' and payed_amount>0 and payed_amount is not null and is_placed_flag=1
            and  convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
            group by [member_card]
        ) a left join (select * from [DA_Tagging].[id_mapping] where sephora_card_no is not null and master_id is not null)b on a.[member_card]=b.sephora_card_no COLLATE SQL_Latin1_General_CP1_CI_AS
    ) A
FULL JOIN 
-- app,ios
(
    SELECT b.master_id,[Media_Related_Order_#] AS [Media_Related_Order_#2]
    FROM (
        select idfa  as [device_id_IDFA],count(distinct orderid) as [Media_Related_Order_#]
        from  [DW_TD].[Tb_Fact_IOS_Ascribe]
        where PayedAmount>0 and PayedAmount is not null and IsPlacedFlag=1
        and  cast(left(cast(datekey as nvarchar(100)),4)+'-'+substring(cast(datekey as nvarchar(100)),5,2)+'-'+right(cast(datekey as nvarchar(100)),2) as date) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
        group by idfa
    ) a left join (select * from [DA_Tagging].[id_mapping] where [device_id_IDFA] is not null and master_id is not null)b on a.[device_id_IDFA]=b.[device_id_IDFA]  collate Chinese_PRC_CS_AI_WS
) B on A.master_id=B.master_id
                
FULL JOIN
--app,安卓
(
    SELECT b.master_id,[Media_Related_Order_#] AS [Media_Related_Order_#3]
    FROM (
        select androidid  as [device_id_IMEI],count(distinct orderid) as [Media_Related_Order_#]
        from [DW_TD].[Tb_Fact_Android_Ascribe]
        where PayedAmount>0 and PayedAmount  is not null and IsPlacedFlag=1
        and  cast(left(cast(datekey as nvarchar(100)),4)+'-'+substring(cast(datekey as nvarchar(100)),5,2)+'-'+right(cast(datekey as nvarchar(100)),2) as date) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
        group by androidid 
    )a left join (select * from [DA_Tagging].[id_mapping] where [device_id_IMEI] is not null and master_id is not null)b on a.[device_id_IMEI]=b.[device_id_IMEI]  collate Chinese_PRC_CS_AI_WS
)C
ON A.master_id=C.master_id
where isnull(A.master_id,isnull(B.master_id,C.master_id)) is not null
)z where DA_Tagging.online_purchase3.master_id =z.master_id
;
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [media_related_revenue]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
--524.Media Related Revenue：投放相关销售额，计算Attribution表中90天内的每个用户有效订单的销售额
--Media Related Revenue
;

update DA_Tagging.online_purchase3
set [media_related_revenue]=z.[Media_Related_Revenue]
from (
select  isnull(A.master_id,isnull(B.master_id,C.master_id)) as master_id,
        isnull([Media_Related_Revenue_#1],0)+isnull([Media_Related_Revenue_#2],0)+isnull([Media_Related_Revenue_#3],0) AS [Media_Related_Revenue]
from
(
SELECT b.master_id,[Media_Related_Revenue] AS [Media_Related_Revenue_#1]
FROM (
    select [member_card],sum(payed_amount) as [Media_Related_Revenue]
    FROM [DW_Sensor].[DWS_Sensor_Order_UTM_Attribution]   -- 这个正式库里也是这个名
    where attribution_type='1D' and payed_amount>0 and payed_amount is not null and is_placed_flag=1
    and  convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
    group by [member_card]
) a left join (select * from [DA_Tagging].[id_mapping] where sephora_card_no is not null and master_id is not null)b on a.[member_card]=b.sephora_card_no COLLATE SQL_Latin1_General_CP1_CI_AS
) A
FULL JOIN 
-- app,ios
(
SELECT b.master_id,[Media_Related_Revenue] AS [Media_Related_Revenue_#2]
FROM (
    select idfa  as [device_id_IDFA],sum(PayedAmount) as [Media_Related_Revenue]
    from  [DW_TD].[Tb_Fact_IOS_Ascribe]
    where PayedAmount>0 and PayedAmount is not null and IsPlacedFlag=1
    and  cast(left(cast(datekey as nvarchar(100)),4)+'-'+substring(cast(datekey as nvarchar(100)),5,2)+'-'+right(cast(datekey as nvarchar(100)),2) as date) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
    group by idfa
) a left join (select * from [DA_Tagging].[id_mapping] where [device_id_IDFA] is not null and master_id is not null)b on a.[device_id_IDFA]=b.[device_id_IDFA]  collate Chinese_PRC_CS_AI_WS
) B on A.master_id=B.master_id
                
FULL JOIN
--app,安卓
(
SELECT b.master_id,[Media_Related_Revenue] AS [Media_Related_Revenue_#3]
FROM (
    select androidid  as [device_id_IMEI],sum(PayedAmount) as [Media_Related_Revenue]
    from [DW_TD].[Tb_Fact_Android_Ascribe]
    where PayedAmount>0 and PayedAmount  is not null and IsPlacedFlag=1
    and  cast(left(cast(datekey as nvarchar(100)),4)+'-'+substring(cast(datekey as nvarchar(100)),5,2)+'-'+right(cast(datekey as nvarchar(100)),2) as date) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
    group by androidid 
)a left join (select * from [DA_Tagging].[id_mapping] where [device_id_IMEI] is not null and master_id is not null)b on a.[device_id_IMEI]=b.[device_id_IMEI]  collate Chinese_PRC_CS_AI_WS
)C
ON A.master_id=C.master_id
where isnull(A.master_id,isnull(B.master_id,C.master_id)) is not null
)z where DA_Tagging.online_purchase3.master_id =z.master_id
;

                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [media_related_abv]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 525.Media Related ABV：计算Attribution表中90天内的每个用户有效订单的销售总额/订单数
/*
is_placed_flag,sales_order_number，sephora_user_id，payed_amount
OrderID,IsPlacedFlag,PayedAmount
                
DW_Sensor.DWS_Sensor_Order_UTM_Attribution
[DW_TD].[Tb_Fact_IOS_Ascribe]
[DW_TD].[Tb_Fact_Android_Ascribe]
*/
                
-- 除app以外的其他渠道
update DA_Tagging.online_purchase3
set media_related_abv=media_related_revenue/media_related_order 
;              
                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [media_resource_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 526.Media Resource Preference
--要换成正式的表，因为正式的表中没有mapping表
-- 计算每个用户90天内销售额最多的渠道（PC/H5/MNP为mapping表匹配的channel，APP为ChannelName）

UPDATE DA_tagging.online_purchase3
set media_resource_preference = z.media_resource_preference
from(
select  isnull(A.master_id,isnull(B.master_id,C.master_id)) as master_id,
        case  when isnull([Media_Related_Revenue1],0)>=isnull([Media_Related_Revenue2],0) 
        then (case when isnull([Media_Related_Revenue1],0)>=isnull([Media_Related_Revenue3],0) then A.[Media_Resource_Preference] else C.[Media_Resource_Preference] collate Chinese_PRC_CS_AI_WS end)
        else (case when isnull([Media_Related_Revenue2],0)>=isnull([Media_Related_Revenue3],0) then B.[Media_Resource_Preference] else C.[Media_Resource_Preference] collate Chinese_PRC_CS_AI_WS  end) end as [Media_Resource_Preference]
                
from
                
--PC/H5/MNP
                
(select master_id,[Media_Related_Revenue1],[Media_Resource_Preference] from 
(select member_card, channel as [Media_Resource_Preference],[Media_Related_Revenue1]
from 
(
    select [member_card],channel,[Media_Related_Revenue1],row_number() over(partition by [member_card] order by [Media_Related_Revenue1] desc) rn
    from 
    (
        select [member_card],ss_utm_source,ss_utm_medium,sum(payed_amount) as [Media_Related_Revenue1]
        FROM [DW_Sensor].[DWS_Sensor_Order_UTM_Attribution]
        where attribution_type='1D' and payed_amount>0 and payed_amount is not null and is_placed_flag=1
        and  convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1) --近90天
        group by [member_card],ss_utm_source,ss_utm_medium
    )t1 
    left join DA_Tagging.coding_media_source t2 
    on t1.ss_utm_medium=t2.medium COLLATE SQL_Latin1_General_CP1_CI_AS
    group by [member_card],channel,[Media_Related_Revenue1]
)tt1 where rn =1
)a left join (select * from [DA_Tagging].[id_mapping] where sephora_card_no is not null and master_id is not null)b on a.[member_card]=b.sephora_card_no COLLATE SQL_Latin1_General_CP1_CI_AS
)A
full join 
                
-- ios
(select master_id,[Media_Related_Revenue2],[Media_Resource_Preference] from
(
select IDFA,CHANNELNAME as [Media_Resource_Preference],[Media_Related_Revenue2]
from
(
    select *,row_number()over(partition by IDFA order by [Media_Related_Revenue2] desc) rn
    from
    (
        select IDFA,CHANNELNAME,sum(payedamount) as [Media_Related_Revenue2]
        from  [DW_TD].[Tb_Fact_IOS_Ascribe]
        where PayedAmount>0 and PayedAmount is not null and IsPlacedFlag=1
        and  cast(left(cast(datekey as nvarchar(100)),4)+'-'+substring(cast(datekey as nvarchar(100)),5,2)+'-'+right(cast(datekey as nvarchar(100)),2) as date) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
        group by IDFA,CHANNELNAME
    ) t1
) t2
where rn = 1
)a left join (select * from [DA_Tagging].[id_mapping] where [device_id_IDFA] is not null and master_id is not null)b on a.IDFA=b.[device_id_IDFA]  collate Chinese_PRC_CS_AI_WS
)B
on A.master_id=B.master_id
                
full join 
-- 安卓
(select master_id,[Media_Resource_Preference],[Media_Related_Revenue3] from
(select AndroidId,CHANNELNAME as [Media_Resource_Preference],[Media_Related_Revenue3]
from
(
    select *,row_number()over(partition by AndroidId order by [Media_Related_Revenue3] desc) rn
    from
    (
        select AndroidId,CHANNELNAME,sum(payedamount) as [Media_Related_Revenue3]
        from  [DW_TD].[Tb_Fact_Android_Ascribe]
        where PayedAmount>0 and PayedAmount is not null and IsPlacedFlag=1
        and  cast(left(cast(datekey as nvarchar(100)),4)+'-'+substring(cast(datekey as nvarchar(100)),5,2)+'-'+right(cast(datekey as nvarchar(100)),2) as date) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
        group by AndroidId,CHANNELNAME
    ) t1
) t2
where rn = 1
)a  left join (select * from [DA_Tagging].[id_mapping] where [device_id_IMEI] is not null and master_id is not null)b on a.AndroidId=b.[device_id_IMEI]  collate Chinese_PRC_CS_AI_WS
)C
on A.master_id=C.master_id
)z
where DA_tagging.online_purchase3.master_id=z.master_id
;

                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [media_medium_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 527. 购买的投放媒介偏好：计算每个用户90天内销售额最多的媒介（PC/H5用mapping表匹配的Medium,MNP用mapping表匹配的Source,APP用CampaignName）
/*
DW_Sensor.DWS_Sensor_Order_UTM_Attribution
[DW_TD].[Tb_Fact_IOS_Ascribe]
[DW_TD].[Tb_Fact_Android_Ascribe] 
列：ss_utm_medium,CampaignName
*/

UPDATE DA_tagging.online_purchase3
set media_medium_preference = z.[Media_Medium_Preference]
from(
    select  isnull(A.master_id,isnull(B.master_id,isnull(C.master_id,D.master_id))) as master_id,
    case when isnull(A.[Media_Related_Revenue],0)>isnull(b.[Media_Related_Revenue],0) then (
    case when isnull(a.[Media_Related_Revenue],0)>isnull(c.[Media_Related_Revenue],0) then
    (case when isnull(a.[Media_Related_Revenue],0)>isnull(d.[Media_Related_Revenue],0) then a.[Media_Medium_Preference] else d.[Media_Medium_Preference] collate Chinese_PRC_CS_AI_WS  end)
    else (case when isnull(c.[Media_Related_Revenue],0)>isnull(d.[Media_Related_Revenue],0) then c.[Media_Medium_Preference] else d.[Media_Medium_Preference]  collate Chinese_PRC_CS_AI_WS  end) end)
    else(
    case when isnull(b.[Media_Related_Revenue],0)>isnull(c.[Media_Related_Revenue],0) then
    (case when isnull(b.[Media_Related_Revenue],0)>isnull(d.[Media_Related_Revenue],0) then b.[Media_Medium_Preference] else d.[Media_Medium_Preference] collate Chinese_PRC_CS_AI_WS  end)
    else (case when isnull(c.[Media_Related_Revenue],0)>isnull(d.[Media_Related_Revenue],0) then c.[Media_Medium_Preference] else d.[Media_Medium_Preference] collate Chinese_PRC_CS_AI_WS  end) end
    ) end AS [Media_Medium_Preference]
                
    from
    --PC/H5  ，用mapping表匹配出 medium
    (select master_id,[Media_Related_Revenue],[Media_Medium_Preference] from 
    (select member_card,[Media_Related_Revenue],Medium as [Media_Medium_Preference] 
    from 
    (
        select [member_card],t2.Medium,[Media_Related_Revenue],row_number() over(partition by [member_card] order by [Media_Related_Revenue] desc) rn
        from 
        (
            select [member_card],ss_utm_medium,sum(payed_amount) as [Media_Related_Revenue]
            FROM [DW_Sensor].[DWS_Sensor_Order_UTM_Attribution]
            where channel_cd in ('web','mobile')
                and attribution_type='1D'      -- channel限制为PC/H5
                and payed_amount>0 and payed_amount is not null -- 限制有效金额
                and is_placed_flag=1                       
                and  convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1) --近90天
            group by [member_card],ss_utm_medium
        )t1 
        left join DA_Tagging.coding_media_source t2 
        on t1.ss_utm_medium=t2.medium COLLATE SQL_Latin1_General_CP1_CI_AS
        group by [member_card],t2.Medium,[Media_Related_Revenue]
    )tt1 where rn =1
    )t1 left join (select * from [DA_Tagging].[id_mapping] where sephora_card_no is not null and master_id is not null)b on t1.[member_card]=b.sephora_card_no COLLATE SQL_Latin1_General_CP1_CI_AS
    )A
    full join 
                
    -- MNP用mapping表匹配的Source
                
    (select master_id,[Media_Related_Revenue],[Media_Medium_Preference] from(
    select member_card,[Media_Related_Revenue],Source as [Media_Medium_Preference]
    from 
    (
        select [member_card],t2.Source,[Media_Related_Revenue],row_number() over(partition by [member_card] order by [Media_Related_Revenue] desc) rn
        from 
        (
            select [member_card],ss_utm_medium,sum(payed_amount) as [Media_Related_Revenue]
            FROM [DW_Sensor].[DWS_Sensor_Order_UTM_Attribution]
            where channel_cd = 'MiniProgram'
                and attribution_type='1D'      -- channel限制为PC/H5
                and payed_amount>0 and payed_amount is not null -- 限制有效金额
                and is_placed_flag=1                       
                and  convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1) --近90天
            group by [member_card],ss_utm_medium
        )t1 
        left join DA_Tagging.coding_media_source t2 
        on t1.ss_utm_medium=t2.medium COLLATE SQL_Latin1_General_CP1_CI_AS 
        group by [member_card],t2.Source,[Media_Related_Revenue]
    )tt1 where rn =1
    )t1 left join (select * from [DA_Tagging].[id_mapping] where sephora_card_no is not null and master_id is not null)b on t1.[member_card]=b.sephora_card_no COLLATE SQL_Latin1_General_CP1_CI_AS 
    )B
                
        ON A.MASTER_ID =B.MASTER_ID
        FULL JOIN
    -- APP,IOS
    (SELECT MASTER_ID,[Media_Related_Revenue],Media_Medium_Preference FROM (
    select IDFA,[Media_Related_Revenue],CampaignName as Media_Medium_Preference
    from
    (
        select *,row_number()over(partition by IDFA order by Media_Related_Revenue desc) rn
        from
        (
            select IDFA,CampaignName,sum(payedamount) as [Media_Related_Revenue]
            from  [DW_TD].[Tb_Fact_IOS_Ascribe]
            where PayedAmount>0 and PayedAmount is not null and IsPlacedFlag=1
            and  cast(left(cast(datekey as nvarchar(100)),4)+'-'+substring(cast(datekey as nvarchar(100)),5,2)+'-'+right(cast(datekey as nvarchar(100)),2) as date) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
            group by IDFA,CampaignName
        ) t1
    ) t2
    where rn = 1
    )t1  left join (select * from [DA_Tagging].[id_mapping] where [device_id_IDFA] is not null and master_id is not null)b on t1.IDFA=b.[device_id_IDFA]  collate Chinese_PRC_CS_AI_WS
    )C
        ON A.MASTER_ID =C.MASTER_ID
    -- APP,安卓
    FULL JOIN
                
    (SELECT MASTER_ID,[Media_Related_Revenue],Media_Medium_Preference FROM
    (
    select AndroidId,[Media_Related_Revenue],CampaignName as Media_Medium_Preference
    from
    (
        select *,row_number()over(partition by AndroidId order by Media_Related_Revenue desc) rn
        from
        (
            select AndroidId,CampaignName,sum(payedamount) as [Media_Related_Revenue]
            from  [DW_TD].[Tb_Fact_Android_Ascribe]
            where PayedAmount>0 and PayedAmount is not null and IsPlacedFlag=1
            and  cast(left(cast(datekey as nvarchar(100)),4)+'-'+substring(cast(datekey as nvarchar(100)),5,2)+'-'+right(cast(datekey as nvarchar(100)),2) as date) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)
            group by AndroidId,CampaignName
        ) t1
    ) t2
    where rn = 1
    )t1  left join (select * from [DA_Tagging].[id_mapping] where [device_id_IMEI] is not null and master_id is not null)b on t1.AndroidId=b.[device_id_IMEI]  collate Chinese_PRC_CS_AI_WS
    )D ON  A.MASTER_ID =D.MASTER_ID
)z where DA_tagging.online_purchase3.MASTER_ID=z.master_id
;


                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [media_period_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 528. 购买的投放时段偏好：计算每个用户90天内最多销售额的有ss_utm_source/campaign及ss_utm_medium/channel这两列内容的place_time时段
/*
app渠道的数据需要新增，目前无法做
DW_Sensor.DWS_Sensor_Order_UTM_Attribution
[DW_TD].[Tb_Fact_IOS_Ascribe]
[DW_TD].[Tb_Fact_Android_Ascribe] 
列：ss_utm_medium,CampaignName
*/
--PC/H5/MNP
;                
UPDATE DA_tagging.online_purchase3
set media_period_preference = z.media_period_preference
from(
    select master_id,media_period_preference from
        (select member_card,
            case hour 
                when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
                when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
                when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
                when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
                when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' 
            end as media_period_preference  
        from
        (
            select [member_card],hour,[payed_amount_sum],row_number() over(partition by [member_card] order by [payed_amount_sum] desc) rn
            from 
            (
                select [member_card],datename(hour,place_time) as hour ,sum(payed_amount) as [payed_amount_sum]
                FROM [DW_Sensor].[DWS_Sensor_Order_UTM_Attribution]
                where attribution_type='1D' 
                    and payed_amount>0 and payed_amount is not null 
                    and is_placed_flag=1
                    and ss_utm_source is not null
                    and ss_utm_medium is not null     -- 对ss_utm_source，ss_utm_medium 做限制
                    and  convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1) --近90天
                group by [member_card],datename(hour,place_time)
            )t1 
        ) t2
        where t2.rn = 1
    )a left join (select * from [DA_Tagging].[id_mapping] where sephora_card_no is not null and master_id is not null)b on a.[member_card]=b.sephora_card_no COLLATE SQL_Latin1_General_CP1_CI_AS 
)z where DA_tagging.online_purchase3.master_id =z.master_id
 ;               
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [campaign_related_order]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 516.活动相关订单数：活动期间每个用户的总订单数
;
update DA_Tagging.online_purchase3
set campaign_related_order=z.order_count
from (
    select sales_member_id,count(distinct sales_order_number) as order_count
    from [DA_Tagging].[sales_order_vb_temp]   --使用临时表
    where CONVERT(varchar(100), place_time, 23) 
    in ( select distinct Campaign_Date from DA_Tagging.coding_campaign_name)-- 获取活动时间范围
    group by sales_member_id 
)z
where DA_Tagging.online_purchase3.sales_member_id=z.sales_member_id
;                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [campaign_related_revenue]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 517.活动相关销售额：活动期间每个用户的总销售额，item_apportion_amount，sales_member_id,master_id
 ;
                
update DA_Tagging.online_purchase3
set campaign_related_revenue=z.amount
from (
    select sales_member_id,sum(item_apportion_amount) as amount
    from [DA_Tagging].[sales_order_vb_temp]   --使用临时表
    where CONVERT(varchar(100), place_time, 23) 
    in (select distinct Campaign_Date from DA_Tagging.coding_campaign_name) -- 获取活动时间范围
    group by sales_member_id 
)z
where DA_Tagging.online_purchase3.sales_member_id=z.sales_member_id
 ;               
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [campaign_related_abv]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 518.活动相关客单价：计算活动期间每个用户的总销售额除以订单数的金额、
;
update DA_Tagging.online_purchase3
set campaign_related_abv=z.ABV
from (
    select sales_member_id,sum(item_apportion_amount)/count(distinct sales_order_number) as ABV
    from [DA_Tagging].[sales_order_vb_temp]   --使用临时表
    where CONVERT(varchar(100), place_time, 23) 
    in ( select distinct Campaign_Date from DA_Tagging.coding_campaign_name) -- 获取活动时间范围
    group by sales_member_id 
)z
where DA_Tagging.online_purchase3.sales_member_id=z.sales_member_id
 ;               
                
                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [campaign_type_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 519.Campaign Type Preference：活动期间购买的活动类型偏好  item_apportion_amount,place_time
-- 计算每个用户90天内销售额最多的活动类型，以时间判断活动类型
update DA_Tagging.online_purchase3
set campaign_type_preference=z.Campaign_Type
from (
    select sales_member_id,Campaign_Type
    from
    (
        select sales_member_id,Campaign_Type,row_number()over(partition by sales_member_id order by sum(item_apportion_amount) desc) as rn
        from
        (
            select distinct sales_member_id,item_apportion_amount,CONVERT(varchar(100), place_time, 23) as place_time 
            from [DA_Tagging].[sales_order_vb_temp]
                where convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)   -- 近90天
        ) t1    -- order表中取字段：sales_member_id、日期、金额、
        inner join 
        (select distinct Campaign_Date,Campaign_Type from DA_Tagging.coding_campaign_name) t2   -- 活动表中取字段：日期，活动类型
        on t1.place_time = t2.Campaign_Date
        group by sales_member_id,Campaign_Type
    ) t3    -- 在表1表2 基础上新增列：排序
    where rn = 1   
)z
where DA_Tagging.online_purchase3.sales_member_id=z.sales_member_id
 ;

                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [campaign_type_detail_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 520.活动期间购买的活动类型细分偏好：计算每个用户90天内销售额最多的活动类型细分，以时间判断活动类型细分
-- 思路与上方一致

update DA_Tagging.online_purchase3
set campaign_type_detail_preference=z.Campaign_Detail_2
from (
    select sales_member_id,Campaign_Detail_2
    from
    (
        select sales_member_id,Campaign_Detail_2,row_number()over(partition by sales_member_id order by sum(item_apportion_amount) desc) as rn
        from
        (
            select distinct sales_member_id,item_apportion_amount,CONVERT(varchar(100), place_time, 23) as place_time 
            from [DA_Tagging].[sales_order_vb_temp]
            where convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)   -- 近90天
        ) t1    -- order表中取字段：sales_member_id、日期、金额、
        inner join 
        (select distinct Campaign_Date,Campaign_Detail_2 from DA_Tagging.coding_campaign_name) t2   -- 活动表中取字段：日期，活动类型细分
        on t1.place_time = t2.Campaign_Date
        group by sales_member_id,Campaign_Detail_2
    ) t3    -- 在表1表2 基础上新增列：排序
    where rn = 1   
)z
where DA_Tagging.online_purchase3.sales_member_id=z.sales_member_id
;

                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [campaign_channel_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 521.活动期间购买的活动渠道偏好，计算每个用户90天内销售额最多的活动渠道

update DA_Tagging.online_purchase3
set campaign_channel_preference=z.store
from (
    select sales_member_id,store
    from
    (
        select sales_member_id,store,row_number()over(partition by sales_member_id order by sum(item_apportion_amount) desc) as rn
        from
        (
            select distinct sales_member_id,item_apportion_amount,store,sales_order_number
            from [DA_Tagging].[sales_order_vb_temp]
            where CONVERT(varchar(100), place_time, 23) in (select distinct Campaign_Date from DA_Tagging.coding_campaign_name)  -- 时间限制在活动时间内
                and convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 90) and convert(date,DATEADD(hour,8,getdate()) - 1)   -- 近90天
        ) t1    -- order表中取字段：sales_member_id、日期、金额
        group by sales_member_id,store
    ) t2   -- 在表1表2 基础上新增列：排序
    where rn = 1   
)z
where DA_Tagging.online_purchase3.sales_member_id=z.sales_member_id
;

                
                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [campaign_period_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 522.活动期间购买的活动时段偏好：90天内

update DA_Tagging.online_purchase3
set campaign_period_preference=z.[Campaign_Period_Preference]
from (
    select sales_member_id,
        case place_hour
            when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
            when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
            when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
            when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
            when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' 
        end as [Campaign_Period_Preference]  
    from
    (
        select sales_member_id,place_hour,row_number()over(partition by sales_member_id order by sum(item_apportion_amount) desc) as rn
        from
        (
            select distinct sales_member_id,item_apportion_amount,place_hour,sales_order_number
            from [DA_Tagging].[sales_order_vb_temp]
            where CONVERT(varchar(100), place_time, 23) in (select distinct Campaign_Date from DA_Tagging.coding_campaign_name)
            AND place_time BETWEEN CONVERT(varchar(100),DATEADD(day,-90,GETDATE()),23) AND CONVERT(varchar(100),GETDATE(),23) --限制为近90天
        ) t1    -- order表中取字段：sales_member_id、日期、金额
        group by sales_member_id,place_hour
    ) t2   -- 在表1表2 基础上新增列：排序
    where rn = 1   
)z
where DA_Tagging.online_purchase3.sales_member_id=z.sales_member_id
;

                
                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [private_sale_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 151 .最常消费的大促: Campaign_Name 通过订单日期做mapping 计算订单数取最多的大促时间

IF OBJECT_ID('tempdb..#private_sale_preference','U')  IS NOT NULL
drop table #private_sale_preference;
create table #private_sale_preference(
	sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	private_sale_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #private_sale_preference(sales_member_id,private_sale_preference)
select sales_member_id,Campaign_Name as private_sale_preference
from(
    select sales_member_id,Campaign_Name
    ,row_number() over(partition by sales_member_id order by Campaign_Name_cn desc) rn
    from(
        select sales_member_id,Campaign_Name,count(distinct sales_order_number) as Campaign_Name_cn
        from(
            select sales_member_id,place_time,Campaign_Name,sales_order_number
            from(
                select sales_member_id,place_time,sales_order_number
                from DA_Tagging.sales_order_basic_temp
                )t1 inner join DA_Tagging.coding_campaign_name tt1 on convert(date, t1.place_time) = tt1.Campaign_Date
            where Campaign_Type = 'Private Sales'  
        )t2 group by sales_member_id,Campaign_Name
    )t3 
)t4 where rn=1


update DA_Tagging.online_purchase3
set private_sale_preference= tt.private_sale_preference
from DA_Tagging.online_purchase3 t1
join #private_sale_preference tt on t1.sales_member_id = tt.sales_member_id

;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [holiday_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 152.最常消费的节假日：通过订单日期做mapping 计算订单数，取最多的节假日

IF OBJECT_ID('tempdb..#holiday_preference','U')  IS NOT NULL
drop table #holiday_preference;
create table #holiday_preference(
	sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	holiday_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #holiday_preference(sales_member_id,holiday_preference)
select sales_member_id,holidays_festivals as holiday_preference
from(
    select sales_member_id,holidays_festivals
    ,row_number() over(partition by sales_member_id order by order_cnt desc) AS rn
    from(
        select sales_member_id,holidays_festivals, count(distinct sales_order_number) as order_cnt
        from DA_Tagging.sales_order_basic_temp  t1 inner join DA_Tagging.coding_daytype  t2  on convert(date, t1.place_time) = t2.date 
        where holidays_festivals is not null
        group by sales_member_id,holidays_festivals
    ) t1
) t2
where rn = 1


update DA_Tagging.online_purchase3
set holiday_preference=tt.holiday_preference
from DA_Tagging.online_purchase3 t1
join #holiday_preference tt on t1.sales_member_id = tt.sales_member_id


                
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [season_preference] temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 153.最常消费的季节：通过订单日期做mapping 计算订单数取最多的季节
IF OBJECT_ID('tempdb..#season_preference','U')  IS NOT NULL
drop table #season_preference;
create table #season_preference(
	sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	season_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #season_preference(sales_member_id,season_preference)
select sales_member_id
,case when place_month in ('March','April','May') then 'Spring'
when place_month in ('June','July','August') then 'Summer'
when place_month in ('September','October','November') then 'Autumn'
else 'Winter' end as season_preference
from(
    select sales_member_id,place_month
    ,row_number() over (partition by sales_member_id order by count(distinct sales_order_number) DESC ) AS rn
    from(
	    select sales_member_id, datename(month,place_date) as place_month, sales_order_number
	    from DA_Tagging.sales_order_basic_temp 
    ) t1 group by sales_member_id, place_month
) t2 where rn = 1
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate [season_preference]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.online_purchase3
set season_preference=tt.season_preference
from DA_Tagging.online_purchase3 t1
join #season_preference tt on t1.sales_member_id = tt.sales_member_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase [propensity_score]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.online_purchase3
    set propensity_score = t2.[label]
    from DA_Tagging.online_purchase3 tt
    join DA_Tagging.online_predict_temp1 t2 on tt.sales_member_id = t2.sales_member_id  


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase [one_year_sales_forecast]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.online_purchase3
    set one_year_sales_forecast = t2.[label]
    from DA_Tagging.online_purchase3 tt
    join DA_Tagging.online_predict_temp2 t2 on tt.sales_member_id = t2.sales_member_id    




insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Online Purchase','Tagging System Online Purchase, Generate Online Purchase Tag End',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;


END
GO
