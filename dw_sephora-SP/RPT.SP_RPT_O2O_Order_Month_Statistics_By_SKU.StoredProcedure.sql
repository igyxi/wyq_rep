/****** Object:  StoredProcedure [RPT].[SP_RPT_O2O_Order_Month_Statistics_By_SKU]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_O2O_Order_Month_Statistics_By_SKU] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description      version
-- ----------------------------------------------------------------------------------------
-- 2021-12-08       houshuangqiang   O2O 月报统计    Initial Version
-- 2021-12-09       houshuangqiang   O2O 月报统计    update logic
-- 2021-12-13       houshuangqiang   O2O 月报统计    delete column
-- 2021-12-15       houshuangqiang   O2O 月报统计    update sku_type logic
-- 2021-12-28       houshuangqiang   O2O 月报统计    update statistical logic
-- 2023-01-16       litao            O2O 月报统计    update statistical logic
-- 2023-03-29       lizeyuan         O2O 月报统计    update source table
-- ========================================================================================
delete from RPT.RPT_O2O_Order_Month_Statistics_By_SKU where format(dt, 'yyyy-MM') = format(@dt, 'yyyy-MM');
insert into RPT.RPT_O2O_Order_Month_Statistics_By_SKU
select  o.statistics_month
        ,case when upper(channel.code) = 'DAZHONGDIANPING' then 'DIANPING'
              when upper(channel.code) = 'JINGDONGDAOJIA' then 'JDDJ'
              else upper(channel.code)
        end as channel_code
        ,channel.name as channel_name
        ,o.store_code
        ,o.store_name
        --,store.province
        --,store.city,
        ,o.city
        --,store.district
        ,o.sku_code
        ,o.sku_name
        --,o.sku_type
        --,case when o.sku_type = '1' then N'普通商品'
        --      when o.sku_type = '5' then N'赠品'
        --      when o.sku_type = '6' then N'套装'
        --      when o.sku_type = '7' then N'换购商品'
        --      when o.sku_type = '8' then N'门店普通商品'
        --      when o.sku_type = '9' then N'门店VB商品'
        --      when o.sku_type = '10' then N'门店GWP商品'
        -- end as sku_type_name
        --,o.brand_code
        --,brand.name as brand_name
		,o.brand_name
		,o.category_code
		,category.name as category_name
        ,o.original_price
--        ,o.avg_price
        ,o.price as avg_price
        ,o.sales_quantity
        ,o.sales_amount
        ,concat(format(@dt, 'yyyy-MM'),'-01') as dt
        --,@dt as dt
        ,current_timestamp as insert_timestamp
from
(
    select  format(bill_date, 'yyyy-MM') as statistics_month
            ,platform_id
            ,shop_code as store_code
            ,shop_name as store_name
            ,replace(city,N'市','') as city
            ,sku_code
            ,sku_name
            ,category_code
			,brand_code as brand_name
            ,original_price
            ,round(sum(price_total)/sum(qty),2,1) as price
			,sum(qty) as sales_quantity
			,sum(price_total) as sales_amount
    from    ODS_OMS_Order.OMNI_Order_Month_Statistics
    where   format(bill_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
    and     qty >= 1
    and     is_synt is null
    group   by format(bill_date, 'yyyy-MM'),platform_id,shop_code,shop_name,sku_code,sku_name,brand_code,category_code,original_price,city
    union   all
    select  format(bill_date, 'yyyy-MM') as data_dt
            ,platform_id
            ,shop_code as store_code
            ,shop_name as store_name
            ,replace(city,N'市','') as city
            ,sku_code
            ,sku_name
            ,category_code
			,brand_code as brand_name
            ,original_price
            ,round(sum(price_total)/sum(qty),2,1) as price
			,sum(qty) as sales_quantity
			,sum(price_total) as sales_amount
    from    ODS_OMS_Order.OMNI_Order_Month_Statistics
    where   format(bill_date, 'yyyy-MM') = format(@dt, 'yyyy-MM')
    and     qty <= -1
    and     is_synt is null
    group   by format(bill_date, 'yyyy-MM'),platform_id,shop_code,shop_name,sku_code,sku_name,brand_code,category_code,original_price,city
) o
left    join ODS_OIMS_System.SYS_Dict_Detail channel
on      o.platform_id = channel.id
left    join ODS_OIMS_Goods.GDS_CategoryTree category
on      o.category_code = category.code
;
END
GO
