/****** Object:  StoredProcedure [DWD].[SP_Fact_EB_Sales_Order_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_EB_Sales_Order_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-05       LeoZhai    Initial Version
-- 2023-06-28       houshuangqiang change to new oms data source
-- ========================================================================================
truncate table DWD.Fact_EB_Sales_Order_New;
insert into DWD.Fact_EB_Sales_Order_New
select
    so.sales_order_sys_id,
    so.sales_order_number,
    so.channel_code,
    so.channel_name,
    so.sub_channel_code,
    so.sub_channel_name,
    so.province,
    so.city,
    so.district,
    so.[type] as order_type,
    so.order_status,
    so.is_placed,
    so.place_time,
    so.place_date,
    so.super_id,
    so.member_id,
    null as open_id,
    so.member_card,
    so.member_card_grade,
    null as member_card_level,
    so.mobile_guid as member_mobile,
    so.order_time,
    format(so.order_time, 'yyyy-MM-dd') as order_date,
    so.payment_status,
    so.payed_amount,
    so.payment_time,
    format(so.payment_time, 'yyyy-MM-dd') as payment_date,
    null as split_flag,
    item.outer_sku_id as item_sku_code,
    item.gift_type as item_type,
    item.title as item_name,
    item.num as item_quantity,
    item.list_price as item_market_price,
	-- item.price as item_market_price,
    item.sales_price as item_sale_price,
    coalesce(item.divide_price,0) + coalesce(item.discount_fee,0) as item_adjustment_unit,
    item.discount_fee as item_adjustment_amount,
    item.divide_price as item_apportion_unit,
    item.divide_order_fee as item_apportion_amount,              
    sku.eb_main_sku_code as item_main_code,
    sku.eb_category as item_category,
    sku.eb_brand_type as item_brand_type,
    trim(sku.eb_brand_name) as item_brand_name,
    trim(sku.eb_brand_name_cn) as item_brand_name_cn,
    trim(sku.eb_level1_name) as item_level1_name,
    trim(sku.eb_level2_name) as item_level2_name,
    trim(sku.eb_level3_name) as item_level3_name,
    sku.eb_product_id as item_product_id,
    null as o2o_shop_cd,
    so.smartba_flag,
    so.ouid,
    current_timestamp as insert_timestamp
from
    DW_OMS_Order.DW_OMS_Sales_Order so
left join
    ODS_OMS_Order.OMS_STD_Trade_Item item
on so.sales_order_number = item.tid
left join
    DWD.DIM_SKU_Info sku
on item.outer_sku_id = sku.sku_code

END
  
GO
