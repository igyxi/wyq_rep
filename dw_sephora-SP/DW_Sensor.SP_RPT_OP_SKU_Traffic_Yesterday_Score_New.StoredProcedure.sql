/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_OP_SKU_Traffic_Yesterday_Score_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_OP_SKU_Traffic_Yesterday_Score_New] @dt [varchar](10) AS
BEGIN
truncate TABLE DW_Sensor.RPT_OP_SKU_Traffic_Yesterday_Score_New;


with sku_id_att_json as (
select
       sku_id,
       attr_id,
       STRING_AGG(value, ',') as value
   from
   (
       select distinct
           psar.sku_id,
           psar.attr_id,
           pal.value
       from
           STG_Product.PROD_SKU_Attrval_REL psar
       left join
       (
           select * from STG_Product.PROD_Attrval where is_deleted = 0 and is_disable =0
       ) pal
       on psar.attrval_id = pal.id
   ) t
--    where sku_id = 20018
   group by sku_id, attr_id
),


sku_id_att as (
 select sku_id,
        [31] as att_31,
        [32] as att_32,
        [33] as att_33,
        [34] as att_34,
        [35] as att_35,
        [36] as att_36,
        [37] as att_37,
        [38] as att_38,
        [39] as att_39,
        [41] as att_41,
        [42] as att_42,
        [44] as att_44,
        [47] as att_47,
        [48] as att_48,
        [49] as att_49,
        [50] as att_50,
        [51] as att_51,
        [53] as att_53,
        [54] as att_54,
        [60] as att_60,
        [61] as att_61,
        [63] as att_63,
        [66] as att_66,
        [69] as att_69,
        [72] as att_72,
        [75] as att_75,
        [78] as att_78
    from
         sku_id_att_json
       PIVOT(
           max(value) for attr_id in ([31],[32],[33],[34],[35],[36],[37],[38],[39],[41],[42],[44],[47],[48],[49],[50],[51],[53],[54],[60],[61],[63],[66],[69],[72],[75],[78])
    ) as pvt
)

insert into DW_Sensor.RPT_OP_SKU_Traffic_Yesterday_Score_New
SELECT
    a1.sku_id as sku_id,
    a1.sku_code as sku_cd,
    a.eb_main_sku_code as main_cd,
    a1.islimit,
    a1.issephora,
    a1.isnew,
    a1.isonline,
    a1.ismember,
    a1.isprelaunch,
    a1.isdiscount,
    a1.is_default,
    a.eb_status as status,
    a.eb_product_id as product_id,
    a.eb_product_name as product_name,
    a.eb_product_name_cn as product_name_cn,
    a.eb_brand_id as brand_id,
    a.eb_brand_type as brand_type,
    a.eb_brand_name as brand_name,
    a.eb_brand_name_cn as brand_name_cn,
    a.eb_sku_type as sku_type,
    a.eb_sku_name as sku_name,
    a.eb_sku_name_cn as sku_name_cn,
    a.eb_category as category,
    a.range as range_name,
    a.eb_segment as segment,
    a.target,
    a.franchise,
    a.first_function,
    a.eb_sale_store as sale_store,
    a.eb_sale_value as sale_value,
    a.eb_sap_price as sap_price,
    a.eb_level1_id as level1_id,
    a.eb_level2_id as level2_id,
    a.eb_level3_id as level3_id,
    a.eb_level1_name as eb_level1_name,
    a.eb_level2_name as eb_level2_name,
    a.eb_level3_name as eb_level3_name,
    att.att_31,
    att.att_32,
    att.att_33,
    att.att_34,
    att.att_35,
    att.att_36,
    att.att_37,
    att.att_38,
    att.att_39,
    att.att_41,
    att.att_42,
    att.att_44,
    att.att_47,
    att.att_48,
    att.att_49,
    att.att_50,
    att.att_51,
    att.att_53,
    att.att_54,
    att.att_60,
    att.att_61,
    att.att_63,
    att.att_66,
    att.att_69,
    att.att_72,
    att.att_75,
    att.att_78,
    a1.image,
    a.eb_first_publish_time as first_publish_time,
    a.eb_last_publish_time as last_publish_time,
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
--     DW_Product.DWS_SKU_Profile a
    DW_Product.DWS_SKU_Profile_New a1
left join
    dwd.dim_sku_info a
on
    a1.sku_code = a.sku_code
left join 
    sku_id_att att
on
    a1.sku_id = att.sku_id
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
    a1.sku_id = sku_traffic.sku_id
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
    a.eb_product_id = op_traffic.product_id
left join
    STG_Product.PROD_Product_Score c
on 
    a.eb_product_id = c.product_id
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
    d.item_sku_cd = a.sku_code;
END
GO
