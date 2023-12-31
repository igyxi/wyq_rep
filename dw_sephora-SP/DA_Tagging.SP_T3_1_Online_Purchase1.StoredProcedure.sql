/****** Object:  StoredProcedure [DA_Tagging].[SP_T3_1_Online_Purchase1]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T3_1_Online_Purchase1] AS
BEGIN

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','online purchase1 start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, create product table Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

TRUNCATE TABLE DA_Tagging.online_purchase_product
-- go
insert into DA_Tagging.online_purchase_product
select distinct t2.product_id,t1.sku_cd as sku_code,t2.category as category,t2.subcategory as subcategory,t2.thirdcategory as thirdcategory
,t2.skin_type as skin_type,t1.sap_price as price,t2.brand,t2.skincare_function_basic,t2.skincare_function_special,t2.makeup_function
,t2.makeup_scene,t2.makeup_look,t2.makeup_color,t2.fragrances_stereotype,t2.fragrances_intensity,t2.fragrances_impression
,t02.fragrances_stereotype_cn,t03.fragrances_intensity_cn,t04.fragrances_impression_cn
,case when t1.product_name_cn like '%礼盒%' then 1 else 0 end as if_gift
from [DW_Product].[V_SKU_Profile] as t1
join DA_Tagging.sephoraproductlist as t2
on t1.sku_cd collate Chinese_PRC_CS_AI_WS= t2.sku_code collate Chinese_PRC_CS_AI_WS
left join DA_Tagging.fragrances_cn t02 on t2.fragrances_stereotype collate Chinese_PRC_CS_AI_WS=t02.fragrances_stereotype collate Chinese_PRC_CS_AI_WS
left join DA_Tagging.fragrances_cn t03 on t2.fragrances_intensity collate Chinese_PRC_CS_AI_WS=t03.fragrances_intensity collate Chinese_PRC_CS_AI_WS
left join DA_Tagging.fragrances_cn t04 on t2.fragrances_impression collate Chinese_PRC_CS_AI_WS=t04.fragrances_impression collate Chinese_PRC_CS_AI_WS
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, create result table Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

TRUNCATE TABLE DA_Tagging.online_purchase1
-- go
insert into DA_Tagging.online_purchase1(master_id,sales_member_id)
select distinct master_id,sales_member_id from DA_Tagging.sales_id_mapping
where master_id is not null
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [preferred_category] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 偏好的一级品类（销售额）：Preferred category
update DA_Tagging.online_purchase1
set preferred_category = tt2.preferred_category
from DA_Tagging.online_purchase1 tt1
join(
	select sales_member_id,preferred_category
	from(
		select sales_member_id,case when casales=max(casales) over(partition by sales_member_id) then category else null end preferred_category
		from(
			select sales_member_id,t2.category,sum(item_apportion_amount) as casales
			from(
				select sales_member_id,item_apportion_amount,item_sku_cd
				from DA_Tagging.sales_order_vb_temp
			)t1
			join (
				select sku_code,category
				from DA_Tagging.online_purchase_product
			) t2
			on t1.item_sku_cd=t2.sku_code
			group by sales_member_id,t2.category
		)tt1
	)ttt1
	where preferred_category is not null
)tt2 on tt1.sales_member_id=tt2.sales_member_id
-- go
--update DA_Tagging.online_purchase1
--set preferred_category = tt2.preferred_category
--from DA_Tagging.online_purchase1 tt1
--join(
--   select sales_member_id,COALESCE(preferred_category,LAST_VALUE(preferred_category) over(partition by sales_member_id 
--   order by preferred_category desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) as preferred_category
--   from(
--       select sales_member_id
--       ,case when casales=max(casales) over(partition by sales_member_id) then category else null end preferred_category
--       from(
--           select sales_member_id,t2.category
--           ,case when t2.category is null then null else sum(item_apportion_amount) over(partition by sales_member_id,t2.category) end casales
--           from(
--               select sales_member_id,item_apportion_amount,item_sku_cd
--               from DA_Tagging.sales_order_vb_temp
--               )t1
--           left join
--           (
--               select sku_code,category
--               from DA_Tagging.online_purchase_product
--           ) t2
--       on t1.item_sku_cd=t2.sku_code
--       )tt1
--   )ttt1
--)tt2 on tt1.sales_member_id=tt2.sales_member_id
--go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [preferred_subcategory] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 偏好的二级品类（销售额）：Preferred Subcategory
update DA_Tagging.online_purchase1
set preferred_subcategory = tt2.preferred_subcategory
from DA_Tagging.online_purchase1 tt1
join(
	select sales_member_id,preferred_subcategory
	from (
		select sales_member_id,case when susales=max(susales) over(partition by sales_member_id) then subcategory else null end preferred_subcategory
		from(
			select sales_member_id,t2.subcategory,sum(item_apportion_amount) as susales
			from(
				select sales_member_id,item_apportion_amount,item_sku_cd
				from DA_Tagging.sales_order_vb_temp
			) t1
			join (
				select sku_code,subcategory
				from DA_Tagging.online_purchase_product
			) t2
			on t1.item_sku_cd=t2.sku_code
			group by sales_member_id,t2.subcategory
		)tt1
	)ttt1
	where preferred_subcategory is not null
)tt2 on tt1.sales_member_id=tt2.sales_member_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [preferred_thirdcategory] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 偏好的三级品类（销售额）：Preferred Thirdcategory
update DA_Tagging.online_purchase1
set preferred_thirdcategory = tt2.preferred_thirdcategory
from DA_Tagging.online_purchase1 tt1
join(
	select sales_member_id,preferred_thirdcategory
	from(
		select sales_member_id,case when thsales=max(thsales) over(partition by sales_member_id) then thirdcategory else null end preferred_thirdcategory
		from(
			select sales_member_id,t2.thirdcategory,sum(item_apportion_amount) as thsales
			from(
				select sales_member_id,item_apportion_amount,item_sku_cd
				from DA_Tagging.sales_order_vb_temp
			) t1
			join (
				select sku_code,thirdcategory
				from DA_Tagging.online_purchase_product
			) t2
			on t1.item_sku_cd=t2.sku_code
			group by sales_member_id,t2.thirdcategory
		)tt1
	)ttt1
	where preferred_thirdcategory is not null
)tt2 on tt1.sales_member_id=tt2.sales_member_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [skin_type] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 皮肤类型：Skin Type  
update DA_Tagging.online_purchase1
set skin_type = tt2.skin_type
from DA_Tagging.online_purchase1 tt1
join(
   select sales_member_id,skin_type from ( 
       select sales_member_id,skin_type,row_number() over (partition by sales_member_id order by skinsales desc) as rn
       from(
           select sales_member_id,t2.skin_type,case when t2.skin_type is null then 0 else sum(item_apportion_amount) over(partition by sales_member_id,t2.skin_type) end skinsales
           from(
               select sales_member_id,item_apportion_amount,item_sku_cd
               from DA_Tagging.sales_order_vb_temp
           )t1
           left join( 
               select sku_code,case when skin_type='各种肤质' then null else skin_type end as skin_type
               from DA_Tagging.online_purchase_product
           ) t2
           on t1.item_sku_cd=t2.sku_code
           )tt  
       )ttt where rn=1
)tt2 on tt1.sales_member_id=tt2.sales_member_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [makeup_maturity],[skincare_maturity] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 品类成熟度：Skincare Maturity
-- 品类成熟度：Makeup Maturity
update DA_Tagging.online_purchase1
set makeup_maturity = case when tt2.makeupsucnt>5 then 'Level I' when tt2.makeupsucnt>3 then 'Level II' when tt2.makeupsucnt>=1 then 'Level III' end
   ,skincare_maturity = case when tt2.skincaresucnt>5 then 'Level I' when tt2.skincaresucnt>3 then 'Level II' when tt2.skincaresucnt>=1 then 'Level III' end
from DA_Tagging.online_purchase1 tt1
join(
   select distinct sales_member_id
   ,COALESCE(makeupsucnt,LAST_VALUE(makeupsucnt) over(partition by sales_member_id order by makeupsucnt desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) as makeupsucnt
   ,COALESCE(skincaresucnt,LAST_VALUE(skincaresucnt) over(partition by sales_member_id order by skincaresucnt desc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) as skincaresucnt
   from(
       select sales_member_id
       ,case when makeupsucnt=max(makeupsucnt) over(partition by sales_member_id) then makeupsucnt else null end as makeupsucnt
       ,case when skincaresucnt=max(skincaresucnt) over(partition by sales_member_id) then skincaresucnt else null end as skincaresucnt
       from(
           select sales_member_id,t2.category
           ,count(distinct case when t2.category='Makeup' then t2.subcategory else null end) as makeupsucnt
           ,count(distinct case when t2.category='Skincare' then t2.subcategory else null end) as skincaresucnt
           from(
               select sales_member_id,item_sku_cd
               from DA_Tagging.sales_order_vb_temp
               )t1
           left join DA_Tagging.online_purchase_product t2
           on t1.item_sku_cd=t2.sku_code
           group by sales_member_id,t2.category
       )tt1
   )ttt1
)tt2  on tt1.sales_member_id=tt2.sales_member_id


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [makeup_price_range] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 产品价位段：Makeup Price Range  make up 
update DA_Tagging.online_purchase1
set makeup_price_range = tt2.makeup_price_range
from DA_Tagging.online_purchase1 tt1
join(
   select sales_member_id,makeup_price_range,row_number() over(partition by sales_member_id order by makeupprocnt desc) rn
   from(
       select sales_member_id,makeup_price_range,count(distinct product_id) as makeupprocnt
       from(
           select sales_member_id
           ,t2.product_id
           ,case when t2.price<=0 then '[0]'
                 when t2.price>0 and t2.price<=100 then '(0,100]'   when t2.price>100 and t2.price<=200 then '(100,200]'
                 when t2.price>200 and t2.price<=300 then '(200,300]' when t2.price>300 and t2.price<=400 then '(300,400]'
                 when t2.price>400 and t2.price<=500 then '(400,500]' when t2.price>500 and t2.price<=700 then '(500,700]'
                 when t2.price>700 and t2.price<=1000 then '(700,1000]' when t2.price>1000 and t2.price<=1500 then '(1000,1500]'
                 when t2.price>1500 and t2.price<=2000 then '(1500,2000]'
                 when t2.price>2000 then '>2000' end as makeup_price_range
           from(
               select sales_member_id,item_sku_cd
               from DA_Tagging.sales_order_vb_temp
           )t1
           left join DA_Tagging.online_purchase_product t2
           on t1.item_sku_cd=t2.sku_code
           where t2.category='Makeup'
       )tt1
       group by sales_member_id,makeup_price_range
   )ttt1
)tt2
on tt1.sales_member_id=tt2.sales_member_id
where rn=1
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [skincare_price_range] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 产品价位段：Skincare Price Range    skincare 
update DA_Tagging.online_purchase1
set skincare_price_range = tt2.skincare_price_range
from DA_Tagging.online_purchase1 tt1
join(
   select sales_member_id,skincare_price_range,row_number() over(partition by sales_member_id order by skincareprocnt desc) rn
   from(
       select sales_member_id,skincare_price_range
       ,count(distinct product_id) as skincareprocnt
       from(
           select sales_member_id
           ,t2.product_id
           ,case when t2.price<=0 then '[0]' when t2.price>0 and t2.price<=100 then '(0,100]'
           when t2.price>100 and t2.price<=200 then '(100,200]' when t2.price>200 and t2.price<=300 then '(200,300]'
           when t2.price>300 and t2.price<=400 then '(300,400]' when t2.price>400 and t2.price<=500 then '(400,500]'
           when t2.price>500 and t2.price<=600 then '(500,600]' when t2.price>600 and t2.price<=700 then '(600,700]'
           when t2.price>700 and t2.price<=800 then '(700,800]' when t2.price>800 and t2.price<=900 then '(800,900]'
           when t2.price>900 and t2.price<=1000 then '(900,1000]' when t2.price>1000 then '>1000' end as skincare_price_range
           from(
               select sales_member_id,item_sku_cd
               from DA_Tagging.sales_order_vb_temp
           )t1
           left join DA_Tagging.online_purchase_product t2
           on t1.item_sku_cd=t2.sku_code
           where t2.category='Skincare'
       )tt1
       group by sales_member_id,skincare_price_range
   )tt2
)tt2
on tt1.sales_member_id=tt2.sales_member_id
where rn=1
-- go

-- 护肤需求：Skincare Demand     
-- 美妆需求：Makeup Demand   
-- 香水需求：Fragrance Demand     5min
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [makeup_demand],[fragrance_demand],[skincare_demand] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
;with temp AS (
 select sales_member_id,item_category,item_sku_cd
 from (
 select sales_member_id,item_category,item_sku_cd,row_number() over (partition by sales_member_id,item_category order by sku_sales desc) as rn,sku_sales
 from
     (
     select sales_member_id,item_category,item_sku_cd,sum(item_apportion_amount) over(partition by sales_member_id,item_category,item_sku_cd) as sku_sales
     from DA_Tagging.sales_order_vb_temp
     )t1
 )tt1 where rn=1
),
temp1 AS (
select distinct sku_code,category as item_category
,STUFF(COALESCE(','+skincare_function_basic,'')+COALESCE(','+skincare_function_special,''),1,1,'') as skincare_demand
,STUFF(COALESCE(','+makeup_function,'')+COALESCE(','+makeup_scene,'')+COALESCE(','+makeup_look,'')+COALESCE(','+makeup_color,''),1,1,'') as makeup_demand
,STUFF(COALESCE(','+fragrances_stereotype_cn,'')+COALESCE(','+fragrances_intensity_cn,'')+COALESCE(','+fragrances_impression_cn,''),1,1,'') as fragrance_demand
from(
select sku_code,category
   ,case when skincare_function_basic='null' then null when skincare_function_basic='' then null else skincare_function_basic end as skincare_function_basic
   ,case when skincare_function_special='null' then null when skincare_function_special='' then null else skincare_function_special end as skincare_function_special
   ,case when makeup_function='null' then null when makeup_function='' then null else makeup_function end as makeup_function
   ,case when makeup_scene='null' then null when makeup_scene='' then null else makeup_scene end as makeup_scene
   ,case when makeup_look='null' then null when makeup_look='' then null else makeup_look end as makeup_look
   ,case when makeup_color='null' then null when makeup_color='' then null else makeup_color end as makeup_color
   ,case when fragrances_stereotype_cn='null' then null when fragrances_stereotype_cn='' then null else fragrances_stereotype_cn end as fragrances_stereotype_cn
   ,case when fragrances_intensity_cn='null' then null when fragrances_intensity_cn='' then null else fragrances_intensity_cn end as fragrances_intensity_cn
   ,case when fragrances_impression_cn='null' then null when fragrances_impression_cn='' then null else fragrances_impression_cn end as fragrances_impression_cn
   from(
       select sku_code,category,skincare_function_basic,skincare_function_special,makeup_function,makeup_scene
         ,makeup_look,makeup_color,fragrances_stereotype_cn,fragrances_intensity_cn,fragrances_impression_cn
       from DA_Tagging.online_purchase_product)t0
   )t1
)
update DA_Tagging.online_purchase1
set makeup_demand =tt2.makeup_demand
   ,fragrance_demand =tt2.fragrance_demand
   ,skincare_demand =tt2.skincare_demand
from DA_Tagging.online_purchase1 tt1
join(
   select sales_member_id
   ,max(case when item_category = 'Makeup' then makeup_demand else null end) as makeup_demand
   ,max(case when item_category = 'Fragrance' then fragrance_demand else null end) as fragrance_demand
   ,max(case when item_category = 'Skincare' then skincare_demand else null end) as skincare_demand
   from 
   (
       select sales_member_id,item_sku_cd,t1.item_category,makeup_demand,fragrance_demand,skincare_demand 
       from temp t1
       left join temp1 t2  on t1.item_sku_cd=t2.sku_code
   )t group by sales_member_id
)tt2
on tt1.sales_member_id=tt2.sales_member_id


-- 线上大促敏感度：Private Sale Sensitivity  1222539条数据 4min
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [private_sale_sensitivity] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

update DA_Tagging.online_purchase1
set private_sale_sensitivity = tt2.private_sale_sensitivity
from DA_Tagging.online_purchase1 tt1
join(
   select sales_member_id,case when dacu=N'大促时购买' and no_dacu= N'非大促时购买' then N'大促及非大促都购买'
   when dacu=N'大促时购买' and no_dacu is null then N'只在大促购买' else N'只在非大促购买' end as private_sale_sensitivity
   from(
       select sales_member_id,
           max (case promotion_behavior when N'大促时购买' then N'大促时购买' else null end) dacu,
           max (case promotion_behavior when N'非大促时购买' then N'非大促时购买' else null end ) no_dacu
       from(
           select distinct sales_member_id
           ,case when tt1.Campaign_Date is not null then N'大促时购买' else N'非大促时购买' end as promotion_behavior
           from(
				select sales_member_id,sales_order_number,place_time 
                from DA_Tagging.sales_order_basic_temp
               ) t1
           left join (
					select Campaign_Date
					from DA_Tagging.coding_campaign_name
					where Campaign_Type = 'Private Sales' 
					) tt1 on convert(date, t1.place_time) = tt1.Campaign_Date
       )tt group by sales_member_id
   )ttt
)tt2
on tt1.sales_member_id=tt2.sales_member_id


-- 购买动机：Key Motivation
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [shopping_driver] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

IF OBJECT_ID('tempdb..#shopping_driver_temp') IS NOT NULL 
DROP TABLE #shopping_driver_temp; 
create table #shopping_driver_temp(
    sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    last_360d_purchase_amount float,
    seasonal_share nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    festival_share nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    promotion_share nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    gifting_share nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    exclusive_share nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
-- go
insert into #shopping_driver_temp(sales_member_id,last_360d_purchase_amount)
select sales_member_id,sum(product_amount) as last_360d_purchase_amount 
from DA_Tagging.sales_order_basic_temp
where convert(varchar(100),place_time,23) between dateadd(dd,-360,DATEADD(hour,8,getdate())) and dateadd(dd,1,DATEADD(hour,8,getdate()))
      and product_amount > 0
group by sales_member_id

update #shopping_driver_temp
set seasonal_share = t2.seasonal_sales/t1.last_360d_purchase_amount
from #shopping_driver_temp t1
join (
    select sales_member_id,sum(product_amount) as seasonal_sales 
    from DA_Tagging.sales_order_basic_temp
    where month(convert(varchar(100),place_time,23)) in (3,6,9,12) 
    group by sales_member_id
)t2 on t1.sales_member_id=t2.sales_member_id

update #shopping_driver_temp
set festival_share = t3.festival_sales/t1.last_360d_purchase_amount
from #shopping_driver_temp t1
join (
    select sales_member_id,sum(product_amount) as festival_sales
    from DA_Tagging.sales_order_basic_temp t1
    cross join (select qixi from DA_Tagging.qixi_lunar where year=year(DATEADD(hour,8,getdate())))t2
    where convert(varchar(100),place_time,23) between dateadd(day,-7,concat(year(DATEADD(hour,8,getdate())),'-','01-01')) and dateadd(day,7,concat(year(DATEADD(hour,8,getdate())),'-','01-01'))--New Year
        or convert(varchar(100),place_time,23) between dateadd(day,-7,concat(year(DATEADD(hour,8,getdate())),'-','02-14')) and dateadd(day,7,concat(year(DATEADD(hour,8,getdate())),'-','02-14'))--Valentine
        or convert(varchar(100),place_time,23)  between dateadd(day,-7,qixi) and dateadd(day,7,qixi) --Qixi
        or convert(varchar(100),place_time,23) between dateadd(day,-7,concat(year(DATEADD(hour,8,getdate()))-1,'-','12-25')) and dateadd(day,7,concat(year(DATEADD(hour,8,getdate()))-1,'-','12-25'))--Christmas
    group by sales_member_id
)t3 on t1.sales_member_id=t3.sales_member_id

update #shopping_driver_temp
set promotion_share = t4.promotion_sales/t1.last_360d_purchase_amount
from #shopping_driver_temp t1
join (
    select sales_member_id,sum(sales) as promotion_sales
    from (
        select sales_member_id,item_apportion_amount as sales,item_sku_cd,item_quantity as qtys
        from DA_Tagging.sales_order_vb_temp
    ) t1 
    left outer join 
    DA_Tagging.online_purchase_product t2 on t1.item_sku_cd=t2.sku_code
    where t1.sales/t1.qtys<t2.price
    group by sales_member_id
)t4 on t1.sales_member_id=t4.sales_member_id

update #shopping_driver_temp
set gifting_share = t5.gift_sales/t1.last_360d_purchase_amount
from #shopping_driver_temp t1
join (
    select sales_member_id,sum(sales) as gift_sales
    from (
        select sales_member_id,item_apportion_amount as sales,item_sku_cd
        from DA_Tagging.sales_order_vb_temp
    ) t1 
    left outer join
    DA_Tagging.online_purchase_product t2 on t1.item_sku_cd=t2.sku_code
    where t2.if_gift=1
    group by sales_member_id
)t5 on t1.sales_member_id=t5.sales_member_id

update #shopping_driver_temp
set exclusive_share = t6.exclusive_sales/t1.last_360d_purchase_amount
from #shopping_driver_temp t1
join (
    select sales_member_id,sum(sales) as exclusive_sales
    from (
        select sales_member_id,item_apportion_amount as sales,item_sku_cd 
        from DA_Tagging.sales_order_vb_temp 
        where item_brand_type='Exclusive'
    ) t1 group by sales_member_id
)t6 on t1.sales_member_id=t6.sales_member_id

update DA_Tagging.online_purchase1
set shopping_driver = case share
when 'seasonal_share' then N'季度'
when 'festival_share' then N'节日'
when 'promotion_share' then N'促销'
when 'gifting_share' then N'礼盒'
when 'exclusive_share' then N'专卖' else N'现货' end
from DA_Tagging.online_purchase1 tt1
left outer join(
    select sales_member_id,share 
    from(
        select sales_member_id,share,score,row_number() over(partition by sales_member_id order by score desc) as rn
        from(
            select sales_member_id,share,score from #shopping_driver_temp 
            unpivot (score for share in([seasonal_share],[festival_share],[promotion_share],[gifting_share],[exclusive_share]))stu_Info
        )t
    )t1 where rn=1 
)tt2
on tt1.sales_member_id=tt2.sales_member_id
-- go


-- 线上价格敏感度：Price Sensitivity  
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','Tagging System Online Purchase Update, [price_sensitivity] Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

update DA_Tagging.online_purchase1
set price_sensitivity = tt2.price_sensitivity 
from DA_Tagging.online_purchase1 tt1
join(
select sales_member_id
,case when price_sensitivity>percentile_7 then N'高'
when price_sensitivity>percentile_3 and price_sensitivity<=percentile_7 then N'中'
when price_sensitivity<=percentile_3 then N'低' else null end as price_sensitivity
from(
    select sales_member_id
    ,round(count(distinct if_discount)/cast(count(sales_order_number) as float), 2) as price_sensitivity
    from(
            select sales_member_id,sales_order_number
            ,case when count(if_discount)<>0 then sales_order_number
            else null end as if_discount
            from(
                    select sales_member_id,sales_order_number
                    ,case when adjustment_amount <>0 then adjustment_amount
                    when adjustment_amount =0 then null else null end as if_discount
                    from (
                        select sales_member_id,sales_order_number,adjustment_amount
                        from DA_Tagging.sales_order_basic_temp
                         ) t1
                ) t2
        group by sales_member_id,sales_order_number
        )tt2 group by sales_member_id
    )t3
cross join 
    (
        select min(per) as percentile_3,max(per) as percentile_7
        from (
            select percentile,max(price_sensitivity) as per
            from (
                select NTILE(10) over(order by price_sensitivity) as percentile,price_sensitivity
                from (
                    select sales_member_id,round(count(distinct if_discount)/cast(count(sales_order_number) as float), 2) as price_sensitivity
                    from(
                        select sales_member_id,sales_order_number
                        ,case when adjustment_amount <>0 then adjustment_amount
                        when adjustment_amount =0 then null else null end as if_discount
                        from (
                            select sales_member_id,sales_order_number,adjustment_amount
                            from DA_Tagging.sales_order_basic_temp
                            ) t1
                    ) t2 
                    group by sales_member_id
                )t3
            )t4
            where percentile <= 7 and percentile>=3
            group by percentile
        )t5
    )t1
)tt2
on tt1.sales_member_id=tt2.sales_member_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_1','online purchase1 end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

END
GO
