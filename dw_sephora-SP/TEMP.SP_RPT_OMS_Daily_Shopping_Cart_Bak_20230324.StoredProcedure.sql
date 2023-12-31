/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Daily_Shopping_Cart_Bak_20230324]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Daily_Shopping_Cart_Bak_20230324] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-12       Tali           Initial Version
-- 2022-09-26       wubin          update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2023-02-09       wei chen       update 排除sku_code为NULL的数据
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
    @dt as dt,
    current_timestamp as insert_timestamp
from
(
	select 
		a.sku_code as sku_code,
		a.eb_main_sku_code as main_sku_code,
		a.eb_sku_name_cn as item_name,
		coalesce(br.brand_rename,a.eb_brand_name) as brand_name,
		a.eb_category as category_name,
		a.eb_brand_type as brand_type,
		a.eb_segment as segment,
		a.range as [range],
		a.eb_sap_price as sap_price,
		b.user_id as user_id,
		b.change_num as quantity,
		b.dt as day_id,
        REPLACE(CONVERT(varchar(10), substring(b.dt,1,7), 20), '-', '') as month_id
	from 
		(
            select 
			     sku_id
			    ,user_id
			    ,change_num
			    ,dt
			from 
                [STG_ShopCart].[Cart_Flow]
			where 
			    dt = @dt
			and 
                store = 'EB' 
			and 
                type <> 3
		) b 
    left join 
		(
            select 
                   b2.sku_id
                  ,b2.sku_code
            from 
                    (
                      select  sku_id 
                             ,sku_code 
                             ,row_number() over(partition by sku_code order by create_time desc) rownum 
                        from 
			                  STG_Product.PROD_SKU
                    ) b2
            where 
                b2.rownum = 1
        ) b1
	on 	
		b.sku_id = b1.sku_id
	left join 
		DWD.DIM_SKU_Info a
	on  
		a.sku_code = b1.sku_code
	left join 
		[DW_Product].[DIM_Brand_Rename] br
	on 
		a.eb_brand_name = br.brand_name
	left join
	    [STG_ShopCart].[Cart_Pressure_Test_UserList] t
	on 
	    b.user_id = t.user_id
	where
	    t.user_id is null
) a 
where a.sku_code is not null
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
