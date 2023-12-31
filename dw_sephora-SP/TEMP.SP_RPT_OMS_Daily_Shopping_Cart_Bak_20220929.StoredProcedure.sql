/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Daily_Shopping_Cart_Bak_20220929]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Daily_Shopping_Cart_Bak_20220929] @dt [VARCHAR](10) AS
BEGIN
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
    @dt as dt,
    current_timestamp as insert_timestamp
from
(
	select 
		a.sku_cd as sku_code,
		a.main_cd as main_sku_code,
		a.sku_name_cn as item_name,
		coalesce(br.brand_rename,a.brand_name) as brand_name,
		a.category as category_name,
		a.brand_type as brand_type,
		a.segment as segment,
		a.range_name as [range],
        a.sap_price as sap_price,
		b.user_id as user_id,
		b.change_num as quantity,
		b.dt as day_id,
        --regexp_replace(substring(b.dt,1,7),'-','') as month_id
        REPLACE(CONVERT(varchar(10), substring(b.dt,1,7), 20), '-', '') as month_id
	from 
		(select 
			* 
		from 
			[STG_ShopCart].[Cart_Flow]
		where 
			dt = @dt
			and store = 'EB' 
            and type <> 3
		) b 
	left join 
		[DW_Product].[DWS_SKU_Profile] a 
	on 
		a.sku_id = b.sku_id
	left join 
		[DW_Product].[DIM_Brand_Rename] br
	on 
		a.brand_name = br.brand_name
	left join
	    [STG_ShopCart].[Cart_Pressure_Test_UserList] t
	on 
	    b.user_id = t.user_id
	where
	    t.user_id is null
)a 
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
