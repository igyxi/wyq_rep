/****** Object:  StoredProcedure [DA_BeautyIn].[SP_T1_1_DataPrep_Bak20230414]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_BeautyIn].[SP_T1_1_DataPrep_Bak20230414] AS
BEGIN

--------------------------------------------------------------------------id mapping

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn Id Mapping Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;


TRUNCATE TABLE DA_BeautyIn.id_mapping

insert into DA_BeautyIn.id_mapping
select distinct master_id,sephora_user_id,sephora_card_no,crm_account_id,sensor_id
from DA_Tagging.id_mapping t
where if_valid=1
and sephora_user_id is not null

--------------------------------------------------------------------------user profile
;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User Profile Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;

TRUNCATE TABLE DA_BeautyIn.user_profile

insert into DA_BeautyIn.user_profile(master_id,sephora_user_id)
select distinct master_id,sephora_user_id
from DA_BeautyIn.id_mapping
where sephora_user_id is not null

;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User Age/Gender/City Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;

-- update age, gender
update DA_BeautyIn.user_profile
set age = tt2.age
    ,gender = tt2.gender
    ,city_tier = tt2.city
from DA_BeautyIn.user_profile tt1
join(
    select user_id,case when t1.age between 1 and 120 then t1.age else null end as age
    ,case when gender='F' then N'女性' when gender='M' then N'男性' else N'未知' end as gender,city
    from (
        select user_id, gender,dateofbirth, datediff(year,dateofbirth,convert(date,getdate())) as age,city
        from STG_User.V_User_Profile
        where isnumeric(user_id)=1 and user_id is not null
        )t1
)tt2 on tt1.sephora_user_id = tt2.user_id

;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User City Tier Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- update city_tier
update DA_BeautyIn.user_profile
set city_tier = tt2.citytiercode
from DA_BeautyIn.user_profile tt1
join(
    select master_id,t1.city_tier,t2.citytiercode
    from(
    select master_id,city_tier
    from DA_BeautyIn.user_profile where city_tier is not null) t1
    left join DA_Tagging.city_list t2
    on t1.city_tier = t2.city collate Chinese_PRC_CS_AI_WS
) tt2 on tt1.master_id = tt2.master_id

;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User Card Type Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- update current_card_type
update DA_BeautyIn.user_profile
set  card_type = t2.current_card_type
from DA_BeautyIn.user_profile t1
join(
    select master_id,current_card_type
    from DA_Tagging.crm_membership
    where current_card_type is not null
    )t2
on t1.master_id=t2.master_id

;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User [category_preference] Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- update category_preference
update DA_BeautyIn.user_profile
set [category_preference] = replace(upper(tt2.[preferred_category]),' ','')
from DA_BeautyIn.user_profile tt1
join(
    select master_id,[preferred_category]
    from DA_Tagging.online_purchase1
    where master_id<>0
)tt2 on tt1.master_id=tt2.master_id

;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User [brand_preference] Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- update brand_preference
update DA_BeautyIn.user_profile
set brand_preference = replace(upper(tt2.preferred_brand),' ','')
from DA_BeautyIn.user_profile tt1
join(
    select master_id,preferred_brand
    from DA_Tagging.online_purchase2
    where master_id<>0
)tt2 on tt1.master_id=tt2.master_id

;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User [like_cnt] Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;


-- update like_cnt, collect_cnt
update DA_BeautyIn.user_profile
set like_cnt = tt2.like_cnt, collect_cnt = tt2.collect_cnt
from DA_BeautyIn.user_profile tt1
join(
    select user_id
    , sum(case behavior when 'like' then cnt else 0 end) like_cnt
    , sum(case behavior when 'collect' then cnt else 0 end) collect_cnt
    from (
        select user_id, behavior, count(*) cnt
        from ODS_BEA.Beauty_Behavior_Post
        group by user_id, behavior
        ) ttt1
    group by ttt1.user_id
)tt2 on tt1.sephora_user_id = tt2.user_id

;
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User [post_cnt] Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;

-- update post_cnt
update DA_BeautyIn.user_profile
set post_cnt = tt2.post_cnt
from DA_BeautyIn.user_profile tt1
join(
    select post_author_id, count(post_id) post_cnt
    from ODS_BEA.Beauty_Behavior_Post
    group by post_author_id
)tt2 on tt1.sephora_user_id = tt2.post_author_id

;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User [comment_cnt] Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;


-- update comment_cnt
update DA_BeautyIn.user_profile
set comment_cnt = tt2.comment_cnt
from DA_BeautyIn.user_profile tt1
join(
    select author_id, count(post_id) comment_cnt
    from ODS_BEA.Beauty_Comment
    group by author_id
)tt2 on tt1.sephora_user_id = tt2.author_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User [user_level] Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- update user_level
update DA_BeautyIn.user_profile
set user_level = tt2.user_level
from DA_BeautyIn.user_profile tt1
join(
    select UserID, BeautyLevelId as user_level
    from ODS_BEA.Beauty_Userprofile
)tt2 on tt1.sephora_user_id = tt2.UserID
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn User [user_score] Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- update user_score
update DA_BeautyIn.user_profile
set user_score = tt2.user_score
from DA_BeautyIn.user_profile tt1
join(
    select UserID, GranuleCount as user_score
    from ODS_BEA.Beauty_Userfortune
)tt2 on tt1.sephora_user_id = tt2.UserID
 
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn user profile for seg Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
--------------------------------------------------------------------------user profile for seg
TRUNCATE TABLE DA_BeautyIn.user_group

insert into DA_BeautyIn.user_group
select user_id as sephora_user_id, 
case when gender = '?' or gender = '2' then 'F'
when gender = '0' then 'M'
when gender = '1' then 'N'
else gender end as gender,
--gender,
    datediff(yy,birthday,getdate()) as age,
    v.city, citytiername as city_tier, card_level
from [DW_User].[V_User_Info] v
left join DA_Tagging.city_list c
on v.city = c.city COLLATE SQL_Latin1_General_CP1_CI_AS 

--UPDATE DA_BeautyIn.user_group
--set gender = 'F '
--where gender = '?' or gender = '2'

--UPDATE DA_BeautyIn.user_group
--set gender = 'M '
--where gender = '0'

--UPDATE DA_BeautyIn.user_group
--set gender = 'N '
--where gender = '1'

;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn existing post2product tags Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
--------------------------------------------------------------------------existing post2product tags
TRUNCATE Table DA_BeautyIn.post_product
insert into  DA_BeautyIn.post_product
select post_id,sku_id,sku_code
,replace(replace(upper(target_gender),' ',''),',','') as target_gender
,replace(replace(upper(category),' ',''),',','') as category
,replace(replace(upper(subcategory),' ',''),',','') as subcategory
,replace(replace(upper(thirdcategory),' ',''),',','') as thirdcategory
,replace(replace(upper(brand),' ',''),',','') as brand
,replace(replace(upper(skin_type),' ',''),',','') as skin_type
,replace(replace(upper(target_age_group),' ',''),',','') as target_age_group
,replace(replace(upper(skincare_function_basic),' ',''),',','') as skincare_function_basic
,replace(replace(upper(makeup_function),' ',''),',','') as makeup_function
,replace(replace(upper(fragrances_stereotype),' ',''),',','') as fragrances_stereotype
from(
    select post_id,skuid as sku_id, sku_code,target_gender,t1.category,subcategory,thirdcategory
        ,brand,skin_type,target_age_group,skincare_function_basic,makeup_function,fragrances_stereotype
    from ODS_BEA.Beauty_Send_Timeline_Content_JsonFormat t0
inner join(
    select product_id,sku_code,sku_id,category ,subcategory ,thirdcategory ,target_gender ,brand
    ,skincare_function_basic ,makeup_function ,target_age_group ,skin_type ,fragrances_stereotype
        from(
            select t1.product_id,sku_code,sku_id
            ,case when t1.category is null then t2.category  COLLATE SQL_Latin1_General_CP1_CI_AS else t1.category end as category,subcategory,thirdcategory
            ,case when t1.target_gender is null then t2.target_gender  COLLATE SQL_Latin1_General_CP1_CI_AS else t1.target_gender end as target_gender
            ,case when t1.brand is null then t2.brand  COLLATE SQL_Latin1_General_CP1_CI_AS else t1.brand end as brand
            ,skincare_function_basic,makeup_function,target_age_group,skin_type,fragrances_stereotype
            from(
                select product_id,sku_cd,sku_id,category,brand,target_gender
                from(
                    select distinct product_id,sku_cd,sku_id,category,brand_name as brand
                    ,case when target='WOMEN' then N'女士' when target='MEN' then N'男士' else null end as target_gender
                    from [DW_Product].[V_SKU_Profile]
                    where sku_cd is not null
                    and (category is not null or brand_name is not null or target is not null)
                    )t
                )t1
            left outer join(
                    select product_id,sku_code ,category ,subcategory ,thirdcategory ,target_gender
                    ,brand ,skincare_function_basic ,makeup_function ,target_age_group ,skin_type ,fragrances_stereotype
                    from DA_Tagging.sephoraproductlist
                )t2 on t1.sku_cd=t2.sku_code COLLATE SQL_Latin1_General_CP1_CI_AS
            )tttt1
)t1 on t0.skuId = t1.sku_id)t

;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn user-post behavior weighted Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
--------------------------------------------------------------------------user-post behavior weighted
TRUNCATE Table DA_BeautyIn.user_post_score

insert into DA_BeautyIn.user_post_score
select sephora_user_id, post_id, sum(post_score) as post_score
from (select sephora_user_id, post_id ,convert(decimal(18,2)
, case when monthdiff <= 6  then post_score
else power(0.95, (monthdiff-6))*post_score  end ) as post_score
from(select sephora_user_id,post_id,
    case when behavior='like' then 2
        when behavior='collect' then 2
        when behavior='comment' then 1
        when behavior='view' then 0.5 end as post_score,
    datediff(mm, behavior_time, convert(date,getdate()-1)) as monthdiff
    from(select user_id as sephora_user_id,post_id,behavior, convert(nvarchar(10),behavior_time,121) as behavior_time
        from ODS_BEA.Beauty_Behavior_Post
        where behavior in ('like','collect')
        and convert(nvarchar(10),behavior_time,121) >= dateadd(mm,-12,getdate())

        union all

        select author_id as sephora_user_id,post_id,
        'comment' as behavior, convert(nvarchar(10),create_time,121) as behavior_time
        from ODS_BEA.Beauty_Comment
        where convert(nvarchar(10),create_time,121) >= dateadd(mm,-12,getdate())

		union all

        select tt2.sephora_user_id,post_id, behavior, behavior_time
        from(
            select user_id, beauty_article_id collate Chinese_PRC_CS_AI_WS  as post_id,
                        'view' as behavior, convert(date,time) as behavior_time
            from [STG_Sensor].[V_Events]  v
            where dt >= dateadd(mm,-3,getdate())
			and platform_type ='MiniProgram'
            and event='beautyIN_blog_view'
            and beauty_article_id is not null
            and time >= dateadd(mm,-3,getdate())
        )tt1
        inner join DA_BeautyIn.id_mapping tt2
        on tt1.user_id=tt2.sensor_id
        where sephora_user_id is not null
        ) t1
    ) t2
) t3
group by sephora_user_id, post_id

;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn user-post behavior Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
--------------------------------------------------------------------------user-post behavior
TRUNCATE Table DA_BeautyIn.user_post_score_ranking

insert into DA_BeautyIn.user_post_score_ranking
select sephora_user_id, post_id, sum(post_score) as post_score
from(select sephora_user_id,post_id,
    case when behavior='like' then 2
        when behavior='collect' then 2
        when behavior='comment' then 1
        when behavior='view' then 0.5 end as post_score
    from(select user_id as sephora_user_id,post_id,behavior
        from ODS_BEA.Beauty_Behavior_Post
        where behavior in ('like','collect')
        and convert(nvarchar(10),behavior_time,121) >= dateadd(mm,-3,getdate())

        union all

        select author_id as sephora_user_id,post_id,
        'comment' as behavior
        from ODS_BEA.Beauty_Comment
        where convert(nvarchar(10),create_time,121) >= dateadd(mm,-3,getdate())

        union all

        select tt2.sephora_user_id,post_id, behavior
        from(
        select user_id, beauty_article_id collate Chinese_PRC_CS_AI_WS  as post_id,
                    'view' as behavior, convert(date,time) as behavior_time
        from [STG_Sensor].[V_Events]  v
        where dt >= dateadd(mm,-3,getdate())
		and platform_type ='MiniProgram'
        and event='beautyIN_blog_view'
        and beauty_article_id is not null
        and time >= dateadd(mm,-3,getdate())
        )tt1
        inner join DA_BeautyIn.id_mapping tt2
        on tt1.user_id=tt2.sensor_id
        where sephora_user_id is not null
        ) t1
    ) t2
group by sephora_user_id, post_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn user-product behavior Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;

--------------------------------------------------------------------------user-product behavior/purchase
TRUNCATE Table DA_Beautyin.user_prod_behavior
insert into DA_Beautyin.user_prod_behavior
select distinct user_id,op_code,behavior
,case when behavior='click' then 1 when behavior= 'add' then 2
else null end as behavior_score
,time,platform
from(
    select user_id,time
    ,case when event in ('viewCommodityDetail') then 'click'
    when event = 'addToShoppingcart' then 'add'
    else null end as behavior
    , orderid, op_code
    ,platform_type as platform
    from [STG_Sensor].[V_Events]
    where dt between convert(date,getdate() - 30) and convert(date,getdate() - 1)
    and ISNUMERIC(op_code)=1 and op_code<>'0'
    and event in ('viewCommodityDetail','addToShoppingcart')
    )t1
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn user-product behavior Start... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;


TRUNCATE Table DA_Beautyin.user_prod_purchase
insert into DA_Beautyin.user_prod_purchase
select tt2.sephora_user_id,tt3.op_code,sum(behavior_score) as behavior_score
from
(
	select account_id,product_id,convert(int,sum(qtys*3)) as behavior_score
	from [ODS_CRM].[FactTrans]
	where account_id<>0
	and qtys>0 and sales>0
	and convert(date,trans_time) between convert(date,getdate() - 30) and convert(date,getdate() - 1)
	group by account_id,product_id)tt1
inner join
(
	select sephora_user_id,crm_account_id
	from DA_Beautyin.id_mapping
	where crm_account_id is not null)tt2 on tt1.account_id=tt2.crm_account_id
inner join
(
	select t1.product_id as crm_product_id,t2.product_id as op_code
	from [ODS_CRM].[DimProduct] t1    
	inner join
	DW_Product.V_SKU_Profile t2
	on t1.sku_code=t2.sku_cd collate Chinese_PRC_CS_AI_WS
	where  t2.product_id<>0)tt3 on tt1.product_id=tt3.crm_product_id
group by tt2.sephora_user_id,tt3.op_code


;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'BeautyIn','BeautyIn, Generate BeautyIn End... ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
END



GO
