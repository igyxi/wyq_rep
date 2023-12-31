/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_OMS_Sales_Order_With_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_OMS_Sales_Order_With_SKU] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       houshuangqiang     Initial Version
-- 2023-02-16       houshuangqiang     update OMS_STD_Trade main table
-- 2023-04-12       houshuangqiang     add column
-- 2023-04-20       houshuangqiang     add column joint_order_number & item_sale_price
-- 2023-04-24       zeyuan             修改主题域
-- 2023-05-08       houshuangqiang     add STG_Order.Order
-- 2023-05-16       houshuangqiang     add TRP001
-- 2023-05-18       houshuangqiang     add address mapping
-- 2023-06-05       houshuangqiang     add po_order_status
-- 2023-06-05       wangzhichun        update province、city、district
-- 2023-06-14       houshuangqiang     add trade_from 排除O2O中的订单数据 & add sys_create_time/sys_update_time
-- 2023-06-26       houshuangqiang     change STG_Order schema to ODS_Order schema
-- 2023-06-27 		houshuangqiang 	   update logic
-- ========================================================================================

truncate table DW_OMS_Order.DW_OMS_Sales_Order_With_SKU;
with po_order as
(
    select  o.source_bill_no as sales_order_number
            ,o.bill_no as purchase_order_number
            ,o.bill_no as invoice_no
            ,o.pos_invoice_id as invoice_id
            ,o.front_order_type as type_code
            ,item.activity_type as sub_type_code
            ,o.member_card_no as member_card
            ,case when o.member_level_name = 'GOLDEN' then 'GOLD' else o.member_level_name end as member_card_grade
            ,case when o.pay_state = 0 then N'支付状态'
                  when o.pay_state = 1 then N'部分付款'
                  when o.pay_state = 2 then N'已付款'
             end as payment_status
            ,case when o.distribution_state = 0 then N'待预检'
                  when o.distribution_state = 1 then N'等待适配快递'
                  when o.distribution_state = 2 then N'等待下发仓'
                  when o.distribution_state = 3 then N'发货异常挂起'
                  when o.distribution_state = 6 then N'已发货'
                  when o.distribution_state = 8 then N'已签收'
                  when o.distribution_state = 9 then N'已作废'
                  when o.distribution_state = 10 then N'取消'
                  when o.distribution_state = 11 then N'异常'
                  when o.distribution_state = 12 then N'等待路由'
                  when o.distribution_state = 13 then N'订单待下发'
                  when o.distribution_state = 14 then N'等待仓库处理'
                  when o.distribution_state = 15 then N'缺货'
                  when o.distribution_state = 16 then N'拒收'
            end as order_status
            ,item.item_sku_code
            ,null as item_sku_name
            ,sum(item.item_quantity) as item_quantity
            ,max(item.item_sale_price) as item_sale_price
            ,sum(item.item_apportion_amount) + sum(item.item_discount_amount) as item_total_amount
            ,sum(item.item_apportion_amount) as item_apportion_amount
            ,sum(item.item_discount_amount) as item_discount_amount
            ,max(item.virtual_sku_code) as virtual_sku_code
			--,item.virtual_sku_code
            ,o.delivery_time as shipping_time
            ,o.express_fee as shipping_amount
            ,o.push_pos_time as pos_sync_time
            ,o.push_pos as pos_sync_status     -- 推送pos 0-待推送，1-推送成功，2-推送失败
            ,o.data_create_time as sys_create_time
            ,o.data_update_time as sys_update_time
    from    ODS_OMS_Order.OMS_Retail_Order_Bill o
    left    join
    (
        select  retail_order_bill_id
                ,activity_type
                ,sum(qty) as item_quantity
                ,max(price) as item_sale_price
                ,sku_code as item_sku_code
                ,sum(share_payment) as item_apportion_amount
                ,sum(coalesce(merchant_discount_fee, 0)  + coalesce(platform_discount_fee, 0)) as item_discount_amount
                ,max(vb_code) as virtual_sku_code
        from    ODS_OMS_Order.OMS_Retail_Goods_Detalis
        group   by retail_order_bill_id,sku_code,activity_type
        union   all
        select  id as retail_order_bill_id
                ,activity_type
                ,1 as item_quantity
                ,0 as item_sale_price
                --,0 as amount
                ,'TRP001' as item_sku_code
                ,express_fee as item_apportion_amount
                ,0 as item_discount_amount
                ,null as virtual_sku_code
        from    ODS_OMS_Order.OMS_Retail_Order_Bill
        where   front_order_type <> 2
        and     express_fee > 0
        and     is_plit <> '1'
        and     distribution_state <> '9'
    ) item
    on      o.id = item.retail_order_bill_id
    where   o.is_plit <> '1'
    and     o.front_order_type <> 2
    and     o.distribution_state <> '9'
    group     by o.source_bill_no,o.bill_no,o.bill_no,o.pos_invoice_id,o.front_order_type,o.member_card_no,o.activity_type,
                case when o.member_level_name = 'GOLDEN' then 'GOLD' else o.member_level_name end, --item.virtual_sku_code
                case when o.pay_state = 0 then N'支付状态' when o.pay_state = 1 then N'部分付款' when o.pay_state = 2 then N'已付款' end,
                case when o.distribution_state = 0 then N'待预检'
                  when o.distribution_state = 1 then N'等待适配快递'
                  when o.distribution_state = 2 then N'等待下发仓'
                  when o.distribution_state = 3 then N'发货异常挂起'
                  when o.distribution_state = 6 then N'已发货'
                  when o.distribution_state = 8 then N'已签收'
                  when o.distribution_state = 9 then N'已作废'
                  when o.distribution_state = 10 then N'取消'
                  when o.distribution_state = 11 then N'异常'
                  when o.distribution_state = 12 then N'等待路由'
                  when o.distribution_state = 13 then N'订单待下发'
                  when o.distribution_state = 14 then N'等待仓库处理'
                  when o.distribution_state = 15 then N'缺货'
                  when o.distribution_state = 16 then N'拒收'
            end,
    item.item_sku_code,o.delivery_time,o.express_fee,o.push_pos_time,o.push_pos,item.activity_type,o.data_create_time,o.data_update_time


),

-- 获取发货仓
warehouse as
(
    select  addr.purchase_order_number
            ,delivery.name as logistics_company
            ,addr.logistics_number
            ,def_warehouse.code as def_warehouse
            ,real_warehouse.code as actual_warehouse
    from
    (
         select bill_no as purchase_order_number
                ,delivery_type_id
                ,trim(delivery_no) as logistics_number
                ,ware_house_default_id
                ,ware_house_real_id
        from    ODS_OMS_Order.ORD_Retail_ORD_DIS_Info
        group   by bill_no,delivery_type_id,delivery_no,ware_house_default_id,ware_house_real_id
    ) addr
    left    join ODS_OIMS_Support.Bas_Delivery_Type delivery
    on      addr.delivery_type_id = delivery.id
    and     delivery.status = '09'
    left    join ODS_OIMS_Support.Bas_Warehouse def_warehouse
    on      addr.ware_house_default_id = def_warehouse.id
    left    join ODS_OIMS_Support.Bas_Warehouse real_warehouse
    on      addr.ware_house_real_id = real_warehouse.id
)

insert into DW_OMS_Order.DW_OMS_Sales_Order_With_SKU
select  so.sales_order_number
        ,so.joint_order_number
        ,po.purchase_order_number
        ,po.invoice_no -- 这里可能也需要像O2O那样转换，历史数据和新数据从不同的地方取值
        -- ,po.purchase_order_number as invoice_no
        ,po.invoice_id
        ,so.channel_code
        ,so.channel_name
        ,so.sub_channel_code
        ,so.sub_channel_name
        ,store.store_code
        ,so.province
        ,so.city
        ,so.district
        ,coalesce(po.type_code, so.[type]) as type_code
        ,po.sub_type_code
        ,so.member_id
        ,so.member_card
        ,coalesce(po.member_card_grade, so.member_card_grade) as member_card_grade
        ,so.payed_amount as payment_amount
        ,so.payment_status
        ,so.order_status as so_order_status
        ,po.order_status as po_order_status
        ,so.order_time
        ,so.payment_time
        ,so.is_placed
        ,so.place_time
        ,so.smartba_flag
        ,po.item_sku_code
        ,po.item_sku_name
        ,po.item_quantity
        ,po.item_sale_price
        ,po.item_total_amount
        ,po.item_apportion_amount
        ,po.item_discount_amount
        ,item.virtual_sku_code
        ,item.virtual_quantity
        ,item.virtual_apportion_amount
        ,item.virtual_discount_amount
        ,warehouse.logistics_company
        ,warehouse.logistics_number
        ,po.shipping_time
        ,po.shipping_amount
        ,warehouse.def_warehouse
        ,warehouse.actual_warehouse
        ,po.pos_sync_time
        ,po.pos_sync_status
        ,po.sys_create_time
        ,po.sys_update_time
        ,current_timestamp as insert_timestamp
from    DW_OMS_Order.DW_OMS_Sales_Order so
left    join po_order po
on      so.sales_order_number = po.sales_order_number
left    join
(
    select  tid as sales_order_number
            ,outer_sku_id as virtual_sku_code
            ,sum(num) as virtual_quantity
            ,sum(divide_order_fee) as virtual_apportion_amount
            ,sum(discount_fee) as virtual_discount_amount
    from    ODS_OMS_Order.OMS_STD_Trade_Item
    where   substring(outer_sku_id, 1,1) = 'V'
    group   by tid,outer_sku_id
) item
on      so.sales_order_number = item.sales_order_number
and     po.virtual_sku_code = item.virtual_sku_code
left    join warehouse
on      po.purchase_order_number = warehouse.purchase_order_number
left    join ODS_OMS_Order.OMS_Store_Mapping store
on      so.store_id = store.store_id
and     warehouse.actual_warehouse = store.warehouse
;
END;

GO
