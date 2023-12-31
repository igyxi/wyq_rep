/****** Object:  StoredProcedure [DA_Tagging].[SP_T2_3_Online_Purchase2_BK]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T2_3_Online_Purchase2_BK] AS
BEGIN

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','online purchase2 start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

---- online purchase2
/* hive--sql server
 1.string --> nvarchar(255)
 2.oms.v_oms_sales_order_vb_level_df    -->    DW_OMS.V_Sales_Order_VB_Level
 3.oms.v_oms_sales_order_sku_level_df   -->    DW_OMS.V_Sales_Order_SKU_Level
 4.oms.v_oms_sales_order_basic_level_df -->    DW_OMS.V_Sales_Order_Basic_Level
 5."," --> go
 pivot
 Select Name FROM SysColumns 
 Where id=Object_Id('dbo.IHGBrandHotelYTDRating')
*/
----------------------------------------------------------------------------------------------------

-- member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS
-- member_card nvarchar(255) collate Chinese_PRC_CS_AI_WS
-- store nvarchar(255) collate Chinese_PRC_CS_AI_WS
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, member_id temp1 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
-- 取每个 member_card最新绑定的卡号
TRUNCATE TABLE DA_Tagging.sales_member_id
-- go
----20210707修改
insert DA_Tagging.sales_member_id(member_id,member_card)
select member_id,member_card
from(
   select member_id
   ,row_number() over(partition by member_id order by place_time desc) as rn
   ,t1.member_card as member_card
   from( 
       select member_id, place_time,REPLACE(member_card,'JD','') as member_card,store_cd
       from DW_OMS.V_Sales_Order_Basic_Level
       where is_placed_flag=1 and product_amount>0 and member_card<>'0'
	   --0706修改 ：订单表取180天数据 --> 取全量的数据
	   --and convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1) 
       )t1
	where isnumeric(member_card) = 1
   )tt1 where rn=1


--t2.member_id is not null then t2.member_card 如果t2的memberid不是空的 就用t2表中的membercard
--else t1.member_id end as sales_member_id  t2的memberid是空的那说明t2的membercard也是空的 用t1中的memberid
-- declare @datetime varchar(100) = ((CONVERT(varchar(100), DATEADD(hour,8,getdate()), 21)))
-- print( + @datetime + ' Tagging System Online Purchase Update, member_id temp2 Start...')
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, member_id temp2 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 把卡号对应到 masterid上
-- master_id bigint,
-- sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
-- store nvarchar(255) collate Chinese_PRC_CS_AI_WS,
-- flag int
TRUNCATE TABLE DA_Tagging.sales_id_mapping
-- go
----20210707修改
insert DA_Tagging.sales_id_mapping(sales_member_id)
select distinct case when t2.member_id is not null then t2.member_card else t1.member_id end as sales_member_id
from(
		select member_id
		from DW_OMS.V_Sales_Order_Basic_Level
		where is_placed_flag=1 and product_amount>0
		--0706修改 ：订单表取180天数据 --> 取全量的数据
		--and convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1) 
	    group by member_id
	)t1 
	left outer join DA_Tagging.sales_member_id t2  on t1.member_id = t2.member_id 

--insert DA_Tagging.sales_id_mapping(sales_member_id,store)
--select distinct case when t2.member_id is not null then t2.member_card else t1.member_id end as sales_member_id
--,case when t2.member_id is not null then t2.store else t3.store end as store
--from(
--		select member_id,store_cd
--		from DW_OMS.V_Sales_Order_Basic_Level
--		where is_placed_flag=1 and product_amount>0
--		--0706修改 ：订单表取180天数据 --> 取全量的数据
--		--and convert(date, place_time) between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1) 
--	    group by member_id,store_cd
--	)t1 
--	left outer join DA_Tagging.sales_member_id t2  on t1.member_id = t2.member_id 
--	left outer join DA_Tagging.channel_store t3 on t1.store_cd = t3.store_cd
-- go

update DA_Tagging.sales_id_mapping 
set master_id = b.master_id,
    flag=1
from DA_Tagging.sales_id_mapping a
join (
	select master_id,sephora_card_no
	from DA_Tagging.id_mapping
	where invalid_date='9999-12-31' and sephora_card_no is not null
)b
on a.sales_member_id = b.sephora_card_no
-- go

update DA_Tagging.sales_id_mapping
set master_id = b.master_id,
	flag=2
from DA_Tagging.sales_id_mapping as a
join (
	select master_id,jd_member_id
	from DA_Tagging.id_mapping
	where invalid_date='9999-12-31' and jd_member_id is not null
)b
on a.sales_member_id = b.jd_member_id
where a.master_id is NULL -- and a.store=N'京东'
-- go

update DA_Tagging.sales_id_mapping
set master_id = b.master_id,
	flag=3
from DA_Tagging.sales_id_mapping as a
join (
	select master_id,tmall_member_id
	from DA_Tagging.id_mapping
	where invalid_date='9999-12-31' and tmall_member_id is not null
)b
on a.sales_member_id = b.tmall_member_id
where a.master_id is NULL-- and a.store=N'天猫'
-- go

update DA_Tagging.sales_id_mapping
set master_id = b.master_id,
	flag=4
from DA_Tagging.sales_id_mapping as a
join (
	select master_id,red_member_id
	from DA_Tagging.id_mapping
	where invalid_date='9999-12-31' and red_member_id is not null
)b
on a.sales_member_id = b.red_member_id
where a.master_id is NULL --and a.store=N'小红书'
-- go


delete from DA_Tagging.sales_id_mapping
where sales_member_id in(
	select distinct sales_member_id
	from(
		select master_id,sales_member_id
		,row_number() over (partition by master_id order by flag) rn
		from DA_Tagging.sales_id_mapping
	)t1 where rn<>1
)


--------------------------------------------------------------------------------------------------
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, order basic temp Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

TRUNCATE TABLE DA_Tagging.sales_order_basic_temp
-- go
insert into DA_Tagging.sales_order_basic_temp
select t1.sales_order_number
,case when t3.member_id  is not null then t3.member_card  else t1.member_id end as sales_member_id
,t2.store,t2.channel,t1.item_vb_quantity,t1.is_placed_flag,t1.product_amount
,t1.place_time,convert(date,t1.place_time) as place_date,t1.adjustment_amount,t1.city,t1.district,t1.member_card_grade
from(
   select sales_order_number,member_id,city,district
   ,case when member_card_grade in ('PINK','WHITE','BLACK','GOLD') 
   then UPPER(SUBSTRING(member_card_grade,1,1))+LOWER(SUBSTRING(member_card_grade,2,( SELECT LEN(member_card_grade)))) 
   else null end as member_card_grade
   ,store_cd,channel_cd,item_vb_quantity,is_placed_flag,product_amount,place_time,adjustment_amount
   from DW_OMS.V_Sales_Order_Basic_Level
   where is_placed_flag=1 and product_amount>0
   )t1
left outer join DA_Tagging.channel_store t2 on t1.store_cd = t2.store_cd and t1.channel_cd=t2.channel_cd
left outer join DA_Tagging.sales_member_id t3 on t1.member_id = t3.member_id 
-- go



--------------------------------------------------------------------------------------------------
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, order vb temp Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

TRUNCATE TABLE  DA_Tagging.sales_order_vb_temp
-- go
insert into DA_Tagging.sales_order_vb_temp
select sales_order_number,case when t2.member_id is not null then t2.member_card else t1.member_id end as sales_member_id
   ,t3.store,t3.channel,item_category,item_brand_type,item_quantity,item_brand_name
   ,item_brand_name_cn,item_sku_cd,is_placed_flag,item_apportion_amount,place_time,datepart( hour,place_time) as place_hour,wd_name,item_name,item_product_id,t4.kol_theme
from(
       select sales_order_number,member_id,item_name,item_product_id,store_cd,channel_cd
           ,case when item_category='MAKE UP' then 'Makeup'
           else UPPER(SUBSTRING(item_category,1,1))+LOWER(SUBSTRING(item_category,2,( SELECT LEN(item_category)))) end as item_category
           ,UPPER(SUBSTRING(item_brand_type,1,1))+LOWER(SUBSTRING(item_brand_type,2,( SELECT LEN(item_brand_type))))  as item_brand_type
           ,UPPER(SUBSTRING(item_brand_name,1,1))+LOWER(SUBSTRING(item_brand_name,2,( SELECT LEN(item_brand_name))))  as item_brand_name
           ,datename(weekday, place_time) as wd_name
           ,item_quantity,item_brand_name_cn,item_sku_cd,is_placed_flag,item_apportion_amount,place_time
       from DW_OMS.V_Sales_Order_VB_Level where is_placed_flag=1 and item_apportion_amount>0
       )t1
left outer join DA_Tagging.sales_member_id t2 on t1.member_id=t2.member_id
left outer join DA_Tagging.channel_store t3 on t1.store_cd = t3.store_cd and t1.channel_cd=t3.channel_cd
left outer join (
      select distinct sku_code,kol_theme 
      from DA_Tagging.sephoraproductlist
      where kol_theme is not null and kol_theme<>'' and kol_theme<>'null'
) t4 on t1.item_sku_cd=t4.sku_code

------------------------------------------------------------------------------------------------
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, order sku temp Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

TRUNCATE TABLE DA_Tagging.sales_order_sku_temp
-- go
insert into DA_Tagging.sales_order_sku_temp
select sales_order_number
   ,case when t2.member_id is not null then t2.member_card else t1.member_id end as sales_member_id
   ,t3.store,t3.channel,item_sku_cd,item_apportion_amount,item_quantity,place_time,item_segment,item_range
   ,case when t4.skincare_function_basic is not null then t4.skincare_function_basic else t4.makeup_function end as item_function
from(
   select sales_order_number,member_id
   ,UPPER(SUBSTRING(item_range,1,1))+LOWER(SUBSTRING(item_range,2,( SELECT LEN(item_range))))  as item_range
   ,UPPER(SUBSTRING(item_segment,1,1))+LOWER(SUBSTRING(item_segment,2,( SELECT LEN(item_segment))))  as item_segment
   ,store_cd,channel_cd,item_quantity,item_sku_cd,item_apportion_amount,place_time
   from DW_OMS.V_Sales_Order_SKU_Level
   where is_placed_flag=1 and item_apportion_amount>0 
   ) t1
left outer join DA_Tagging.sales_member_id t2 on t1.member_id=t2.member_id
left outer join DA_Tagging.channel_store t3 on t1.store_cd = t3.store_cd and t1.channel_cd=t3.channel_cd
left outer join
(
   select sku_code,skincare_function_basic,makeup_function
   from DA_Tagging.sephoraproductlist 
)t4 on t1.item_sku_cd=t4.sku_code


--select top 100 * from DA_Tagging.sales_order_sku_temp
----------------------------------------------------------------------------------------------------
-- prioity result table
--master_id bigint,
--sales_member_id nvarchar(255),
--skincare_recency int,
--makeup_recency int,
--fragrance_recency int,
--skincare_item int,
--makeup_item int,
--fragrance_item int,
--skincare_sales float,
--makeup_sales float,
--fragrance_sales float,
--selective_sales float,
--exclusive_sales float,
--sephora_sales float,
--lancome_sales float,
--lauder_sales float,
--guerlain_sales float,
--skll_sales float,
--shiseido_sales float,
--dragon_sales float,
--tmall_sales float,
--jd_sales float,
--dragon_app_sales float,
--dragon_mnp_sales float,
--tmall_sephora_fs_sales float,
--tmall_wei_fs_sales float,
--purchase_recency int,
--purchase_frequency int,
--purchase_monetary int,
--dragon_sales_ranking nvarchar(255),
--tmall_sales_ranking nvarchar(255),
--jd_sales_ranking nvarchar(255),
--recency_ranking nvarchar(255),
--frequency_ranking nvarchar(255),
--purchase_ranking nvarchar(255),
--first_purchase_platform nvarchar(255),
--first_purchase_channel nvarchar(255),
--last_purchase_platform nvarchar(255),
--last_purchase_channel nvarchar(255),
--repeat_brand_sales nvarchar(255),
--repeat_brand_orders nvarchar(255),
--repeat_brand_qty nvarchar(255),
--preferred_brand nvarchar(255),
--preferred_brand_type nvarchar(255),
--preference_hour nvarchar(255),
--preference_weekday nvarchar(255),
--preferred_function nvarchar(255),
--preferred_range nvarchar(255),
--preferred_segment nvarchar(255),
--preference_store nvarchar(255),
--preference_channel nvarchar(255),
--kol_theme_purchase nvarchar(255)
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, creat result table Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

TRUNCATE TABLE DA_Tagging.online_purchase2
-- go
insert into DA_Tagging.online_purchase2(master_id,sales_member_id)
select distinct master_id,sales_member_id from DA_Tagging.sales_id_mapping
where master_id is not null

---------------------------------------------------------------------------------
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update category sales&item start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

update DA_Tagging.online_purchase2
set skincare_item = tt2.skincare_item
	,makeup_item = tt2.makeup_item
	,fragrance_item = tt2.fragrance_item
	,skincare_sales = tt2.skincare_sales
	,makeup_sales = tt2.makeup_sales
	,fragrance_sales = tt2.fragrance_sales
from DA_Tagging.online_purchase2 tt1
join(
	select sales_member_id  
	,max(case when item_category= 'Skincare' then item_cnt else 0 end) as skincare_item
	,max(case when item_category= 'Makeup' then item_cnt else 0 end) as makeup_item
	,max(case when item_category= 'Fragrance' then item_cnt else 0 end) as fragrance_item
	,max(case when item_category= 'Skincare' then item_sales else 0 end) as skincare_sales
	,max(case when item_category= 'Makeup' then item_sales else 0 end) as makeup_sales
	,max(case when item_category= 'Fragrance' then item_sales else 0 end) as fragrance_sales
	from(
		select sales_member_id,item_category
		,sum(item_quantity) as item_cnt
		,sum(item_apportion_amount) as item_sales
			from DA_Tagging.sales_order_vb_temp
			where item_category is not null
			group by sales_member_id,item_category
		)t1 
		group by sales_member_id
)tt2 
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS 	
on tt1.sales_member_id=tt2.sales_member_id 
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update category recency start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

update DA_Tagging.online_purchase2
set skincare_recency = tt2.skincare_recency
	,makeup_recency = tt2.makeup_recency
	,fragrance_recency = tt2.fragrance_recency
from DA_Tagging.online_purchase2 tt1
join(
	select sales_member_id     
	,max(case when item_category= 'Skincare' then recency else null end) as skincare_recency
	,max(case when item_category= 'Makeup' then recency else null end) as makeup_recency
	,max(case when item_category= 'Fragrance' then recency else null end) as fragrance_recency
	from(
	    select sales_member_id,item_category
	    ,datediff(day,convert(date,place_time),convert(date,DATEADD(hour,8,getdate())))  as recency
	    from(
	        select sales_member_id,item_category,place_time
	        ,row_number() over(partition by sales_member_id,item_category order by place_time desc) as rn
	        from DW_Sephora.DA_Tagging.sales_order_vb_temp
	     	)t1 where rn=1
		)t2 group by sales_member_id
)tt2 
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS 
on tt1.sales_member_id=tt2.sales_member_id 
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update brand_type sales start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

update DA_Tagging.online_purchase2
set selective_sales = tt2.selective_sales
	,exclusive_sales = tt2.exclusive_sales
	,sephora_sales = tt2.sephora_sales
from DA_Tagging.online_purchase2 tt1
join(
	select sales_member_id
	,max(case when item_brand_type = 'Selective' then item_sales else 0 end) as selective_sales
	,max(case when item_brand_type = 'Exclusive' then item_sales else 0 end) as exclusive_sales
	,max(case when item_brand_type = 'Sephora' then item_sales else 0 end) as sephora_sales
	from(
		select sales_member_id,item_brand_type
		,sum(item_apportion_amount) as item_sales
		from DA_Tagging.sales_order_vb_temp
		where item_brand_type is not null
		group by sales_member_id,item_brand_type
	)t1 group by sales_member_id
)tt2 
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS 	
on tt1.sales_member_id=tt2.sales_member_id 
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update brand sales start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

update DA_Tagging.online_purchase2
set lancome_sales = tt2.lancome_sales
    ,lauder_sales = tt2.lauder_sales
    ,guerlain_sales = tt2.guerlain_sales
    ,skll_sales = tt2.skll_sales
    ,shiseido_sales = tt2.shiseido_sales
from DA_Tagging.online_purchase2 tt1
join(
    select sales_member_id 
    ,max(case when item_brand_name = 'Lancome' then sales else 0 end) as lancome_sales
    ,max(case when item_brand_name = 'Lauder' then sales else 0 end) as lauder_sales
    ,max(case when item_brand_name = 'Guerlain' then sales else 0 end) as guerlain_sales
    ,max(case when item_brand_name = 'Skii' then sales else 0 end) as skll_sales
    ,max(case when item_brand_name = 'Shiseido' then sales else 0 end) as shiseido_sales
    from (
        select sales_member_id,item_brand_name
              ,sum(item_apportion_amount) as sales
        from DA_Tagging.sales_order_vb_temp
        group by sales_member_id,item_brand_name 
    ) t1
    group by sales_member_id
)tt2
on tt1.sales_member_id=tt2.sales_member_id
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update platform sales & ab start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())


update DA_Tagging.online_purchase2
set dragon_sales = tt2.dragon_sales
	,tmall_sales = tt2.tmall_sales
	,jd_sales = tt2.jd_sales
	,dragon_sales_ab = tt2.dragon_sales_ab
	,tmall_sales_ab = tt2.tmall_sales_ab
	,jd_sales_ab = tt2.jd_sales_ab
from DA_Tagging.online_purchase2 tt1
join(	
	select sales_member_id
	,max(case when platform = N'丝芙兰官网' then platform_sales else 0 end) as dragon_sales
    ,max(case when platform = N'天猫' then platform_sales else 0 end) as tmall_sales
    ,max(case when platform = N'京东' then platform_sales else 0 end) as jd_sales
	,max(case when platform = N'丝芙兰官网' then platform_sales/platform_orders else 0 end) as dragon_sales_ab
    ,max(case when platform = N'天猫' then platform_sales/platform_orders else 0 end) as tmall_sales_ab
    ,max(case when platform = N'京东' then platform_sales/platform_orders else 0 end) as jd_sales_ab
		from(
			select sales_member_id,store as platform
			,sum(product_amount) as platform_sales
			,count(distinct sales_order_number) as platform_orders
		        from DA_Tagging.sales_order_basic_temp 
		        group by sales_member_id,store
	)t1 group by sales_member_id
)tt2
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
on tt1.sales_member_id=tt2.sales_member_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update channel sales start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

update DA_Tagging.online_purchase2
set dragon_app_sales = tt2.dragon_app_sales
	,dragon_mnp_sales = tt2.dragon_mnp_sales
	,tmall_sephora_fs_sales = tt2.tmall_sephora_fs_sales
	,tmall_wei_fs_sales = tt2.tmall_wei_fs_sales
from DA_Tagging.online_purchase2 tt1
join(	
	select sales_member_id
	,max(case when channel = N'APP' then channel_sales else 0 end) as dragon_app_sales
    ,max(case when channel = N'小程序' then channel_sales else 0 end) as dragon_mnp_sales
    ,max(case when channel = N'丝芙兰天猫店' then channel_sales else 0 end) as tmall_sephora_fs_sales
    ,max(case when channel = N'蔚蓝之美天猫店' then channel_sales else 0 end) as tmall_wei_fs_sales
		from(
			select sales_member_id,channel,sum(product_amount) as channel_sales
	        from DA_Tagging.sales_order_basic_temp 
	        group by sales_member_id,channel
	)t1 group by sales_member_id
)tt2
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
on tt1.sales_member_id=tt2.sales_member_id 
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update recency&frequency&monetary start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

update DA_Tagging.online_purchase2
set purchase_recency = tt2.purchase_recency
	,purchase_frequency = tt2.purchase_frequency
	,purchase_monetary = tt2.purchase_monetary
from DA_Tagging.online_purchase2 tt1
join(
	select sales_member_id
	,max(recency) as purchase_recency, max(frequency) as purchase_frequency, max(monetary) as purchase_monetary		
    from(
			select sales_member_id
	        ,datediff(day,max(convert(date,place_time)),convert(date,DATEADD(hour,8,getdate()))) as recency
	        ,count(distinct sales_order_number) as frequency
	        ,sum(product_amount) as monetary
	        from DA_Tagging.sales_order_basic_temp 
	        group by sales_member_id
	)t1 group by sales_member_id
)tt2
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
on tt1.sales_member_id=tt2.sales_member_id
-- go

--------------------------------------------------------------------------------------------------
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update ranking start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

if not object_id(N'Tempdb..#T') is null
 drop table #T
-- go
create table #T(id int,ColumnName nvarchar(255),RankColumn nvarchar(255))
insert #T
select 1,'dragon_sales','dragon_sales_ranking' union all
select 2,'jd_sales','jd_sales_ranking' union all
select 3,'tmall_sales','tmall_sales_ranking' union all
select 4,'purchase_recency','recency_ranking' union all
select 5,'purchase_frequency','frequency_ranking' union all
select 6,'purchase_monetary','purchase_ranking' 
-- go

declare @s int=1
while @s<=6
begin

declare @ColumnName NVARCHAR(250) = (select ColumnName from #T where id = convert(int,@s))
declare @RankColumn NVARCHAR(250) = (select RankColumn from #T where ColumnName=@ColumnName)
declare @sql nvarchar(max)

set @sql ='
     UPDATE DA_Tagging.online_purchase2 
     set '+@RankColumn+'=tt2.sales_ranking
     from DA_Tagging.online_purchase2 tt1
     join (
          select sales_member_id
            ,case when sales_rk> 0 and sales_rk<=0.20 then ''(0,20%]''
            when sales_rk> 0.20 and sales_rk<=0.40 then ''(20%,40%]''
            when sales_rk> 0.40 and sales_rk<=0.60 then ''(40%,60%]''
            when sales_rk> 0.60 and sales_rk<=0.80 then ''(60%,80%]''
            when sales_rk> 0.80 and sales_rk<=1.00 then ''(80%,100%]''
            else null end as sales_ranking
          from (
               select sales_member_id,convert(float,(row_number() over (order by '+@ColumnName+' desc))/user_cnt)  as sales_rk
               from(
                   select sales_member_id, '+@ColumnName+'
                   from DA_Tagging.online_purchase2
                   where '+@ColumnName+'>0
                    )t1
                  cross join (
                  select convert(float,count(distinct sales_member_id)) as user_cnt
                        from DA_Tagging.online_purchase2
                        where '+@ColumnName+' > 0 
                    )t2
            )tt
     )tt2
     on tt1.sales_member_id=tt2.sales_member_id 
    '
exec ( @sql)
set @s=@s+1
end

--------------------------------------------------------------------------------------------------
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update first purchase platform start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

-- go
IF OBJECT_ID('tempdb..#first_purchas_temp') IS NOT NULL 
 DROP TABLE #first_purchas_temp; 
--  create table #first_purchas_temp(
--     sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--     store nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--     channel nvarchar(255) collate Chinese_PRC_CS_AI_WS
--  )
  create table #first_purchas_temp(
    sales_member_id nvarchar(255),
    store nvarchar(255),
    channel nvarchar(255)
 )
-- go
insert into #first_purchas_temp
select sales_member_id ,store,channel
    from(
        select sales_member_id,store,channel
        ,row_number() over (partition by sales_member_id order by place_time) as rn
        from DA_Tagging.sales_order_basic_temp
    ) as t1
    where rn = 1
-- go

update DA_Tagging.online_purchase2
set first_purchase_platform = tt2.store
	,first_purchase_channel = tt2.channel
from DA_Tagging.online_purchase2 tt1
join #first_purchas_temp tt2 
-- on tt1.sales_member_id = tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
on tt1.sales_member_id = tt2.sales_member_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update last purchase platform start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

-- go
IF OBJECT_ID('tempdb..#last_purchase_temp') IS NOT NULL 
 DROP TABLE #last_purchase_temp; 
--  create table #last_purchase_temp(
--     sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--     store nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--     channel nvarchar(255) collate Chinese_PRC_CS_AI_WS
--  )
  create table #last_purchase_temp(
    sales_member_id nvarchar(255),
    store nvarchar(255),
    channel nvarchar(255)
 )
-- go
insert into #last_purchase_temp
select sales_member_id,store,channel
    from(
        select sales_member_id,store,channel
        ,row_number() over (partition by sales_member_id order by place_time desc) as rn
        from DA_Tagging.sales_order_basic_temp
    ) as t1
where rn = 1
-- go

update DA_Tagging.online_purchase2
set last_purchase_platform=tt2.store
	,last_purchase_channel=tt2.channel
from DA_Tagging.online_purchase2 tt1
-- join #last_purchase_temp tt2 on tt1.sales_member_id = tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
join #last_purchase_temp tt2 on tt1.sales_member_id = tt2.sales_member_id


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update if repeat brand temp6_0 start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

-- go
IF OBJECT_ID('tempdb..#tagging_system_online_purchase_temp6_0') IS NOT NULL 
 DROP TABLE #tagging_system_online_purchase_temp6_0; 

--  create table #tagging_system_online_purchase_temp6_0(
--     sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--     brand_type nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--     brand nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--     first_order_time nvarchar(255) collate Chinese_PRC_CS_AI_WS
--  )

 create table #tagging_system_online_purchase_temp6_0(
    sales_member_id nvarchar(255) ,
    brand_type nvarchar(255) ,
    brand nvarchar(255) ,
    first_order_time nvarchar(255)
 )
-- go
insert into #tagging_system_online_purchase_temp6_0
select sales_member_id,item_brand_type as brand_type
,item_brand_name as brand,min(place_time)as first_order_time
from DA_Tagging.sales_order_vb_temp
group by sales_member_id,item_brand_type,item_brand_name
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update if repeat brand temp6_1 start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

-- go
--IF OBJECT_ID('tempdb..#tagging_system_online_purchase_temp6_1') IS NOT NULL 
--DROP TABLE #tagging_system_online_purchase_temp6_1; 
--create table #tagging_system_online_purchase_temp6_1(
--    sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--    brand_type nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--    brand nvarchar(255) collate Chinese_PRC_CS_AI_WS,
--    if_repeat int,
--    orders int,
--    sales float,
--    qty int
--)
--20210701修改
truncate table DA_Tagging.online_purchase_temp6_1
-- go
insert into DA_Tagging.online_purchase_temp6_1
select sales_member_id,brand_type,brand,if_repeat
    ,count(distinct sales_order_number) as orders
    ,sum(item_apportion_amount) as sales
    ,sum(item_quantity) as qty
from(
    select t1.sales_member_id,t1.sales_order_number,t1.brand_type
    ,t1.brand,t1.item_apportion_amount,t1.item_quantity
    ,case when t1.place_time=t2.first_order_time then 0 else 1 end as if_repeat
    from
    (
        select sales_member_id,sales_order_number
        ,item_brand_type as brand_type,item_brand_name as brand
        ,item_apportion_amount,item_quantity,place_time
        from DA_Tagging.sales_order_vb_temp
    )t1
    left outer join
    (
        select sales_member_id,brand_type,brand,first_order_time
        from #tagging_system_online_purchase_temp6_0) t2
    on t1.sales_member_id=t2.sales_member_id 
    and t1.brand_type=t2.brand_type
    and t1.brand=t2.brand
    )tt1
group by sales_member_id,brand_type,brand,if_repeat
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update if repeat brand update start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

--;with repeat_brand_sales_temp as (
    select sales_member_id,brand as repeat_brand_sales
	into #repeat_brand_sales_temp
    from(
        select sales_member_id,brand,row_number() over(partition by sales_member_id order by sales desc) as rn
        from DA_Tagging.online_purchase_temp6_1
        where if_repeat=1
        )t1
    where rn=1
--)

update DA_Tagging.online_purchase2
set repeat_brand_sales = tt2.repeat_brand_sales
from DA_Tagging.online_purchase2 as tt1
--join repeat_brand_sales_temp as tt2
join #repeat_brand_sales_temp as tt2
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
on tt1.sales_member_id=tt2.sales_member_id

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update repeat sales brand end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with repeat_brand_orders_temp as (
    select sales_member_id,brand as repeat_brand_orders
    from(
        select sales_member_id,brand,row_number() over(partition by sales_member_id order by orders desc) as rn
        from DA_Tagging.online_purchase_temp6_1
        where if_repeat=1
		)t1
    where rn=1
)

update DA_Tagging.online_purchase2
set repeat_brand_orders = tt2.repeat_brand_orders
from DA_Tagging.online_purchase2 as tt1
join repeat_brand_orders_temp as tt2
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
on tt1.sales_member_id=tt2.sales_member_id 

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update repeat order brand end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with repeat_brand_qty_temp as (
    select sales_member_id,brand as repeat_brand_qty
    from(
        select sales_member_id,brand,row_number() over(partition by sales_member_id order by qty desc) as rn
        from DA_Tagging.online_purchase_temp6_1
        where if_repeat=1
		)t1 
	where rn=1
)

update DA_Tagging.online_purchase2
set repeat_brand_qty = tt2.repeat_brand_qty
from DA_Tagging.online_purchase2 as tt1
join repeat_brand_qty_temp as tt2
-- on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
on tt1.sales_member_id=tt2.sales_member_id

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update repeat qty brand end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
;with temp1 as (
	select sales_member_id,item_brand_name
	from(
		select sales_member_id,item_brand_name
		,row_number() over(partition by sales_member_id order by sales desc) as rn
		from( select sales_member_id,item_brand_name,sum(item_apportion_amount) as sales
			from DA_Tagging.sales_order_vb_temp
			group by sales_member_id,item_brand_name
			)t0 
			)t1 where rn=1
)
,temp2 as (
	select sales_member_id,item_brand_type
	from(
		select sales_member_id,item_brand_type
		,row_number() over(partition by sales_member_id order by sales desc) as rn
		from
		( select sales_member_id,item_brand_type,sum(item_apportion_amount) as sales
			from DA_Tagging.sales_order_vb_temp
			group by sales_member_id,item_brand_type
			)t0 
			)t1 where rn=1
)

update DA_Tagging.online_purchase2 --1222539条数据 2min
set preferred_brand = t2.item_brand_name
	,preferred_brand_type = t3.item_brand_type
from DA_Tagging.online_purchase2 as t1
-- join temp1 t2 on t1.sales_member_id=t2.sales_member_id collate Chinese_PRC_CS_AI_WS
-- join temp2 t3 on t1.sales_member_id=t3.sales_member_id collate Chinese_PRC_CS_AI_WS
join temp1 t2 on t1.sales_member_id=t2.sales_member_id
join temp2 t3 on t1.sales_member_id=t3.sales_member_id

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update preferred brand type end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with functionTemp as (
	select sales_member_id,item_function
	from(
	    select sales_member_id,item_function
	    ,row_number() over(partition by sales_member_id order by sales desc) as rn
	    from 
	    ( select sales_member_id,item_function,sum(item_apportion_amount) as sales
	        from DA_Tagging.sales_order_sku_temp
	        group by sales_member_id,item_function
			)t0
	    )t1 where rn=1
)
,rangeTemp as (
	select sales_member_id,item_range
    from(
        select sales_member_id,item_range
        ,row_number() over(partition by sales_member_id order by sales desc) as rn
        from 
        ( select sales_member_id,item_range,sum(item_apportion_amount) as sales
          from DA_Tagging.sales_order_sku_temp
          group by sales_member_id,item_range
		  )t0
	)t1  where rn=1
)
,segmentTemp as (
	 select sales_member_id,item_segment
    from(
        select sales_member_id,item_segment
        ,row_number() over(partition by sales_member_id order by sales desc) as rn
        from 
        ( select sales_member_id,item_segment,sum(item_apportion_amount) as sales
          from DA_Tagging.sales_order_sku_temp
          group by sales_member_id,item_segment
		  )t0
	)t1 where rn=1
)

update DA_Tagging.online_purchase2 --1222539条数据 2min
set preferred_function = t2.item_function
	,preferred_range = t3.item_range
	,preferred_segment = t4.item_segment
from DA_Tagging.online_purchase2 as t1
-- join functionTemp t2 on t1.sales_member_id=t2.sales_member_id collate Chinese_PRC_CS_AI_WS
-- join rangeTemp t3 on t1.sales_member_id=t3.sales_member_id collate Chinese_PRC_CS_AI_WS
-- join segmentTemp t4 on t1.sales_member_id=t4.sales_member_id collate Chinese_PRC_CS_AI_WS
join functionTemp t2 on t1.sales_member_id=t2.sales_member_id
join rangeTemp t3 on t1.sales_member_id=t3.sales_member_id
join segmentTemp t4 on t1.sales_member_id=t4.sales_member_id


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update preferred function end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with storeTemp as (
	 select sales_member_id,store
    from(
        select sales_member_id,store
        ,row_number() over(partition by sales_member_id order by sales desc) as rn
        from 
        ( select sales_member_id,store,sum(product_amount) as sales
			from DA_Tagging.sales_order_basic_temp
			group by sales_member_id,store
		  )t0
	)t1 where rn=1
)

,channelTemp as (
	 select sales_member_id,channel
    from(
        select sales_member_id,channel
        ,row_number() over(partition by sales_member_id order by sales desc) as rn
        from 
        ( select sales_member_id,channel,sum(product_amount) as sales
			from DA_Tagging.sales_order_basic_temp
			group by sales_member_id,channel
		  )t0
	)t1 where rn=1
)

update DA_Tagging.online_purchase2 --1222539条数据 1min
set preference_store = t2.store
	,preference_channel = t3.channel
from DA_Tagging.online_purchase2 as t1
-- join storeTemp t2 on t1.sales_member_id=t2.sales_member_id collate Chinese_PRC_CS_AI_WS
-- join channelTemp t3 on t1.sales_member_id=t3.sales_member_id collate Chinese_PRC_CS_AI_WS
join storeTemp t2 on t1.sales_member_id=t2.sales_member_id
join channelTemp t3 on t1.sales_member_id=t3.sales_member_id


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update preferred platform end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with kolTemp as (
    select sales_member_id,kol_theme
	from(
	    select sales_member_id,kol_theme
	    ,row_number() over (partition by sales_member_id order by kol_theme_purchase desc) as rn
	    from (
	        select sales_member_id,kol_theme,sum(item_apportion_amount) as kol_theme_purchase
	        from DA_Tagging.sales_order_vb_temp
	        group by sales_member_id,kol_theme
	        )t1
	    )tt where rn=1
)
update DA_Tagging.online_purchase2 
set kol_theme_purchase = t2.kol_theme  --1222539条 5.5min
from DA_Tagging.online_purchase2 as t1
-- join kolTemp t2 on t1.sales_member_id=t2.sales_member_id collate Chinese_PRC_CS_AI_WS
join kolTemp t2 on t1.sales_member_id=t2.sales_member_id

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update kol theme end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
;with hourTemp as (
	select sales_member_id,place_hour from(
		select sales_member_id,place_hour
		,row_number() over(partition by sales_member_id order by order_cn desc) as rn
		from(
			select sales_member_id,place_hour ,count(distinct sales_order_number) as order_cn
			from DA_Tagging.sales_order_vb_temp
			group by sales_member_id,place_hour
		)t0 
	)t1 where rn=1
)
,wkTemp as(
	select sales_member_id,wd_name from(
		select sales_member_id,wd_name
		,row_number() over(partition by sales_member_id order by order_cn desc) as rn
		from(
			select sales_member_id,wd_name ,count(distinct sales_order_number) as order_cn
			from DA_Tagging.sales_order_vb_temp
			group by sales_member_id,wd_name
		)t0 
	)t1 where rn=1
)

update DA_Tagging.online_purchase2 --1min
set preference_hour =  case t2.place_hour when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
						when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
						when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
						when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
						when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' end
	,preference_weekday = t3.wd_name
from DA_Tagging.online_purchase2 as t1
-- join hourTemp t2 on t1.sales_member_id=t2.sales_member_id collate Chinese_PRC_CS_AI_WS
-- join wkTemp t3 on t1.sales_member_id=t3.sales_member_id collate Chinese_PRC_CS_AI_WS
join hourTemp t2 on t1.sales_member_id=t2.sales_member_id collate Chinese_PRC_CS_AI_WS
join wkTemp t3 on t1.sales_member_id=t3.sales_member_id collate Chinese_PRC_CS_AI_WS

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_3','Tagging System Online Purchase Update, update preferred placetime end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

END

GO
