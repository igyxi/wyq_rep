/****** Object:  StoredProcedure [DA_Tagging].[SP_T4_1_Prod]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T4_1_Prod] AS
BEGIN

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product Tab Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;


TRUNCATE TABLE DA_Tagging.product
insert into DA_Tagging.product(product_id,sku_cd)
select product_id,sku_cd
from DW_Product.v_sku_profile
where product_id is not null or sku_cd is not null
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product Crm Product ID Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.product
set crm_product_id = t2.product_id
from DA_Tagging.product t1
join ODS_CRM.DimProduct t2 on t1.sku_cd = t2.sku_code collate Chinese_PRC_CS_AI_WS
;



/* ############ ############ ############ Product Daily Update Tag ############ ############ ############ */
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product Coding Tag Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.product
set brand = t2.brand_name --UPPER(SUBSTRING(t2.brand_name,1,1))+LOWER(SUBSTRING(t2.brand_name,2,( SELECT LEN(t2.brand_name))))

,brand_type = UPPER(SUBSTRING(t2.brand_type,1,1))+LOWER(SUBSTRING(t2.brand_type,2,( SELECT LEN(t2.brand_type))))
,brand_origin = t2.brand_origin 

,skin_type = (case 
 when t2.att_39 like N'%敏感%' then N'敏感肌'
 when t2.att_39 like N'%混合%' then N'混合肌'
 when t2.att_39 like N'%油%' then N'油皮'
 when t2.att_39 like N'%干%' then N'干皮'
 when t2.att_39 like N'%中性%' then N'中性皮'
 when t2.att_39 like N'%各种肤质%' then N'各种肤质'
end)

,skincare_function_forproductlistcase = (case 
        when t2.level1_name=N'护肤' 
		and (
			t2.att_47 like N'%提亮肤色%'   
			or t2.att_47 like N'%亮白%'   
			or t2.att_78 like N'%提亮肤色%' 
			or t2.sku_name_cn like N'%烟酰胺%'
			or t2.sku_name_cn like N'%美白%'
			or t2.sku_name_cn like N'%钻白%'
			or t2.sku_name_cn like N'%焕白%'
			or t2.sku_name_cn like N'%透亮%'
			or t2.sku_name_cn like N'%亮白%'
			or t2.sku_name_cn like N'%沁白%'
			or t2.sku_name_cn like N'%透白%'
			or t2.sku_name_cn like N'%润白%'
			or t2.sku_name_cn like N'%曜白%'
			or t2.sku_name_cn like N'%臻白%' ) then N'美白提亮'
    when  t2.level1_name=N'护肤' 
		and (
			t2.att_47 like N'%抗氧化%'
			or t2.att_47 like N'%提拉紧致%'
			or t2.att_47 like N'%淡化细纹%'
			or t2.att_47 like N'%抗老%'
			or t2.att_47 like N'%抗老修复%'
			or t2.att_78 like N'%淡化细纹%'
			or t2.att_78 like N'%提拉紧致%'
			or t2.sku_name_cn like N'%抗初老%' ) then N'抗初老'
    when  t2.level1_name=N'护肤' 
		and (
			t2.att_47 like    N'%保湿补水%'
			or t2.att_47 like   N'%滋润%'
			or t2.att_47 like   N'%保湿%'
			or t2.sku_name_cn like  N'%喷雾%'
			or t2.sku_name_cn like  N'%肤水%'
			or t2.sku_name_cn like  N'%滋养%'
			or t2.sku_name_cn like  N'%补水%'
			or t2.sku_name_cn like  N'%水润%'
			or t2.sku_name_cn like  N'%保湿%'
			or t2.sku_name_cn like  N'%滋润%') then N'保湿补水' end)

,makeup_look = (case 
    when t2.level1_name=N'彩妆'
		and( t2.sku_name_cn like N'%哑光%'
			or t2.sku_name_cn like N'%丝绒%'
			or t2.sku_name_cn like N'%柔雾%'
			or t2.sku_name_cn like N'%雾光%'
			or t2.sku_name_cn like N'%雾面%'
			or t2.sku_name_cn like N'%雾感%'
			or t2.sku_name_cn like N'%绒雾%'
			or t2.sku_name_cn like N'%雾彩%'
			or t2.sku_name_cn like N'%云雾%'
			or t2.sku_name_cn like N'%轻雾%'
			or t2.att_33 like N'%哑光%') then N'哑光'
    when t2.level1_name=N'彩妆'
		and(t2.sku_name_cn like N'%缎面%'
			or t2.sku_name_cn like N'%光泽%'
			or t2.att_33 like N'%金属%'
			or t2.att_33 like N'%光泽%'
			or t2.att_33 like N'%缎面%' ) then N'亮面' 
	when t2.level1_name=N'彩妆'
        and( t2.att_33 like N'%细闪%'
             or t2.sku_name_cn like N'%珠光%' ) then N'珠光'
			end)

,skincare_function_basic = (
	case 
	when level1_name=N'护肤' and att_47 like  N'%亮白%' then N'美白'
	when level1_name=N'护肤' and sku_name_cn like  N'%抗初老%' then N'抗老'
	when level1_name=N'护肤' and att_47 like  N'%抗老%' then N'抗老'
	when level1_name=N'护肤' and att_47 like  N'%抗老修复%' then N'  抗老'
	when level1_name=N'护肤' and sku_name_cn like  N'%喷雾%' then N'保湿补水'
	when level1_name=N'护肤' and sku_name_cn like  N'%肤水%' then N'保湿补水'
	when level1_name=N'护肤' and sku_name_cn like  N'%滋养%' then N'保湿补水'
	when level1_name=N'护肤' and sku_name_cn like  N'%补水%' then N'保湿补水'
	when level1_name=N'护肤' and sku_name_cn like  N'%水润%' then N'保湿补水'
	when level1_name=N'护肤' and sku_name_cn like  N'%保湿%' then N'保湿补水'
	when level1_name=N'护肤' and sku_name_cn like  N'%滋润%' then N'保湿补水'
	when level1_name=N'护肤' and att_47 like  N'%保湿%' then N'保湿补水'
	when level1_name=N'护肤' and att_47 like  N'%滋润%' then N'保湿补水'
	when level1_name=N'护肤' and att_47 like  N'%修护%' then N'修护'
	when level1_name=N'护肤' and att_47 like  N'%修复%' then N'修复'
	when level1_name=N'护肤' and att_47 like  N'%祛痘%' then N'祛痘'
	when level1_name=N'护肤' and att_47 like  N'%祛粉刺/祛痘%' then N'祛痘'
	when level1_name=N'护肤' and att_47 like  N'%晒后修护%' then N'晒后修护'
	when level1_name=N'护肤' and att_47 like  N'%防晒%' then N'防晒'
	when level1_name=N'护肤' and sku_name_cn like  N'%防晒%' then N'防晒'
	when level1_name=N'护肤' and att_47 like  N'%隔离%' then N'防晒'
	when level1_name=N'护肤' and att_47 like  N'%隔离防晒%' then N'防晒'
	when level1_name=N'护肤' and att_47 like  N'%去角质%' then N'去角质'
	when level1_name=N'护肤' and att_78 like  N'%去角质%' then N'去角质'
	when level1_name=N'护肤' and att_47 like  N'%去屑%' then N'去屑'
	when level1_name=N'护肤' and att_47 like  N'%控油%' then N'控油'
	when level1_name=N'护肤' and att_47 like  N'%清爽控油%' then N'控油'
	when level1_name=N'护肤' and att_47 like  N'%丰盈%' then N'丰盈'
	when level1_name=N'护肤' and att_47 like  N'%清洁%' then N'清洁'
	when level1_name=N'护肤' and att_78 like  N'%清洁%' then N'清洁'
	when level1_name=N'护肤' and att_47 like  N'%亮泽%' then N'亮泽'
	when level1_name=N'护肤' and att_47 like  N'%柔顺%' then N'柔顺'
	when level1_name=N'护肤' and att_47 like  N'%头皮护理%' then N'头皮护理'
	end
)

,skincare_function_special=(case
    when level1_name= N'护肤' and att_47 like N'%提亮肤色%' then N'提亮'
    when level1_name= N'护肤' and att_78 like N'%提亮肤色%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%烟酰胺%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%美白%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%钻白%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%焕白%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%透亮%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%亮白%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%沁白%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%透白%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%润白%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%曜白%' then N'提亮'
    when level1_name= N'护肤' and sku_name_cn like N'%臻白%' then N'提亮'
    when level1_name= N'护肤' and att_47 like N'%抗氧化%' then N'抗氧化'
    when level1_name= N'护肤' and att_47 like N'%提拉紧致%' then N'提拉紧致'
    when level1_name= N'护肤' and att_78 like N'%提拉紧致%' then N'提拉紧致'
    when level1_name= N'护肤' and att_47 like N'%淡化细纹%' then N'淡化细纹'
    when level1_name= N'护肤' and att_78 like N'%淡化细纹%' then N'淡化细纹'
    when level1_name= N'护肤' and att_47 like N'%抗皱%' then N'淡化细纹'
    when level1_name= N'护肤' and att_47 like N'%细致毛孔%' then N'细致毛孔'
    when level1_name= N'护肤' and att_47 like N'%修饰毛孔%' then N'修饰毛孔'
    when level1_name= N'护肤' and att_47 like N'%淡斑%' then N'淡斑'
    when level1_name= N'护肤' and att_47 like N'%淡化黑眼圈%' then N'淡化黑眼圈'
    when level1_name= N'护肤' and att_47 like N'%改善眼部浮肿%' then N'改善眼部浮肿'
    when level1_name= N'护肤' and att_78 like N'%改善眼部浮肿%' then N'改善眼部浮肿'
    when level1_name= N'护肤' and att_47 like N'%改善眼部肌肤%' then N'改善眼部肌肤'
    when level1_name= N'护肤' and att_78 like N'%改善眼部肌肤%' then N'改善眼部肌肤'
    when level1_name= N'护肤' and att_47 like N'%去红血丝%' then N'去红血丝'
    when level1_name= N'护肤' and att_47 like N'%舒缓%' then N'舒缓'
    when level1_name= N'护肤' and att_78 like N'%舒缓%' then N'舒缓'
    when level1_name= N'护肤' and att_47 like N'%美胸%' then N'美胸'
    when level1_name= N'护肤' and att_47 like N'%纤体%' then N'纤体'
    when level1_name= N'护肤' and att_47 like N'%护色%' then N'护色'
end)


,target_gender = (case 
      when (t2.level1_name like N'%男士%'
        or t2.att_51 like N'%男士%'
        or t2.level2_name in (N'男士',N'男士护肤',N'男士彩妆')
        or t2.brand_name_cn in (N'朗仕', N'杜比丽夫', N'JACK BLACK')
        or t2.brand_name in (N'LAB SERIES', N'DTRT', N'JACK BLACK')
        or t2.sku_name_cn like N'%男士%'
        or t2.sku_name_cn like N'%男用%'
        or t2.sku_name_cn like N'%男式%'
        or t2.sku_name_cn like N'%男款%'
        or t2.sku_name_cn like N'%男性%'
        or t2.sku_name_cn like N'%剃须%'
        or t2.sku_name_cn like N'%朗仕%'
        or t2.sku_name_cn like N'%LAB SERIES%'
        or t2.sku_name_cn like N'%Lab Series%'
        or t2.sku_name_cn like N'%杜比丽夫%'
        or t2.sku_name_cn like N'%DTRT%'
        or t2.sku_name_cn like N'%JACK BLACK%') then N'男士' 
	when (t2.att_51 like N'%女士%'
		or t2.att_51 like N'%女士%') then N'女士' 
	when t2.att_51 like N'%通用%' then N'通用'
		end)

--,subcategory = (case 
--        when t2.level1_name = N'香水' then N'Women Fragrances,Unisex Fragrances,Men Fragrances'
--        when t2.level2_name = N'眼部护理' then N'Eye Care'
--        when t2.level1_name = N'彩妆' and t2.level2_name = N'眼部彩妆' then N'Eyes Makeup'
--        when t2.level2_name in (N'面部护理',N'面膜',N'清洁') then N'Face Care'
--        when t2.level1_name = N'彩妆' and t2.level2_name = N'脸部彩妆' then N'Face Makeup'
--        when t2.level1_name = N'彩妆' and t2.level2_name = N'唇部彩妆' then N'Lips Makeup' end)

,season =( case  
	when (t2.product_name_cn like N'%春季%' and t2.product_name_cn not like N'%限定%' and t2.product_name_cn not like N'%限量%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%春日%' and t2.product_name_cn not like N'%限定%' and t2.product_name_cn not like N'%限量%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%春夏%' and t2.product_name_cn not like N'%限定%' and t2.product_name_cn not like N'%限量%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%夏%' and t2.product_name_cn not like N'%夏威夷%' and t2.product_name_cn not like N'%限定%' and t2.product_name_cn not like N'限量' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%清爽%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%清透%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%轻盈%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%水润%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%水盈%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%水滢%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%高倍防晒%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%高倍防护%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%黄瓜%' and t2.level1_name in (N'护肤', N'彩妆') )
	or (t2.product_name_cn like N'%喷雾%' and t2.level1_name = N'护肤' )
	or t2.att_41 like N'%SPF50%'  
	then N'春夏'
	when (t2.product_name_cn like N'%手霜%')
	or (t2.product_name_cn like N'%手部修护霜%')
	or (t2.product_name_cn like N'%秋%' and t2.product_name_cn not like N'%限定%' and t2.product_name_cn not like N'%限量%' and t2.level1_name in (N'护肤', N'彩妆'))
	or (t2.product_name_cn like N'%冬%' and t2.product_name_cn not like N'%限定%' and t2.product_name_cn not like N'%限量%' and t2.level1_name in (N'护肤', N'彩妆'))
	or (t2.product_name_cn like N'%丝绒%' and t2.level1_name in (N'护肤', N'彩妆'))
	or (t2.product_name_cn like N'%丝缎%' and t2.level1_name in (N'护肤', N'彩妆'))
	or (t2.product_name_cn like N'%滋润%' and t2.level1_name in (N'护肤', N'彩妆'))
	or (t2.product_name_cn like N'%特润%' and t2.level1_name in (N'护肤', N'彩妆'))
	or (t2.product_name_cn like N'%倍润%' and t2.level1_name in (N'护肤', N'彩妆'))
	or (t2.product_name_cn like N'%高保湿%' and t2.level1_name in (N'护肤', N'彩妆'))
	then N'秋冬' end )

,format = (case when t2.att_54 like N'%粉饼%' then N'粉状'
                when t2.att_54 like N'%膏状%' then N'膏状'
                when t2.att_54 like N'%固态%' then N'固态'
                when t2.att_54 like N'%固体%' then N'固态'
                when t2.att_54 like N'%混合质地%' then N'混合'
                when t2.att_54 like N'%颗粒%' then N'颗粒'
                when t2.att_54 like N'%泥状%' then N'泥状'
                when t2.att_54 like N'%凝胶%' then N'凝胶'
                when t2.att_54 like N'%泡沫%' then N'泡沫'
                when t2.att_54 like N'%喷雾%' then N'喷雾'
                when t2.att_54 like N'%片状%' then N'片状'
                when t2.att_54 like N'%其他%' then N'其他'
                when t2.att_54 like N'%气垫%' then N'气垫'
                when t2.att_54 like N'%乳液%' then N'乳液'
                when t2.att_54 like N'%乳状%' then N'乳状'
                when t2.att_54 like N'%霜状%' then N'霜状'
                when t2.att_54 like N'%水%' then N'水液'
                when t2.att_54 like N'%水液%' then N'水液'
                when t2.att_54 like N'%液体%' then N'水液'
                when t2.att_54 like N'%套装%' then N'套装'
                when t2.att_54 like N'%油质%' then N'油状'
                when t2.att_54 like N'%油状%' then N'油状'
                when t2.att_54 like N'%啫喱%' then N'啫喱'
                when t2.sku_name_cn like N'%粉饼%' then N'粉状'
                when t2.sku_name_cn like N'%散粉%' and t2.sku_name_cn not like N'%刷%'  and t2.sku_name_cn not like N'%膏%' then N'粉状'
                when t2.sku_name_cn like N'%露%'  and t2.sku_name_cn not like N'%露娜%' and t2.sku_name_cn not like N'%露茗堂%' and t2.sku_name_cn not like N'%4爽露%' then N'乳液'
                when t2.sku_name_cn like N'%油%'  and t2.sku_name_cn not like N'%去油%' and t2.sku_name_cn not like N'%奶油%' and t2.sku_name_cn not like N'%牛油果%' then N'油状'
                when t2.sku_name_cn like N'%蜜粉%' and t2.sku_name_cn not like N'%棒%'  and t2.sku_name_cn not like N'%液%' and t2.sku_name_cn not like N'%膏%' and t2.sku_name_cn not like N'%胶%' then N'粉状'
                when t2.sku_name_cn like N'%腮红%' and t2.sku_name_cn not like N'%棒%'  and t2.sku_name_cn not like N'%液%' and t2.sku_name_cn not like N'%膏%' and t2.sku_name_cn not like N'%胶%' then N'粉状'
                when t2.sku_name_cn like N'%眼影%' and t2.sku_name_cn not like N'%棒%'  and t2.sku_name_cn not like N'%液%' and t2.sku_name_cn not like N'%膏%' and t2.sku_name_cn not like N'%胶%' then N'粉状'
                when t2.sku_name_cn like N'%阴影%' and t2.sku_name_cn not like N'%棒%'  and t2.sku_name_cn not like N'%液%' and t2.sku_name_cn not like N'%膏%' and t2.sku_name_cn not like N'%胶%' then N'粉状'
                when t2.sku_name_cn like N'%高光%' and t2.sku_name_cn not like N'%棒%'  and t2.sku_name_cn not like N'%液%' and t2.sku_name_cn not like N'%膏%' and t2.sku_name_cn not like N'%胶%' then N'粉状'
                when t2.sku_name_cn like N'%膏%' then N'膏状'
                when t2.sku_name_cn like N'%凝胶%' then N'凝胶'
                when t2.sku_name_cn like N'%泡沫%' then N'泡沫'
                when t2.sku_name_cn like N'%雾%' then N'喷雾'
                when t2.sku_name_cn like N'%片状%' then N'片状'
                when t2.sku_name_cn like N'%气垫%' then N'气垫'
                when t2.sku_name_cn like N'%乳%' then N'乳液'
                when t2.sku_name_cn like N'%霜%' then N'霜状'
                when t2.sku_name_cn like N'%化妆水%' then N'水液'
                when t2.sku_name_cn like N'%菁华水%' then N'水液'
                when t2.sku_name_cn like N'%精萃水%' then N'水液'
                when t2.sku_name_cn like N'%精华水%' then N'水液'
                when t2.sku_name_cn like N'%亲肤水%' then N'水液'
                when t2.sku_name_cn like N'%柔肤水%' then N'水液'
                when t2.sku_name_cn like N'%爽肤水%' then N'水液'
                when t2.sku_name_cn like N'%香水%' then N'水液'
                when t2.sku_name_cn like N'%液%' then N'水液'
                when t2.sku_name_cn like N'%啫喱%' then N'啫喱' end)

from  DA_Tagging.product t1
join(
	select distinct sku_cd,product_id,t01.brand_name,brand_name_cn,product_name_cn
	,brand_type, att_39,att_47,att_78,att_54,att_51,sku_name_cn,att_33,att_41
	,level1_name,level2_name ,t02.brand_origin
	from(
		select distinct sku_cd,product_id
		, case when brand_name in ('MAKEUPFOREVER','MAKE UP FOR EVER') then 'MAKE UP FOR EVER' 
		when brand_name in ('LAUDER','ESTEELAUDER') then 'LAUDER' 
		when brand_name in ('YSL','YVES ST LAURENT') then 'YVES ST LAURENT'  else brand_name
		end as brand_name 
		,brand_name_cn,product_name_cn
		,brand_type, att_39,att_47,att_78,att_54,att_51,sku_name_cn,att_33,att_41
		,level1_name,level2_name            
		from DW_Product.v_sku_profile
		)t01
		left join (
				select brand_name,brand_origin from DA_Tagging.coding_brand_origin
					)t02 on t01.brand_name = t02.brand_name COLLATE SQL_Latin1_General_CP1_CI_AS
)t2 on t1.sku_cd COLLATE SQL_Latin1_General_CP1_CI_AS =t2.sku_cd and t1.product_id COLLATE SQL_Latin1_General_CP1_CI_AS= t2.product_id
;


update DA_Tagging.product
set category= t2.category
,subcategory= t2.subcategory
,thirdcategory= t2.thirdcategory
from  DA_Tagging.product t1
join(
	select sku_cd,product_id
	,t2.category,t2.subcategory,t2.thirdcategory
	,t1.level1_name,t1.level2_name,t1.level3_name
	from(
		select sku_cd,product_id
	 	,level1_name,level2_name,level3_name
	 	from DW_Product.v_sku_profile
	 	)t1 left outer join
	 	 DA_Tagging.coding_district_bak t2 
	 	 on t1.level1_name = t2.level1_name COLLATE SQL_Latin1_General_CP1_CI_AS
	 	 and t1.level2_name = t2.level2_name COLLATE SQL_Latin1_General_CP1_CI_AS
	 	 and t1.level3_name = t2.level3_name COLLATE SQL_Latin1_General_CP1_CI_AS
)t2 on t1.sku_cd COLLATE SQL_Latin1_General_CP1_CI_AS=t2.sku_cd  and t1.product_id COLLATE SQL_Latin1_General_CP1_CI_AS= t2.product_id 
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [detailcategory],[format],[franchise],[launch_date]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.product
set detailcategory=tt3.detailcategory,
    franchise = tt3.franchise,
    launch_date = tt3.launch_date
from DA_Tagging.product t
join(
    select product_id,sku_cd,level3_name as detailcategory
        ,franchise,last_publish_time as launch_date
    from DW_Product.V_SKU_Profile 
)tt3 on t.sku_cd=tt3.sku_cd COLLATE Chinese_PRC_CI_AS
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [online_lowest_price],[online_lowest_price_12M],[online_lowest_price_6M]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.product
set  online_lowest_price = tt3.online_lowest_price,
    online_lowest_price_12M = tt3.online_lowest_price_12M,
    online_lowest_price_6M = tt3.online_lowest_price_6M
from DA_Tagging.product t
join (
    select t1.item_sku_cd,online_lowest_price,online_lowest_price_12M,online_lowest_price_6M
    from(
            select item_sku_cd,min(item_apportion_amount) as online_lowest_price
            from DA_Tagging.sales_order_sku_temp
            group by item_sku_cd
        ) t1
        left outer join (
            select item_sku_cd,min(item_apportion_amount) as online_lowest_price_12M
            from DA_Tagging.sales_order_sku_temp
            where convert(date, place_time) between convert(date,getdate()-360) and convert(date,getdate()-1)
            group by item_sku_cd
        ) t2 on t1.item_sku_cd COLLATE Chinese_PRC_CI_AS=t2.item_sku_cd
        left outer join (
            select item_sku_cd,min(item_apportion_amount) as online_lowest_price_6M
            from DA_Tagging.sales_order_sku_temp 
            where convert(date, place_time) between convert(date,getdate()-180) and convert(date,getdate()-1)
            group by item_sku_cd
        ) t3 on t1.item_sku_cd COLLATE Chinese_PRC_CI_AS=t3.item_sku_cd
)tt3 on t.sku_cd=tt3.item_sku_cd COLLATE Chinese_PRC_CI_AS
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [avg_discount_rate]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.product
set avg_discount_rate = tt3.avg_discount_rate
from DA_Tagging.product t
join (
    select item_sku_cd,avg(discount) as avg_discount_rate
    from(
        select item_sku_cd,item_apportion_amount /(case when item_sale_price<>0 then item_sale_price*item_quantity else null end) as discount
        from DW_OMS.V_Sales_Order_SKU_Level
        where item_apportion_amount>0 and is_placed_flag=1 and item_type_cd<>'GWP'
        )t
    group by item_sku_cd
) as tt3 on t.sku_cd COLLATE SQL_Latin1_General_CP1_CI_AS=tt3.item_sku_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [avg_discount_rate]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.product
set omni_channel_sales = tt.omni_sales,
    omni_channel_item = tt.omni_item,
    omni_channel_growth = tt.omni_growth_month
from DA_Tagging.product t
join (
    select t.product_id,omni_sales,omni_item,omni_growth_month
    from(
        select product_id,sum(sales) as omni_sales,sum(qtys) as omni_item
        from ODS_CRM.FactTrans
        where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag=1
            and convert(date, sap_time) between convert(date,getdate() - 180) and convert(date,getdate() - 1)
            -- and convert(date, sap_time) between convert(date,dateadd(dd,-day(getdate())+1,getdate())) and convert(date,dateadd(dd,-1,DATEADD(mm, DATEDIFF(m,0,getdate())+1, 0))) 
        group by product_id)t
    left outer join (
        select t1.product_id,omni_sales_month * 1.0 / omni_sales_l_month -1 as omni_growth_month
        from(
            select product_id,avg(sales) as omni_sales_month
            from ODS_CRM.FactTrans
            where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag=1
                and convert(date, sap_time) between convert(date,dateadd(dd,-day(getdate())+1,getdate())) and convert(date,dateadd(dd,-1,DATEADD(mm, DATEDIFF(m,0,getdate())+1, 0))) 
                --本月第一天和最后一天
            group by product_id)t1
        left outer join(
            select product_id,avg(sales) as omni_sales_l_month
            from ODS_CRM.FactTrans
            where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag=1
                and convert(date, sap_time) between convert(date,DATEADD(m,-1 ,dateadd(dd,-day(getdate())+1,getdate()))) and convert(date,dateadd(d,-1,dateadd(m,-1,DATEADD(mm, DATEDIFF(m,0,getdate())+1, 0))))
                --上月的第一天和最后一天
            group by product_id)t2 on t1.product_id=t2.product_id
    )tt on t.product_id=tt.product_id
) as tt on t.crm_product_id  COLLATE SQL_Latin1_General_CP1_CI_AS=tt.product_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [online_sales],[online_item],[online_avg_item_per_order]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set online_sales = tt.online_sales,
    online_item = tt.online_item,
    online_avg_item_per_order = tt.online_avg_item_per_order
from DA_Tagging.product t
join (
    select t1.item_sku_cd,online_sales,online_item,online_avg_item_per_order
    from(
        select item_sku_cd,sum(item_apportion_amount) as online_sales,sum(item_quantity) as online_item
        from DA_Tagging.sales_order_sku_temp
        group by item_sku_cd)t1 
    left outer join(
        select item_sku_cd,avg(online_item_per_order) as online_avg_item_per_order
        from(
            select sales_order_number,item_sku_cd,sum(item_quantity) as online_item_per_order
            from DA_Tagging.sales_order_sku_temp
            group by sales_order_number,item_sku_cd
            )t
        group by item_sku_cd)t2 on t1.item_sku_cd=t2.item_sku_cd
) as tt on t.sku_cd=tt.item_sku_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [online_growth]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 线上销售增长率
    select item_sku_cd
    ,avg(online_sales_month) as online_sales_month
    into #temp1
    from(
        select item_sku_cd,convert(date,place_time) as place_data
            ,sum(item_apportion_amount) as online_sales_month
            from DW_OMS.V_Sales_Order_VB_Level
            where is_placed_flag=1 and item_apportion_amount>0 
            and convert(date,place_time) between convert(date,DATEADD(hour,8,getdate()) - 30) and convert(date,DATEADD(hour,8,getdate()) - 1) 
            and store_cd='S001'
            group by item_sku_cd,convert(date,place_time)
        )t
    group by item_sku_cd

    select item_sku_cd
    ,avg(online_sales_last_month) as online_sales_last_month
    into #temp2
    from(
        select item_sku_cd,convert(date,place_time) as place_data
            ,sum(item_apportion_amount) as online_sales_last_month
            from DW_OMS.V_Sales_Order_VB_Level
            where is_placed_flag=1 and item_apportion_amount>0 
            and convert(date,place_time) between convert(date,DATEADD(hour,8,getdate()) - 61) and convert(date,DATEADD(hour,8,getdate()) - 31)
            and store_cd='S001'
            group by item_sku_cd,convert(date,place_time)
        )t
    group by item_sku_cd


update DA_Tagging.product
    set online_growth = (tt.online_sales_month-tt.online_sales_last_month)/(case when tt.online_sales_last_month<>0 then tt.online_sales_last_month else null end)
    from DA_Tagging.product t1
    join (
        select t1.item_sku_cd,online_sales_month,online_sales_last_month
        from #temp1 t1 left outer join #temp2 t2 on t1.item_sku_cd=t2.item_sku_cd
)tt on t1.sku_cd  COLLATE SQL_Latin1_General_CP1_CI_AS=tt.item_sku_cd
;                       



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product online channel sales temp',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 产品分渠道消费金额、消费件数
IF OBJECT_ID('tempdb..#online_channel_sales_temp') IS NOT NULL 
DROP TABLE #online_channel_sales_temp; 
create table #online_channel_sales_temp(
    item_sku_cd nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    channel nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    online_sales decimal(20,5),
    online_item int
)
insert into #online_channel_sales_temp
select item_sku_cd,case when channel=N'小程序' then 'MNP' else channel end as channel
    ,sum(item_apportion_amount) as online_sales,sum(item_quantity) as online_item
from(
    select item_sku_cd,channel,item_apportion_amount,item_quantity
    from DA_Tagging.sales_order_sku_temp
    where channel in ('APP',N'小程序') 
    )t1 
group by item_sku_cd,channel

union all

select item_sku_cd
,case when store=N'丝芙兰官网' then 'DRAGON' 
when store=N'京东' then 'JD'
when store=N'天猫' then 'TMALL' else null end as channel
    ,sum(item_apportion_amount) as online_sales,sum(item_quantity) as online_item
from(   
    select item_sku_cd,store,item_apportion_amount,item_quantity
    from DA_Tagging.sales_order_sku_temp
    where store in (N'丝芙兰官网',N'京东',N'天猫')
    )t1 
group by item_sku_cd,store
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [dragon_sales],[app_sales],[mnp_sales],[tmall_sales],[jd_sales]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
-- 渠道消费金额
update DA_Tagging.product
set dragon_sales = tt.dragon_sales,
    app_sales = tt.app_sales,
    mnp_sales = tt.mnp_sales,
    tmall_sales = tt.tmall_sales,
    jd_sales = tt.jd_sales
from DA_Tagging.product t
join (
    select item_sku_cd
        ,max(case when channel='DRAGON' then online_sales else 0 end) as dragon_sales
        ,max(case when channel='APP' then online_sales else 0 end) as app_sales
        ,max(case when channel='MNP' then online_sales else 0 end) as mnp_sales
        ,max(case when channel='TMALL' then online_sales else 0 end) as tmall_sales
        ,max(case when channel='JD' then online_sales else 0 end) as jd_sales
    from #online_channel_sales_temp
    group by item_sku_cd
) as tt on t.sku_cd=tt.item_sku_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [dragon_item],[app_item],[mnp_item],[tmall_item],[jd_item]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set dragon_item = tt.dragon_item,
    app_item = tt.app_item,
    mnp_item =tt.mnp_item,
    tmall_item = tt.tmall_item,
    jd_item = tt.jd_item
from DA_Tagging.product t
join (
    select item_sku_cd
        ,max(case when channel='DRAGON' then online_item else 0 end) as dragon_item
        ,max(case when channel='APP' then online_item else 0 end) as app_item
        ,max(case when channel='MNP' then online_item else 0 end) as mnp_item
        ,max(case when channel='TMALL' then online_item else 0 end) as tmall_item
        ,max(case when channel='JD' then online_item else 0 end) as jd_item
    from #online_channel_sales_temp
    group by item_sku_cd
) as tt on t.sku_cd=tt.item_sku_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product online channel growth temp1',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
IF OBJECT_ID('tempdb..#online_channel_growth_temp1') IS NOT NULL 
DROP TABLE #online_channel_growth_temp1; 
create table #online_channel_growth_temp1(
    item_sku_cd nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    channel nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    online_sales_month decimal(20,5)
)
insert into #online_channel_growth_temp1
select item_sku_cd,case when channel=N'小程序' then 'MNP' else channel end as channel,online_sales_month
from(
    select item_sku_cd,channel,avg(item_sales_daily) as online_sales_month
    from(
        select item_sku_cd,t2.channel,place_date,avg(item_apportion_amount) as item_sales_daily
        from(
            select item_sku_cd,convert(date, place_time) as place_date,item_apportion_amount,store_cd,channel_cd
            from DW_OMS.V_Sales_Order_SKU_Level
            where is_placed_flag=1 and item_apportion_amount>0 
                --本月
                and convert(date,place_time) between convert(date,DATEADD(hour,8,getdate()) - 30) and convert(date,DATEADD(hour,8,getdate()) - 1) 
                )t1 
        left outer join DA_Tagging.channel_store t2 on t1.store_cd=t2.store_cd  COLLATE SQL_Latin1_General_CP1_CI_AS and t1.channel_cd=t2.channel_cd  COLLATE SQL_Latin1_General_CP1_CI_AS
        where t2.channel in ('APP',N'小程序')
        group by item_sku_cd,t2.channel,place_date )t1 
    group by item_sku_cd,channel
)t1

union all

select item_sku_cd,case when store=N'丝芙兰官网' then 'DRAGON' 
                        when store=N'京东' then 'JD'
                        when store=N'天猫' then 'TMALL' else null end as channel,online_sales_month
from(
    select item_sku_cd,store,avg(item_sales_daily) as online_sales_month
    from(
        select item_sku_cd,t2.store,place_date,avg(item_apportion_amount) as item_sales_daily
        from(
            select item_sku_cd,convert(date, place_time) as place_date,item_apportion_amount,store_cd,channel_cd
            from DW_OMS.V_Sales_Order_SKU_Level
            where is_placed_flag=1 and item_apportion_amount>0 
                --本月
                and convert(date,place_time) between convert(date,DATEADD(hour,8,getdate()) - 30) and convert(date,DATEADD(hour,8,getdate()) - 1) 
                )t1 
        left outer join DA_Tagging.channel_store t2 on t1.store_cd=t2.store_cd  COLLATE SQL_Latin1_General_CP1_CI_AS and t1.channel_cd=t2.channel_cd  COLLATE SQL_Latin1_General_CP1_CI_AS
        where t2.store in (N'丝芙兰官网',N'京东',N'天猫')
        group by item_sku_cd,t2.store,place_date )t1 
    group by item_sku_cd,store
)t2
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product online channel growth temp2',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
IF OBJECT_ID('tempdb..#online_channel_growth_temp2') IS NOT NULL 
DROP TABLE #online_channel_growth_temp2; 
create table #online_channel_growth_temp2(
    item_sku_cd nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    channel nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    online_sales_l_month decimal(20,5)
)
insert into #online_channel_growth_temp2
select item_sku_cd,case when channel=N'小程序' then 'MNP' else channel end as channel,online_sales_l_month
from(
    select item_sku_cd,channel,avg(item_sales_daily) as online_sales_l_month
    from(
        select item_sku_cd,t2.channel,place_date,avg(item_apportion_amount) as item_sales_daily
        from (
            select item_sku_cd,convert(date, place_time) as place_date,item_apportion_amount,store_cd,channel_cd
            from DW_OMS.V_Sales_Order_SKU_Level
            where is_placed_flag=1 and item_apportion_amount>0 
                --上月
                and convert(date,place_time) between convert(date,DATEADD(hour,8,getdate()) - 61) and convert(date,DATEADD(hour,8,getdate()) - 31) 
                                                                )t1  
        left outer join DA_Tagging.channel_store t2 on t1.store_cd=t2.store_cd  COLLATE SQL_Latin1_General_CP1_CI_AS and t1.channel_cd=t2.channel_cd  COLLATE SQL_Latin1_General_CP1_CI_AS
        where t2.channel in ('APP',N'小程序')
        group by item_sku_cd,t2.channel,place_date 
        )t1
    group by item_sku_cd,channel
)t1

union all

select item_sku_cd,case when t2.store=N'丝芙兰官网' then 'DRAGON' 
                        when t2.store=N'京东' then 'JD'
                        when t2.store=N'天猫' then 'TMALL' else null end as channel,online_sales_l_month
from(
    select item_sku_cd,store,avg(item_sales_daily) as online_sales_l_month
    from(
        select item_sku_cd,t2.store,place_date,avg(item_apportion_amount) as item_sales_daily
        from(
            select item_sku_cd,convert(date, place_time) as place_date,item_apportion_amount,store_cd,channel_cd
            from DW_OMS.V_Sales_Order_SKU_Level
            where is_placed_flag=1 and item_apportion_amount>0 
                --上月
                and convert(date,place_time) between convert(date,DATEADD(hour,8,getdate()) - 61) and convert(date,DATEADD(hour,8,getdate()) - 31)
                                                            )t1  
        left outer join DA_Tagging.channel_store t2 on t1.store_cd=t2.store_cd  COLLATE SQL_Latin1_General_CP1_CI_AS and t1.channel_cd=t2.channel_cd  COLLATE SQL_Latin1_General_CP1_CI_AS
        where t2.store in (N'丝芙兰官网',N'京东',N'天猫')
        group by item_sku_cd,t2.store,place_date )t1 
    group by item_sku_cd,store
)t2  
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [dragon_growth],[app_growth],[mnp_growth],[tmall_growth],[jd_growth]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set dragon_growth = tt.dragon_growth,
    app_growth = tt.app_growth,
    mnp_growth = tt.mnp_growth,
    tmall_growth = tt.tmall_growth,
    jd_growth = tt.jd_growth
from DA_Tagging.product t
join (
    select item_sku_cd
        ,max(case when channel='DRAGON' then growth else 0 end) as dragon_growth
        ,max(case when channel='APP' then growth else 0 end) as app_growth
        ,max(case when channel='MNP' then growth else 0 end) as mnp_growth
        ,max(case when channel='TMALL' then growth else 0 end) as tmall_growth
        ,max(case when channel='JD' then growth else 0 end) as jd_growth
    from(
        select t1.item_sku_cd,t1.channel
            ,online_sales_month,online_sales_l_month,online_sales_month/online_sales_l_month as growth
        from #online_channel_growth_temp1 t1
        left outer join #online_channel_growth_temp2 t2 
        on t1.item_sku_cd=t2.item_sku_cd and t1.channel=t2.channel)t
    group by item_sku_cd
) as tt on t.sku_cd  COLLATE SQL_Latin1_General_CP1_CI_AS=tt.item_sku_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [product_order_avg_basket]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set product_order_avg_basket=tt.product_order_avg_basket
from DA_Tagging.product t
join (
    select item_sku_cd,cast(avg(product_amount) as float) as product_order_avg_basket
    from(
        select distinct item_sku_cd,t2.sales_order_number,product_amount
        from(
            select item_sku_cd,sales_order_number
            from DW_OMS.V_Sales_Order_SKU_Level
            where is_placed_flag=1 and item_apportion_amount>0 
               )t1  
        join (
            select sales_order_number,product_amount
            from DW_OMS.V_Sales_Order_Basic_Level
            where is_placed_flag=1 and product_amount>0
                )t2 on t1.sales_order_number=t2.sales_order_number
    )t
    group by item_sku_cd
) as tt on t.sku_cd  COLLATE SQL_Latin1_General_CP1_CI_AS=tt.item_sku_cd
; 

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [pink],[white],[black],[gold],[non_member]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set pink = tt.pink_sales,
    white = tt.white_sales,
    black = tt.black_sales,
    gold = tt.gold_sales,
    non_member = tt.non_member_sales
from DA_Tagging.product t
join (
    select item_sku_cd
        ,max(case when member_card_grade='PINK' then sales else 0 end) as pink_sales
        ,max(case when member_card_grade='WHITE' then sales else 0 end) as white_sales
        ,max(case when member_card_grade='BLACK' then sales else 0 end) as black_sales
        ,max(case when member_card_grade='GOLD' then sales else 0 end) as gold_sales
        ,max(case when member_card_grade='non_member' then sales else 0 end) as non_member_sales
    from(
        select item_sku_cd,member_card_grade,sum(item_apportion_amount) as sales
        from(
            select item_sku_cd,item_apportion_amount
                ,case when member_card_grade in ('PINK','WHITE','BLACK','GOLD') then member_card_grade else 'non_member' end as member_card_grade
            from DW_OMS.V_Sales_Order_SKU_Level
            where is_placed_flag=1 and item_apportion_amount>0 
        )t 
        group by item_sku_cd,member_card_grade
    )t
    group by item_sku_cd,member_card_grade
) as tt on t.sku_cd  COLLATE SQL_Latin1_General_CP1_CI_AS=tt.item_sku_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [add_to_cart]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set add_to_cart = tt.add_to_cart
from DA_Tagging.product t
join (
    select op_code,count(event) as add_to_cart
    from STG_Sensor.V_Events 
    where event='addToShoppingcart' 
    and dt between convert(date,getdate() -90) and convert(date,getdate() -1)
    and  isnumeric(op_code)=1
    group by op_code --commodity_sku
) as tt on t.product_id=tt.op_code
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [cvr]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

select op_code,count(0) as click_cnt
into #click_item_cnt
from STG_Sensor.V_Events 
where event='viewCommodityDetail' and dt between convert(date,getdate() -90) and convert(date,getdate() -1)
and  isnumeric(op_code)=1
and op_code<>'0'
and op_code is not null
group by op_code


select item_product_id,count(distinct sales_order_number) order_cn
into #sales_item_cnt
from DA_Tagging.sales_order_vb_temp
where convert(date, place_time)  between convert(date,getdate() -90) and convert(date,getdate() -1) 
and item_product_id<>'0'
and store=N'丝芙兰官网'
and item_product_id is not null
group by item_product_id



update DA_Tagging.product
set cvr = tt.cvr
from DA_Tagging.product t
join (
    select t1.item_product_id ,  convert(float,t1.order_cn)/convert(float,(case when click_cnt<>0 then click_cnt else null end)) as cvr--0913新增
    from #sales_item_cnt t1 
	left outer join  #click_item_cnt t2 on convert(nvarchar(255),t1.item_product_id) = convert(nvarchar(255),t2.op_code) 
)tt on t.product_id=tt.item_product_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [recruitment_member],[recruitment_sales]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.product
set recruitment_member = tt.recruitment_member,
    recruitment_sales = tt.recruitment_sales
from DA_Tagging.product t
join(
	select item_sku_cd
	, count(distinct t1.sales_member_id) as recruitment_member
	, sum(item_apportion_amount) as recruitment_sales
	from(
	    select item_sku_cd, sales_member_id, item_apportion_amount, sales_order_number
	    from(
	        select item_sku_cd, sales_member_id,item_apportion_amount,sales_order_number
	        ,row_number() over(partition by sales_member_id order by place_time) as rn
	        from DA_Tagging.sales_order_vb_temp 
	        where item_product_id<>0 and store = N'丝芙兰官网'
	        )t1 where rn=1
	)t1 group by item_sku_cd
) as tt on t.sku_cd=tt.item_sku_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [repurchse_member],[repurchse_order],[repurchse_sales]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set repurchse_member = tt.repurchase_member_cnt,
    repurchse_order = tt.repurchase_order_cnt,
    repurchse_sales = tt.repurchase_sales
from DA_Tagging.product t
join (
    select item_sku_cd,count(distinct t2.sales_member_id) as repurchase_member_cnt
        ,count(distinct t2.sales_order_number) as repurchase_order_cnt
        ,sum(product_amount) as repurchase_sales
    from(
        select distinct item_sku_cd,sales_member_id,item_apportion_amount,sales_order_number
        from DA_Tagging.sales_order_sku_temp
        where convert(date, place_time) between convert(date,getdate() -30) and convert(date,getdate() -1) )t1
    join (
        select sales_order_number,product_amount,sales_member_id
        from(
            select sales_order_number,sales_member_id,product_amount,row_number() over(partition by sales_member_id order by place_time) as rn
            from DA_Tagging.sales_order_basic_temp
            where convert(date, place_time) between convert(date,getdate() -360) and convert(date,getdate() -1) )t1
        where rn>1
        )t2 on t1.sales_order_number=t2.sales_order_number and t1.sales_member_id=t2.sales_member_id
    group by item_sku_cd
) as tt on t.sku_cd=tt.item_sku_cd
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [subcategory_share],[function_share]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set subcategory_share = tt.subcategory_share,
    function_share = tt.function_share
from DA_Tagging.product t
join (
    select item_sku_cd
    ,sales*1.0 /subcategory_sales as subcategory_share
    ,sales*1.0 /function_sales as function_share
    from(
        select item_sku_cd,sum(item_apportion_amount) as sales
        from DA_Tagging.sales_order_sku_temp
        where convert(date, place_time) between convert(date,getdate() -180) and convert(date,getdate() -1)
        group by item_sku_cd)t1
    left outer join(
        select sku_code,subcategory,case when skincare_function_basic is not null then skincare_function_basic else makeup_function end as productfunction
        from DA_Tagging.coding_sephoraproductlist 
        )t2 on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS= t2.sku_code collate Chinese_PRC_CS_AI_WS
    left outer join(
        select t2.subcategory,sum(item_apportion_amount) as subcategory_sales
        from(
            select item_sku_cd,item_apportion_amount
            from DA_Tagging.sales_order_sku_temp
            where convert(date, place_time) between convert(date,getdate() -180) and convert(date,getdate() -1) 
            )t1 
        left outer join DA_Tagging.coding_sephoraproductlist t2 on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS= t2.sku_code collate Chinese_PRC_CS_AI_WS
        group by t2.subcategory
        )t3 on t2.subcategory=t3.subcategory
    left outer join(
        select t2.productfunction,sum(item_apportion_amount) as function_sales
        from(
            select item_sku_cd,item_apportion_amount
            from DA_Tagging.sales_order_sku_temp
            where convert(date, place_time) between convert(date,getdate() -180) and convert(date,getdate() -1) 
            )t1 
        left outer join(
            select sku_code
                ,case when skincare_function_basic is not null then skincare_function_basic else makeup_function end as productfunction
            from DA_Tagging.coding_sephoraproductlist)t2 on t1.item_sku_cd collate Chinese_PRC_CS_AI_WS= t2.sku_code collate Chinese_PRC_CS_AI_WS
        group by t2.productfunction
        )t4 on t2.productfunction=t4.productfunction
    ) as tt on t.sku_cd=tt.item_sku_cd
    ;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [basket_penetration],[total_revenue_share]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set basket_penetration = tt.basket_penetration,
    total_revenue_share = tt.total_renenue_share
from DA_Tagging.product t
join (
    select item_sku_cd,sales_order_cnt*1.0 /total_order_cnt as basket_penetration
        ,sales*1.0 /total_order_sales as total_renenue_share
    from(
        select item_sku_cd,count(distinct sales_order_number) as sales_order_cnt,sum(item_apportion_amount) as sales
        from DA_Tagging.sales_order_sku_temp
        where convert(date, place_time) between convert(date,getdate() -180) and convert(date,getdate() -1)
        group by item_sku_cd
        )t1
    cross join(
        select count(distinct sales_order_number) as total_order_cnt,sum(product_amount) as total_order_sales
        from DA_Tagging.sales_order_basic_temp
        where convert(date, place_time) between convert(date,getdate() -180) and convert(date,getdate() -1) 
		)t2
) as tt on t.sku_cd=tt.item_sku_cd
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product [season_share]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.product
set season_share = tt.season_share
from DA_Tagging.product t
join (
    select item_sku_cd,season_sales*1.0 /season_total_sales as season_share
    from(
        select item_sku_cd,DATENAME(QUARTER,place_time) as season,sum(item_apportion_amount) as season_sales
        from DA_Tagging.sales_order_sku_temp
        where convert(date, place_time) between convert(date,getdate() -180) and convert(date,getdate() -1)
        group by item_sku_cd,DATENAME(QUARTER,place_time))t1
    left outer join(
        select season,sum(product_amount) as season_total_sales
        from(
            select DATENAME(QUARTER,place_time) as season,product_amount
            from DA_Tagging.sales_order_basic_temp
            where convert(date, place_time) between convert(date,getdate() -180) and convert(date,getdate() -1) 
            )t 
        group by season)t2 on t1.season=t2.season
) as tt on t.sku_cd=tt.item_sku_cd            
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product Model Tag Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

update DA_Tagging.product
            set target_customer_status = tt2.prod_status
                ,target_customer_card_type = tt2.prod_card
                ,omni_channel_product_role = tt2.prod_omni
                ,online_product_role = tt2.prod_online
                ,target_customer = tt2.prod_group
                ,uv_value_segment = tt2.prod_uv
                ,combo_effectiveness = tt2.prod_combo
            from DA_Tagging.product tt1
            join(
                select item_sku_cd
                ,max(case when model_type='online' then model_res else null end) as prod_online
                ,max(case when model_type='omni' then model_res else null end) as prod_omni
                ,max(case when model_type='status' then model_res else null end) as prod_status
                ,max(case when model_type='combo' then model_res else null end) as prod_combo
                ,max(case when model_type='uv' then model_res else null end) as prod_uv
                ,max(case when model_type='group' then model_res else null end) as prod_group
                ,max(case when model_type='card' then model_res else null end) as prod_card
                from(
                    select item_sku_cd,model_type
                    ,case  when model_res='brand_new_to_eb' then N'BRAND_NEW' 
                        when model_res='convert_new_to_eb' then N'CONVERT_NEW' 
                        when model_res='existing_eb' then N'RETURN' 
                        when model_res='bundle_order_sales_pro' then N'套装' 
                        when model_res='non_bundle_order_sales_pro' then N'单品' 
                        when model_res='l_uv_pro' then N'高' 
                        when model_res='m_uv_pro' then N'中' 
                        when model_res='h_uv_pro' then N'低' 
                        when model_res='fragrance1_pro' then N'香水用户' 
                        when model_res='wellness1_pro' then N'健康饮品用户' 
                        when model_res='makeup1_pro' then N'彩妆新手' 
                        when model_res='makeup2_pro' then N'彩妆成熟用户' 
                        when model_res='skincare1_pro' then N'护肤新手' 
                        when model_res='skincare2_pro' then N'护肤成熟用户' 
                        when model_res='first_purchase_sales' then N'招新' 
                        when model_res='hotlist_sales' then N'热卖' 
                        when model_res='crm_growth_month' then N'近期飙升' 
                        when model_res='online_growth_month' then N'近期飙升' 
                        when model_res='re_purchase_sales' then N'回购' 
                        when model_res='stock_sales' then N'囤货' 
                        when model_res='view_pv' then N'人气' 
                        when model_res='non_sales' then N'Non Member' 
                        when model_res='gold_sales' then N'Gold' 
                        when model_res='pink_sales' then N'Pink' 
                        when model_res='black_sales' then N'Black' 
                        when model_res='white_sales' then N'White' end as model_res
                    from DA_Tagging.prod_model
                )tt
                group by item_sku_cd
            )tt2 on tt1.sku_cd = tt2.item_sku_cd collate Chinese_PRC_CS_AI_WS

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Product','Tagging System Product, Generate Product Tag  End',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;


END
GO
