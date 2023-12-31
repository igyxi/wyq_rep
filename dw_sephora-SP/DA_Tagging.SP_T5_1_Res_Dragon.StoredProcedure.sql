/****** Object:  StoredProcedure [DA_Tagging].[SP_T5_1_Res_Dragon]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T5_1_Res_Dragon] AS
BEGIN


	-- first version --=======--=======--=======--=======--=======--=======--=======--=======--=======--=======--=======
	/*
	
	-- 拉取Tagging Id Mapping中最新的 master_id sephora_user_id 对应关系
	Truncate table [DA_Tagging].[tagging_res_dragon]
	insert into [DA_Tagging].[tagging_res_dragon]
		(sephora_user_id,master_id,update_date,invalid_date)
	select distinct sephora_user_id, master_id 
	, convert(date,getdate()) as update_date
	, '9999-12-31' as invalid_date
		from DA_Tagging.id_mapping
		where invalid_date = '9999-12-31' and sephora_user_id is not null



	-- 从1期online purchase结果表中拉取官网销售额和官网客单价
	update [DA_Tagging].[tagging_res_dragon]
	set dragon_sales = tt.dragon_sales
		,Dragon_Sales_AB = tt.Dragon_Sales_AB
	from [DA_Tagging].[tagging_res_dragon] t1
			join(
		select master_id, dragon_sales, Dragon_Sales_AB
			from DA_Tagging.online_purchase2
			where dragon_sales is not null or Dragon_Sales_AB is not null
	)tt on t1.master_id = tt.master_id



	-- 从1期engagement结果表中拉取最常浏览的大类和 最常浏览品牌
	update [DA_Tagging].[tagging_res_dragon]
	set most_visited_category = tt.most_visited_category,
		most_visited_brand = tt.most_visited_brand
	from [DA_Tagging].[tagging_res_dragon] t1
			join(
		select master_id, most_visited_category, most_visited_brand
			from DA_Tagging.engagement
			where most_visited_category is not null or most_visited_brand is not null
	)tt on t1.master_id = tt.master_id


	-- 删除初始化无用空值 即当前无购买/无浏览历史的用户
	delete from [DA_Tagging].[tagging_res_dragon]
	where most_visited_category is null
			and most_visited_brand is null
			and (Dragon_Sales_AB is null or Dragon_Sales_AB = 0)
			and (dragon_sales is null or dragon_sales = 0)

	*/
	
	
	insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
	select 'Dragon Tracking','Daily Tracking [dragon_sales], [dragon_sales_ab], [most_visited_category], [most_visited_brand] Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	;

	insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
	select 'Dragon Tracking','Generate Daily update buyer Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	;
	-- Update Version --=======--=======--=======--=======--=======--=======--=======--=======--=======--=======--=======
	-- 筛选前一天有销售的人
	if not object_id(N'Tempdb..#last_day_purchase_master') is null 
	drop table #last_day_purchase_master
	select distinct sales_member_id, t3.master_id, t3.sephora_user_id
	into #last_day_purchase_master
	from(
		select t1.sales_member_id, master_id
			from(
			select distinct sales_member_id
				from DA_Tagging.sales_order_basic_temp
				where store = N'丝芙兰官网' and place_date = convert(date,getdate() -1)
		)t1 inner join DA_Tagging.sales_id_mapping t2 on t1.sales_member_id=t2.sales_member_id
	)tt inner join DA_Tagging.id_mapping t3 on tt.master_id=t3.master_id
		where t3.sephora_user_id is not null

	insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
	select 'Dragon Tracking','Generate Daily update visitor Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	;

	-- 筛选前一天有浏览的人
	if not object_id(N'Tempdb..#last_day_visit_master') is null 
	drop table #last_day_visit_master
	select distinct master_id, t1.sephora_user_id, t0.user_id
	into #last_day_visit_master
	from(
		select user_id
			from DA_Tagging.v_events_session
			where dt = convert(date,getdate() - 1)
				and event = 'viewCommodityDetail'
				and isnumeric(op_code) = 1
				and op_code <> '0'
				and (brand is not null or category is not null)
				group by user_id
	)t0 inner join(
		select master_id, sensor_id, sephora_user_id
			from DA_Tagging.id_mapping
			where invalid_date='9999-12-31'
				and sensor_id is not null and sensor_id<>0
				and sephora_user_id is not null and sephora_user_id<>0
	)t1 on t0.user_id=t1.sensor_id
		where t1.sephora_user_id is not null

	insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
	select 'Dragon Tracking','Generate Daily update sephora user Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	;

	-- 信息可能会有更改的人的信息
	if not object_id(N'Tempdb..#last_day_master') is null 
	drop table #last_day_master
	select t0.master_id, t0.sephora_user_id
	, t1.dragon_sales, t1.dragon_sales_ab
	, t2.most_visited_category, t2.most_visited_brand
	into #last_day_master
		from(
				select master_id, sephora_user_id
				from #last_day_purchase_master group by master_id, sephora_user_id
			union 
				select master_id, sephora_user_id
				from #last_day_visit_master group by master_id, sephora_user_id
	)t0
			inner join DA_Tagging.online_purchase2 t1 on t0.master_id = t1.master_id
			inner join DA_Tagging.engagement t2 on t0.master_id = t2.master_id


	insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
	select 'Dragon Tracking','Generate Daily update [dragon_sales], [dragon_sales_ab], [most_visited_category], [most_visited_brand] Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	;

	-- 更新前一天有购买的人的官网销售额 和官网客单价
	insert into DA_Tagging.tagging_res_dragon(sephora_user_id ,master_id,dragon_sales,dragon_sales_ab
		, most_visited_category, most_visited_brand, update_date, invalid_date)
	select distinct sephora_user_id, master_id, dragon_sales, dragon_sales_ab, most_visited_category, most_visited_brand
	, convert(date,getdate()) as update_date
	, '9999-12-31' as invalid_date
		from(
		select t2.sephora_user_id , t2.master_id
		, t2.dragon_sales, t2.dragon_sales_ab
		, t2.most_visited_category, t2.most_visited_brand
			from DA_Tagging.tagging_res_dragon t1
				right join #last_day_master t2
				on t1.sephora_user_id = t2.sephora_user_id
			where t1.sephora_user_id is null
				or t1.dragon_sales <> t2.dragon_sales
				or t1.dragon_sales_ab <> t2.dragon_sales_ab
				or t1.most_visited_category <> t2.most_visited_category
				or t1.most_visited_brand <> t2.most_visited_brand
	)tt
	
	insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
	select 'Dragon Tracking','Generate Daily update invaild date Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	;

	-- 更新前一天的信息失效
	update DA_Tagging.tagging_res_dragon
	set invalid_date= convert(date,getdate())
	from DA_Tagging.tagging_res_dragon t
	join(
		select sephora_user_id , master_id, update_date,invalid_date,rn
		from(
			select sephora_user_id , master_id, update_date, invalid_date 
					, rank() over (partition by sephora_user_id , master_id order by  update_date desc) rn
					from DA_Tagging.tagging_res_dragon
		)t where rn<>1
	)tt on t.master_id = tt.master_id 
		and t.sephora_user_id = tt.sephora_user_id
		and t.update_date = tt.update_date
	
	;

	insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
	select 'Dragon Tracking','Daily Tracking [dragon_sales], [dragon_sales_ab], [most_visited_category], [most_visited_brand] End....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
	;


END
GO
