/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sensor_PDP_Performance_Bak_20230526]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sensor_PDP_Performance_Bak_20230526] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-22       wubin          update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2022-11-09       wangzhichun    update PLATFORM_TYPE & PAGE_ID
-- 2022-09-22       wubin          update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2022-11-09       wangzhichun    update PLATFORM_TYPE
-- 2022-11-17       houshuangqiang add field category1 label
-- 2022-11-30       houshuangqiang add field category2 label
-- 2023-02-23       wangzhichun    update source table
-- 2023-04-10       houshuangqiang update logic
-- ========================================================================================
delete from DW_Sensor.RPT_Sensor_PDP_Performance where dt = @dt;
with sales_op as
(
    select
        vb.product_id as product_id,
        vb.channel_id as channel_id,
        vb.place_date as place_date,
        count(distinct sales_order_number) as orders,
        round(sum(vb.item_apportion_amount),2) as apportion_amount,
        sum(vb.item_quantity) as item_quantity,
        count(distinct vb.member_id) as users_number
    from
    (
        select
            sales_order_number,
            item_product_id as product_id,
            case
                when sub_channel_code in ('APP','APP(ANDROID)','APP(IOS)') then 'APP'
                when sub_channel_code in ('ANNYMINIPROGRAM','BENEFITMINIPROGRAM','MINIPROGRAM') then 'MNP'
                when sub_channel_code = 'WCS' then 'PC'
                when sub_channel_code = 'WECHAT' then 'MOBILE'
            else upper(sub_channel_code)
            end as channel_id,
            place_date,
            member_id,
            item_apportion_amount,
            item_quantity
        from
            -- DW_OMS.RPT_Sales_Order_VB_Level
            RPT.RPT_Sales_Order_VB_Level
        where
            is_placed = 1
        and channel_code = 'SOA'
        and place_date = @dt
        and sub_channel_code in ('APP','APP(ANDROID)','APP(IOS)','MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','MOBILE','PC','WCS','WECHAT')
    ) vb
    group by
        vb.product_id,
        vb.channel_id,
        vb.place_date
)

insert into DW_Sensor.RPT_Sensor_PDP_Performance
select	cast(pv.dt as varchar(7)) as statics_month,
		pv.dt as DATE,
		pv.product_id as op_code,
		coalesce(pv.product_name_cn, 'NO DETAIL') as product_name_cn,
		coalesce(brand.brand_rename, pv.brand_name, 'NO DETAIL') as brand_name_en,
		coalesce(pv.category, 'NO DETAIL') as category,
		coalesce(pv.brand_type, 'NO DETAIL') as brand_type,
		pv.category1_level1_id,
		pv.category1_level1_name,
		pv.category1_level2_id,
		pv.category1_level2_name,
		pv.category1_level3_id,
		pv.category1_level3_name,
		pv.category2_level1_id,
		pv.category2_level1_name,
		pv.category2_level2_id,
		pv.category2_level2_name,
		pv.category2_level3_id,
		pv.category2_level3_name,
		pv.platform_type,
		pv.pv,
		pv.uv,
		coalesce(so.orders,0),
		coalesce(so.apportion_amount,0) as apportion_amount,
		coalesce(so.item_quantity,0) as item_quantity,
		coalesce(so.users_number,0) as users_number,
		current_timestamp as insert_timestamp,
		@dt as dt
from 
(
	select	sku.eb_product_name_cn as product_name_cn,
            sku.eb_brand_name as brand_name,
            sku.eb_category as category,
            sku.eb_brand_type as brand_type,
            sku.eb_level1_id as category1_level1_id,
            sku.eb_level1_name as category1_level1_name,
            sku.eb_level2_id as category1_level2_id,
            sku.eb_level2_name as category1_level2_name,
            sku.eb_level3_id as category1_level3_id,
            sku.eb_level3_name as category1_level3_name,
            sku.eb_category2_level1_id as category2_level1_id,
            sku.eb_category2_level1_name as category2_level1_name,
            sku.eb_category2_level2_id as category2_level2_id,
            sku.eb_category2_level2_name as category2_level2_name,
            sku.eb_category2_level3_id as category2_level3_id,
            sku.eb_category2_level3_name as category2_level3_name,
			count(page.user_id) as pv,
			count(distinct page.user_id) as uv,
			case when upper(page.platform_type) = 'MINIPROGRAM' then 'MNP'
				 when upper(page.platform_type) = 'WEB' then 'PC'
				 else upper(page.platform_type) 
			end as platform_type,
			product_id,
			page.dt		
	from 	[DW_Sensor].[DWS_Product_Detail_Page_View] page
	left 	join DWD.DIM_SKU_Info sku 
	on 		page.sku_id = sku.eb_sku_id 
	where 	page.dt = @dt 
	group 	by 	sku.eb_product_name_cn,
				sku.eb_brand_name,
				sku.eb_category,
				sku.eb_brand_type,
				sku.eb_level1_id,
				sku.eb_level1_name,
				sku.eb_level2_id,
				sku.eb_level2_name,
				sku.eb_level3_id,
				sku.eb_level3_name,
				sku.eb_category2_level1_id,
				sku.eb_category2_level1_name,
				sku.eb_category2_level2_id,
				sku.eb_category2_level2_name,
				sku.eb_category2_level3_id,
				sku.eb_category2_level3_name,
				page.dt,
				page.product_id,
				case when upper(page.platform_type) = 'MINIPROGRAM' then 'MNP'
				     when upper(page.platform_type) = 'WEB' then 'PC'
				     else upper(page.platform_type) 
			    end
) pv 
left 	join DW_Product.DIM_Brand_Rename brand
on		pv.brand_name = brand.brand_name
left 	join sales_op so
on		pv.product_id = so.product_id
and		pv.platform_type = so.channel_id			
;
END




GO
