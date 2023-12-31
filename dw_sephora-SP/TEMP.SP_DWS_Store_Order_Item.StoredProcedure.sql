/****** Object:  StoredProcedure [TEMP].[SP_DWS_Store_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Store_Order_Item] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-22       houshuangqiang     New_OMS数据往老的OrderHub.Store_Order_item中写数据，供下游使用。
-- ========================================================================================
truncate table DW_New_OMS.DWS_Store_Order_Item;
insert  into DW_New_OMS.DWS_Store_Order_Item
select  o.id as store_order_item_sys_id
        ,o.retail_order_bill_id as store_order_sys_id
        ,o.app_food_code as app_food_code
        ,sku.code as sku_code
        ,sku.name as sku_name
        ,o.qty as quantity
        ,o.share_price as price
        ,o.market_price as list_price
        ,o.invoice_price_total as invoice_price_total
--        ,sku1.eb_sku_name as description
        ,null as description
        ,o.paid_amount as price_total
--        ,category.name as categroy
--        ,brand.name as brand
        ,sku1.eb_category as category
        ,sku1.eb_brand_name as brand
        ,o.item_type as item_type
        ,o.create_time as create_time
        ,o.modify_time as update_time
        ,o.create_by as create_user
        ,o.modify_by as update_user
        ,null as is_delete -- store_order_item表也全是空值
        ,null as spec
        ,sku.path as main_image -- 需要拼接域名，我这里不知道域名
        ,o.barcode as upc
        ,o.adjustment_price as adjustment_price
        ,null as unique_id
        ,o.amount_discount as adjustment_price_total
        ,o.original_total as original_total
        ,o.status as status
        ,o.is_synt as is_sync
        ,o.surplus_quantity as surplus_quantity
        ,o.surplus_price_total as surplus_price_total
        ,o.surplus_invoice_total as surplus_invoice_total
        ,current_timestamp as insert_timestamp
from    STG_New_OMS.Omni_Retail_Ord_Goods_Detail o
left 	join STG_IMS.Gds_Btsinglprodu sku
on 		o.singleproduct_id = sku.id
left    join DWD.DIM_SKU_Info sku1
on      sku.code = sku1.sku_code
--left 	join STG_IMS.Bas_Brand brand
--on  	o.brand_id = brand.id
--left 	join STG_IMS.gds_btgoods product
--on 		o.goods_id = product.id
--left 	join STG_IMS.gds_categorytree category
--on 		product.categorytreeid = category.id
;
END
GO
