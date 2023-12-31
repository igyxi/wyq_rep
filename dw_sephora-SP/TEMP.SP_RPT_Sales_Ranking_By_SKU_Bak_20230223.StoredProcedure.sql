/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_Ranking_By_SKU_Bak_20230223]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_Ranking_By_SKU_Bak_20230223] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-10-17       wangzhichun        change sku table
-- ========================================================================================
truncate table [DW_OMS].[RPT_Sales_Ranking_By_SKU];
insert into [DW_OMS].[RPT_Sales_Ranking_By_SKU]
select
    place_date,
	item_name,
	item_sku_cd,
	item_category,
	item_brand_name,
	item_brand_type,
	range_name,
	segment,
	ranking,
	lead(ranking,1) over (partition by item_name,item_sku_cd,item_category,item_brand_name,item_brand_type,range_name,segment order by b.place_date desc) - ranking as change,
	item_quantity,
	item_apportion_amount,
	round(item_apportion_amount/amount_by_dt,2) as item_apportion_amount_weight,
    current_timestamp as insert_timestamp
from
(
	select 
        place_date,
		item_name,
		item_sku_cd,
		item_category,
		item_brand_name,
		item_brand_type,
		range_name,
		segment,
		RANK() over (partition by place_date order by item_apportion_amount desc) as ranking,
		item_quantity as item_quantity,
		item_apportion_amount as item_apportion_amount,
		sum(item_apportion_amount) over(partition by place_date) as amount_by_dt
	from 
	(
        select 
            place_date,
			item_name,
			item_sku_cd,
			item_category,
			item_brand_name,
			item_brand_type,
			range_name,
			segment,
			sum(item_quantity) as item_quantity,
			sum(item_apportion_amount) as item_apportion_amount
		from 
		(
			select 
                place_date,
                dsm.eb_sku_name_cn as item_name,
                vb.item_sku_cd,
				vb.item_level1_name as item_category,
				coalesce(br.brand_rename,vb.item_brand_name) as item_brand_name,
				vb.item_brand_type,
				dsm.range as range_name,
				dsm.segment,
				vb.item_quantity,
				round(vb.item_apportion_amount,2) as item_apportion_amount
			from 
            (
                select 
                    place_date,
                    item_sku_cd,
                    item_level1_name,
                    item_brand_name,
                    item_brand_type,
                    item_quantity,
                    item_apportion_amount
                from 
                    DW_OMS.RPT_Sales_Order_VB_Level 
                where 
                    is_placed_flag= 1 
                and 
                    store_cd = 'S001'
            ) vb
			left join 
				DWD.DIM_SKU_Info dsm 
			on 
				dsm.sku_code = vb.item_sku_cd
			left join 
				DW_Product.DIM_Brand_Rename br
			on 
				dsm.eb_brand_name = br.brand_name 
				
		) a
		group by 
            place_date,
			item_name,
			item_sku_cd,
			item_category,
			item_brand_name,
			item_brand_type,
			range_name,
			segment
	) t
) b
;
END
GO
