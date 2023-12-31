/****** Object:  StoredProcedure [DW_ShopCart].[SP_RPT_OMS_Daily_Shopping_Cart]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_ShopCart].[SP_RPT_OMS_Daily_Shopping_Cart] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-12       Tali           Initial Version
-- 2022-09-26       wubin          update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2023-02-09       wei chen       update 排除sku_code为NULL的数据
-- 2023-03-28       houshuangqiang change source table to DWD.Fact_Cart_Flow
-- ========================================================================================
delete from [DW_ShopCart].[RPT_OMS_Daily_Shopping_Cart] where dt = @dt;
insert into [DW_ShopCart].[RPT_OMS_Daily_Shopping_Cart]
select
    sku_code,
    main_sku_code,
    item_name,
    brand_name,
    category_name,
    brand_type,
    segment,
    [range],
    sap_price,
    count(distinct user_id) as user_id,
    sum(quantity) as quantity,
    day_id,
    month_id,
    day_id as dt,
    current_timestamp as insert_timestamp
from
(
	select
		sku.sku_code as sku_code,
		sku.eb_main_sku_code as main_sku_code,
		sku.eb_sku_name_cn as item_name,
		coalesce(brand.brand_rename,sku.eb_brand_name) as brand_name,
		sku.eb_category as category_name,
		sku.eb_brand_type as brand_type,
		sku.eb_segment as segment,
		sku.range as [range],
		sku.eb_sap_price as sap_price,
		cart.user_id as user_id,
		cart.change_num as quantity,
		cart.dt as day_id,
        replace(convert(varchar(10), substring(cart.dt,1,7), 20), '-', '') as month_id
	from
	(
            select  sku_id
					,sku_code
                    ,user_id
                    ,change_num
                    ,cast(dt as nvarchar(10)) as dt
			from    DWD.Fact_Cart_Flow
			where	dt = @dt
			and		store_code = 'EB'
			and		change_type <> 3
	) cart
	left join DWD.DIM_SKU_Info sku
	on	cart.sku_code = sku.sku_code
	left join [DW_Product].[DIM_Brand_Rename] brand
	on	sku.eb_brand_name = brand.brand_name
	left join [STG_ShopCart].[Cart_Pressure_Test_UserList] t
	on cart.user_id = t.user_id
	where t.user_id is null
) p
where sku_code is not null
group by
    sku_code,
    main_sku_code,
    item_name,
    brand_name,
    category_name,
    brand_type,
    segment,
    [range],
	sap_price,
    day_id,
    month_id
;
end
GO
