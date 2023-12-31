/****** Object:  StoredProcedure [TEMP].[SP_RPT_OP_SKU_Traffic_Yesterday_Score_BAK20230428]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OP_SKU_Traffic_Yesterday_Score_BAK20230428] @dt [varchar](10) AS
BEGIN
truncate TABLE DW_Sensor.RPT_OP_SKU_Traffic_Yesterday_Score;
insert into DW_Sensor.RPT_OP_SKU_Traffic_Yesterday_Score
SELECT
    a.sku_id,
    a.sku_cd,
    a.main_cd,
    a.islimit,
    a.issephora,
    a.isnew,
    a.isonline,
    a.ismember,
    a.isprelaunch,
    a.isdiscount,
    a.is_default,
    a.status,
    a.product_id,
    a.product_name,
    a.product_name_cn,
    a.brand_id,
    a.brand_type,
    a.brand_name,
    a.brand_name_cn,
    a.sku_type,
    a.sku_name,
    a.sku_name_cn,
    a.category,
    a.range_name,
    a.segment,
    a.target,
    a.franchise,
    a.first_function,
    a.sale_store,
    a.sale_value,
    a.sap_price,
    a.level1_id,
    a.level2_id,
    a.level3_id,
    a.level1_name,
    a.level2_name,
    a.level3_name,
    a.att_31,
    a.att_32,
    a.att_33,
    a.att_34,
    a.att_35,
    a.att_36,
    a.att_37,
    a.att_38,
    a.att_39,
    a.att_41,
    a.att_42,
    a.att_44,
    a.att_47,
    a.att_48,
    a.att_49,
    a.att_50,
    a.att_51,
    a.att_53,
    a.att_54,
    a.att_60,
    a.att_61,
    a.att_63,
    a.att_66,
    a.att_69,
    a.att_72,
    a.att_75,
    a.att_78,
    a.image,
    a.first_publish_time,
    a.last_publish_time,
    sku_traffic.dt as traffic_date,
    sku_traffic.sku_pv,
    sku_traffic.sku_uv,
    op_traffic.op_pv,
    op_traffic.op_uv,
    c.total_amount,
    c.tr_sequence,
    c.top_or_bottom,
    c.tr_score,
    c.total_sales,
    c.tr_score2,
	d.sku_total_amount,
	d.sku_total_quantity,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DW_Product.DWS_SKU_Profile a
left join
(
    select
        count(1) as sku_pv,
        count(distinct user_id) as sku_uv,
        sku_id,
        dt
    from
        DW_Sensor.DWS_Product_Detail_Page_View 
    where 
        dt=@dt
    group by 
        sku_id,
        dt
) sku_traffic
on 
    a.sku_id = sku_traffic.sku_id
left join
(
    select
        count(1) as op_pv,
        count(distinct user_id) as op_uv,
        product_id
    from
        DW_Sensor.DWS_Product_Detail_Page_View 
    where 
        dt=@dt
    group by 
        product_id
) op_traffic 
on
    a.product_id = op_traffic.product_id
left join
    STG_Product.PROD_Product_Score c
on 
    a.product_id = c.product_id
left join
    (
        select 
	        sum(item_apportion_amount) as sku_total_amount,
	    	sum(item_quantity) as sku_total_quantity,
	    	item_sku_cd
	    from 
	        DW_OMS.RPT_Sales_Order_VB_Level
	    where 
	        place_date >= dateadd(d,-1,@dt)
        and 
            is_placed_flag= 1 
        and 
            store_cd = 'S001'
	    group by 
            item_sku_cd
	)d
on 
    d.item_sku_cd = a.sku_cd;
END
GO
