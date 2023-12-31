/****** Object:  StoredProcedure [DA_Tagging].[SP_T4_5_CRM2]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T4_5_CRM2] AS
BEGIN

/* ############ ############ ############ Crm Memebership Tag ############ ############ ############ */

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Tab',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

TRUNCATE TABLE DA_Tagging.crm_membership2
insert into DA_Tagging.crm_membership2(master_id,crm_account_id,crm_account_no)
select master_id, crm_account_id, sephora_card_no as crm_account_no 
from DA_Tagging.id_mapping
where invalid_date='9999-12-31'
and (crm_account_id is not null or sephora_card_no is not null)
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Private Sale Preference',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

-- 全渠道最常消费的大促：Private Sale Preference
update DA_Tagging.crm_membership2
set private_sale_preference = tt2.private_sale_preference
from DA_Tagging.crm_membership2 tt1
join(
        select account_id,Campaign_Name as private_sale_preference
        from(
            select account_id,Campaign_Name
                ,row_number() over(partition by account_id order by trans_cnt desc) as rn
            from(
                select account_id,t2.Campaign_Name,count(distinct trans_id) as trans_cnt
                from(
                    select account_id,trans_id,sap_time
                    from ODS_CRM.FactTrans
                    where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='1'
                    )t1  inner join (select Campaign_Date,Campaign_Name from DA_Tagging.coding_campaign_name 
						where Campaign_Type = 'Private Sales'  )t2 on convert(date, t1.sap_time) = t2.Campaign_Date
                group by account_id,Campaign_Name
            )tt
        )ttt where rn=1
)tt2 on tt1.crm_account_id=tt2.account_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Holidays Preference',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
--全渠道最常消费的节假日：Holidays_Festivals
update DA_Tagging.crm_membership2
set holiday_preference = tt2.holidays_festivals
from DA_Tagging.crm_membership2 tt1
join(
    select account_id,holidays_festivals
    from(
        select account_id,holidays_festivals
            ,row_number() over(partition by account_id order by trans_cnt desc) as rn
        from(
            select account_id,holidays_festivals,count(distinct trans_id) as trans_cnt
            from(
                select account_id,trans_id,sap_time from ODS_CRM.FactTrans 
                where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='1' 
                -- and DateDiff(dd,convert(date,sap_time),getdate())<90
                )t1 join(
                    select daytype,date,holidays_festivals from DA_Tagging.coding_daytype 
                    where daytype = 'Holidays and Festivals'
                    )t2 on convert(date,t1.sap_time) = t2.date
            group by account_id,holidays_festivals
            )tt1
    )tt2 where rn=1
)tt2 on tt1.crm_account_id=tt2.account_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Season Preference',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 全渠道最常消费的季节：Season Preference
select account_id,trans_month
into #SeasonPreference
from(
    select account_id,trans_month
    ,row_number() over(partition by account_id order by trans_cnt desc) as rn
    from(
        select account_id,month(sap_time) as trans_month,count(distinct trans_id) as trans_cnt
        from ODS_CRM.FactTrans
        where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='1'  
        --and DateDiff(dd,convert(date,sap_time),getdate())<90
        group by account_id,month(sap_time)
    )tt
)t2 where rn=1
;

update DA_Tagging.crm_membership2
set season_preference = tt2.season_preference 
from DA_Tagging.crm_membership2 tt1
join(
    select account_id
    ,case when trans_month in (3,4,5) then 'Spring' 
            when trans_month in (6,7,8) then 'Summer'
            when trans_month in (9,10,11) then 'Autumn'
            when trans_month in (12,1,2) then 'Winter' end as season_preference
    from  #SeasonPreference
)tt2 on tt1.crm_account_id=tt2.account_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Price Sensitivity',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())                   
;
-- 全渠道价格敏感度：Price Sensitivity 
update DA_Tagging.crm_membership2
set price_sensitivity = tt2.price_sensitivity  
from DA_Tagging.crm_membership2 tt1
join(
    select t1.account_id
    ,case when price_sensitivity>percentile_7 then N'高'
    when price_sensitivity>percentile_3 and price_sensitivity<=percentile_7 then N'中'
    when price_sensitivity<=percentile_3 then N'低' else null end as price_sensitivity
    from(
        select account_id,round(count(if_discount_order)/cast(count(distinct trans_id) as float), 2) as price_sensitivity
        from(
            select account_id,trans_id
                ,case when sum(if_discount)>0 then trans_id else null end as if_discount_order
            from(
                select t1.account_id,t1.trans_id
                    ,case when sales/qtys < price then 1 else 0 end as if_discount
                from (
                    select account_id,trans_id,sales,qtys,product_id
                    from ODS_CRM.FactTrans
                    where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='1')t1 
                left join ODS_CRM.DimProduct t2 on t1.product_id =t2.product_id
            )t
            group by account_id,trans_id
        )tt 
        group by account_id
    )t1
    cross join(
        select min(per) as percentile_3,max(per) as percentile_7
        from(
            select max(price_sensitivity) as per
            from(
                select NTILE(10) over(order by price_sensitivity) as percentile,price_sensitivity
                from(
                    select account_id,round(count(if_discount_order)/cast(count(distinct trans_id) as float), 2) as price_sensitivity
                    from(
                        select account_id,trans_id
                            ,case when sum(if_discount)>0 then trans_id else null end as if_discount_order
                        from(
                            select t1.account_id,t1.trans_id
                            ,case when sales/qtys < price then 1 else 0 end as if_discount
                            from (
                                select account_id,trans_id,sales,qtys,product_id
                                from ODS_CRM.FactTrans
                                where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='1'
                                )t1 
                            left join ODS_CRM.DimProduct t2 on t1.product_id =t2.product_id
                        )t1
                        group by account_id,trans_id
                    )t2
                    group by account_id
                )t3
            )t4
            where percentile <= 7 and percentile>=3
         group by percentile
        )t5
    )t6
)tt2 on tt1.crm_account_id=tt2.account_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership [private_sale_sensitivity]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())                   
--全渠道大促敏感度
--[只在大促][只在非大促][大促非大促均购买偏好大促][大促非大促均购买偏好非大促]
select distinct account_id,trans_id
,case when datediff(ss,promotion_start_time,sap_time)/3600 <= promotion_hours 
and datediff(ss,promotion_start_time,sap_time)/3600 >=0 then N'大促时购买' else N'非大促时购买' end as promotion_behavior
into #promotion_behavior_temp
from (
    select account_id,trans_id,sap_time,year(sap_time) as order_year,month(sap_time) as order_month
    from ODS_CRM.FactTrans
    where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='1'
	)t1
left outer join(
    select promotion_start_time,promotion_hours,year(promotion_start_time) as promotion_year,month(promotion_start_time) as promotion_month
    from DA_Tagging.promotion_time
	)t2 on t1.order_year=t2.promotion_year and t1.order_month=t2.promotion_month


update DA_Tagging.crm_membership2
set private_sale_sensitivity = tt2.private_sale_sensitivity 
from DA_Tagging.crm_membership2 tt1
join(
    select account_id
    ,case when dacu=N'大促时购买' and no_dacu= N'非大促时购买' then N'大促及非大促都购买' 
          when dacu=N'大促时购买' and no_dacu is null then N'只在大促购买' else N'只在非大促购买' end as private_sale_sensitivity
    from(
        select account_id
            ,max(case promotion_behavior when N'大促时购买' then N'大促时购买' else null end) as dacu
            ,max(case promotion_behavior when N'非大促时购买' then N'非大促时购买' else null end) as no_dacu
        from #promotion_behavior_temp t
        group by account_id
    )tt
)tt2 on tt1.crm_account_id=tt2.account_id
;

update DA_Tagging.crm_membership2
set private_sale_sensitivity = tt2.private_sale_sensitivity
from DA_Tagging.crm_membership2 tt1
join(
    select account_id
    ,case when no_dacu_cnt <= dacu_cnt then N'大促非大促均购买偏好大促' else  N'大促非大促均购买偏好非大促' end as private_sale_sensitivity
    from(
        select t1.account_id
        ,max(case when promotion_behavior=N'非大促时购买' then order_cnt end) as no_dacu_cnt
        ,max(case when promotion_behavior=N'大促时购买' then order_cnt end) as dacu_cnt
        from(
            select account_id, promotion_behavior, count(distinct trans_id) as order_cnt 
            from #promotion_behavior_temp 
            group by account_id, promotion_behavior
        )t1
        inner join (
            select distinct crm_account_id, private_sale_sensitivity
            from DA_Tagging.crm_membership2
            where private_sale_sensitivity=N'大促及非大促都购买'
        )t2 on t1.account_id = t2.crm_account_id
        group by t1.account_id
    )tt1 
)tt2 on tt1.crm_account_id=tt2.account_id
where tt1.private_sale_sensitivity=N'大促及非大促都购买'
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership avg purchase times offline2online',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
update DA_Tagging.crm_membership2
set avg_purchase_times_offline2online = tt2.avg_pur_times_offline2online
     ,avg_purchase_interval_offline2online = tt2.avg_pur_interval_offline2online
from DA_Tagging.crm_membership2 tt1
join(
    select account_id,avg(offline_trans_cnt) as avg_pur_times_offline2online
        ,avg(offline_online_interval) as avg_pur_interval_offline2online
    from(
        select account_id,trans_rn as offline_trans_cnt
        ,datediff(dd,trans_date,next_trans_date) as offline_online_interval
        from(
            select account_id,trans_id,trans_date
            ,row_number() over(partition by account_id order by trans_date) as trans_rn
            ,is_eb_store
            ,lead(is_eb_store,1) over(partition by account_id order by trans_date) as next_is_eb_store
            ,lead(trans_date,1) over(partition by account_id order by trans_date) as next_trans_date
            from(
                select account_id,trans_id,convert(date,sap_time) as trans_date,store_id
                from [ODS_CRM].[factTrans]
                where convert(date, sap_time) between convert(date,getdate()-360) and convert(date,getdate()-1) 
				and account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='true'
                )t1 
            left outer join [ODS_CRM].[DimStore] t2 on t1.store_id=t2.store_id
        )tt1
        where is_eb_store=1 and next_is_eb_store=2
        )t
    group by account_id
)tt2 on tt1.crm_account_id=tt2.account_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Preferred Range',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
--偏好的产品作用部位（销售额）
select account_id,Range as preferred_range
into #preferred_range
from(
    select account_id,Range,row_number() over(partition by account_id order by sales desc) as rn
    from(
        select account_id,Range,sum(sales) as sales
        from(
            select account_id,product_id,sales
            from ODS_CRM.FactTrans
            where valid_flag='1' and sales>0 
            and convert(date, sap_time) between convert(date,getdate() - 360) and convert(date,getdate() - 1) 
        )t1 
        left outer join(
            select product_id,Range,Segment,brand_type
            from [ODS_CRM].[DimProduct]
        )t2 on t1.product_id=t2.product_id
        group by account_id,Range)t1 
)t1 where rn=1
;

update DA_Tagging.crm_membership2
set preferred_range = tt2.preferred_range
from DA_Tagging.crm_membership2 tt1
join #preferred_range tt2 on tt1.crm_account_id=tt2.account_id
;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Preferred Segment',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
;
--偏好的产品细分类别（销售额）
select account_id,Segment as preferred_segment
into #preferred_segment
    from(
        select account_id,Segment,row_number() over(partition by account_id order by sales desc) as rn
        from(
            select account_id,Segment,sum(sales) as sales
            from(
                select account_id,product_id,sales
                from ODS_CRM.FactTrans
                where valid_flag='1' and sales>0 
                    and convert(date, sap_time) between convert(date,getdate() - 360) and convert(date,getdate() - 1) 
            )t1 
            left outer join(
                select product_id,Range,Segment,brand_type
                from [ODS_CRM].[DimProduct]
            )t2 on t1.product_id=t2.product_id
            group by account_id,Segment)t1 
    )t1 
    where rn=1


update DA_Tagging.crm_membership2
set preferred_segment = tt2.preferred_segment
from DA_Tagging.crm_membership2 tt1
join #preferred_segment tt2 on tt1.crm_account_id=tt2.account_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Preferred Brand Type',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
;
----偏好的产品品牌类型（销售额）
select account_id,brand_type as preferred_brand_type
into #preferred_brand_type
    from(
        select account_id,brand_type,row_number() over(partition by account_id order by sales desc) as rn
        from(
            select account_id,brand_type,sum(sales) as sales
            from(
                select account_id,product_id,sales
                from ODS_CRM.FactTrans
                where valid_flag='1' and sales>0 
                and convert(date, sap_time) between convert(date,getdate() - 360) and convert(date,getdate() - 1) 
            )t1 
            left outer join(
                select product_id,Range,Segment,brand_type
                from [ODS_CRM].[DimProduct]
            )t2 on t1.product_id=t2.product_id
            group by account_id,brand_type)t1 
    )t1 where rn=1
;

update DA_Tagging.crm_membership2
set preferred_brand_type = tt2.preferred_brand_type
from DA_Tagging.crm_membership2 tt1
join #preferred_brand_type tt2 on tt1.crm_account_id=tt2.account_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership [next_brand_to_buy]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
;
with temp1 as (
    select trans_id,brand_id as brand
    from(
            select brand_id,trans_id from ODS_CRM.FactTrans where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='true'
            and convert(date, sap_time) between convert(date,getdate() - 91) and convert(date,getdate() - 1)
            )t1 
)
,temp2 as (
    select t1.trans_id as bask_id,brand from temp1 t1
    left outer join (
            select trans_id from temp1 group by trans_id having count(distinct brand)>1 )t2 on t1.trans_id=t2.trans_id
    where t2.trans_id is not null 
)
                                
,temp3 as (
    select brand, count(distinct bask_id) as bask_cnt from temp2 group by brand
)
                                
,temp4 as (
    select t1.brand as brand_1,t2.brand as brand_2,count(distinct t1.bask_id) as bask_cnt
    from temp2 t1 left outer join temp2 t2 on t1.bask_id=t2.bask_id where t1.brand<>t2.brand 
    group by t1.brand,t2.brand
)
                                
,temp5 as (
    select brand_1,brand_2
    from(
        select brand_1,brand_2
        ,row_number() over(partition by brand_1 order by lift desc) lift_rn
        from(
            select t1.brand_1,t1.brand_2,t1.bask_cnt as pair_baskcnt,t2.bask_cnt as brand_1_baskcnt,t3.bask_cnt as brand_2_baskcnt,t4.bask_cnt as total_cnt
            ,ROUND(CAST(t1.bask_cnt AS float)/t4.bask_cnt, 4) as support ,ROUND(CAST(t1.bask_cnt AS float)/t2.bask_cnt, 4) as confidence
            ,ROUND(CAST(t1.bask_cnt AS float)/t2.bask_cnt/t3.bask_cnt*t4.bask_cnt, 4) as lift
            from temp4 t1
            left outer join temp3 t2 on t1.brand_1=t2.brand
            left outer join temp3 t3 on t1.brand_2=t3.brand
            cross join (
                select count(distinct bask_id) as bask_cnt from temp2
                )t4
            )tt
        )tt where lift_rn=1
)
                                
update DA_Tagging.crm_membership2
set next_brand_to_buy = tttt.nextToBuyBrand
from DA_Tagging.crm_membership2 tt1
join(
    select account_id, tt2.brand as  nextToBuyBrand
    from(
        select account_id,t2.brand_2 as nextToBuyBrand
        from(
            select account_id,brand_id
            from ODS_CRM.FactTrans where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='true'
            and convert(date, sap_time) between convert(date,getdate() - 91) and convert(date,getdate() - 1)
            )t1
            left join temp5 t2 on t1.brand_id =t2.brand_1
        )tt1 left join ( select distinct brand_id, brand from ODS_CRM.DimProduct
    )tt2 on tt1.nextToBuyBrand=tt2.brand_id   
)tttt on tt1.crm_account_id=tttt.account_id   
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership [next_segment_to_buy]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
;

with temp1 as (
	select trans_id,t2.segment as segment
	from(
		select product_id,trans_id from ODS_CRM.FactTrans
		where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag=1 
		and convert(date, sap_time) between convert(date,getdate() - 91) and convert(date,getdate() - 1)
		)t1 
		left join DW_Product.V_SKU_Profile t2 on convert(nvarchar(255),t1.product_id)=t2.sku_cd
		where t2.segment is not null and t2.segment is not NULL
)
                                                        
,temp2 as (
	select t1.trans_id as bask_id,segment from temp1 t1
	left outer join (
			select trans_id from temp1 group by trans_id having count(distinct segment)>1
			)t2 on t1.trans_id=t2.trans_id
	where t2.trans_id is not null 
)
                                                        
,temp3 as (
	select segment, count(distinct bask_id) as bask_cnt
	from temp2
	group by segment
)
                                                        
,temp4 as (
	select t1.segment as segment_1,t2.segment as segment_2,count(distinct t1.bask_id) as bask_cnt
	from temp2 t1
	left outer join temp2 t2 on t1.bask_id=t2.bask_id
	where t1.segment<>t2.segment
	group by t1.segment,t2.segment
)
                                                        
,temp5 as (
    select segment_1,segment_2
    from(
        select segment_1,segment_2
        ,row_number() over(partition by segment_1 order by lift desc) lift_rn
        from(
            select t1.segment_1,t1.segment_2, t1.bask_cnt as pair_baskcnt, t2.bask_cnt as segment_1_baskcnt
            , t3.bask_cnt as segment_2_baskcnt, t4.bask_cnt as total_cnt
            ,ROUND(CAST(t1.bask_cnt AS float)/t4.bask_cnt, 4) as support
            ,ROUND(CAST(t1.bask_cnt AS float)/t2.bask_cnt, 4) as confidence
            ,ROUND(CAST(t1.bask_cnt AS float)/t2.bask_cnt/t3.bask_cnt*t4.bask_cnt, 4) as lift
            from temp4 t1
            left outer join
                temp3 t2 on t1.segment_1=t2.segment
            left outer join
                temp3 t3 on t1.segment_2=t3.segment
            cross join (
                select count(distinct bask_id) as bask_cnt from temp2
                ) t4
            )tt
    )tt where lift_rn=1
)
                    
update DA_Tagging.crm_membership2
set next_segment_to_buy = ttt.nextToBuySegment
from DA_Tagging.crm_membership2 tt1
join(
select account_id,tt2.segment_2 as nextToBuySegment
from(
    select account_id,t2.segment as segment
    from(
        select product_id,account_id from ODS_CRM.FactTrans
        where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag=1 
        and convert(date, sap_time) between convert(date,getdate() - 91) and convert(date,getdate() - 1)
        )t1 
        left join DW_Product.V_SKU_Profile t2 on convert(nvarchar(255),t1.product_id)=t2.sku_cd
            where t2.segment is not null and t2.segment is not NULL
    )tt1
    left join temp5 tt2 on tt1.segment =tt2.segment_1
)ttt on  tt1.crm_account_id=ttt.account_id   
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership [propensity_score]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
;
update DA_Tagging.crm_membership2
set propensity_score = t2.[label]
from DA_Tagging.crm_membership2 tt
join DA_Tagging.crm_predict t2 on tt.crm_account_id = t2.account_id   --DA_Tagging.crm_predict_temp1


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Generate Crm Memebership Tag End ',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
;

delete from DA_Tagging.crm_membership2
where private_sale_preference is null
and holiday_preference is null
and season_preference is null
and price_sensitivity is null
and private_sale_sensitivity is null
and next_segment_to_buy is null
and next_brand_to_buy is null
and propensity_score is null
and avg_purchase_times_offline2online is null
and avg_purchase_interval_offline2online is null
and preferred_range is null
and preferred_segment is null
and preferred_brand_type is null

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Crm','Tagging System Crm Memebership, Delete Crm Memebership Invalid Tag End ',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())    
;
END
GO
