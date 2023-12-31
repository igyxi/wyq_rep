/****** Object:  StoredProcedure [TEMP].[SP_DW_OMS_Sales_Order_With_SKU_Bak_20230505]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_OMS_Sales_Order_With_SKU_Bak_20230505] AS
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
-- ========================================================================================
truncate table DW_OMS_Order.DW_OMS_Sales_Order_With_SKU;
with so_order as
(
    select  so.tid as sales_order_number
            ,so.merge_no as joint_order_number
            ,so.bill_no as purchase_order_number
            ,case when upper(so.platform) = 'TAOBAO' then 'TMALL'
                  when upper(so.platform) = 'JINGDONG' then 'JD'
                  when upper(so.platform) = 'douyinxiaodian' then 'DOUYIN'
                  else upper(so.platform) end as channel_code -- 需要在字典表中把淘宝改成天猫
            ,case when channel.name = N'淘宝' then N'天猫'
                  when channel.name = N'京东商城' then N'京东'
                  when channel.name = N'抖音小店' then N'抖音'
                  when channel.name = N'OFF_LINE' then N'线下'
            	  else channel.name end as channel_name
--            ,so.trade_from as sub_channel_code
--            ,upper(so.shop_code) as sub_channel_code
            ,so.channel_id as sub_channel_code
            ,sub_channel.name as sub_channel_name
            ,so.store_id as store_code
--            ,so.store_number
           -- ,customer_id 用户ID
            ,null as member_id
            ,so.vip_card_no as member_card
            ,null as member_card_grade
            ,so.smart_BA_flag as smartba_flag -- channel_code 为小程序的，需要转成smartba, 等正式数据，看哪些渠道是小程序的
            ,so.created as order_time
            ,so.pay_time as payment_time
            ,so.payment as payment_amount
            ,so.pay_status as payment_status
            ,so.status as order_status
            ,case when so.pay_status = 1 then 1 else 0 end as is_placed
            ,so.pay_time as place_time
            ,relation.tag_id -- 值与老系统的订单类型不相同
            ,tag.code as type_code -- 值与老系统的订单类型不相同
            ,tag.name  -- 值与老系统的订单类型不相同
            ,so.receiver_state as province
            ,so.receiver_city as city
            ,so.receiver_district as district
--            ,post_fee as shipping_amount so 单快递费
    from    ODS_New_OMS.OMS_STD_Trade so
    left    join ODS_OIMS_System.SYS_Dict_Detail channel
    on      so.platform = channel.code
    left    join ODS_OIMS_System.SYS_Dict_Detail sub_channel
    on      so.channel_id = sub_channel.code
    left    join ODS_New_OMS.OMS_Std_Tag_Relation relation
    on      so.tid = relation.tid
    and     so.platform = relation.tid
    left    join ODS_OIMS_Support.Bas_Tag tag
    on      relation.tag_id = tag.id
    where   so.platform not in ('DAZHONGDIANPING', 'JINGDONGDAOJIA', 'MEITUAN', 'NEIMAI')
),

po_order as
(
    select  o.source_bill_no as sales_order_number
            ,o.bill_no as purchase_order_number
            ,invoice.receipt_number as invoice_no
            ,invoice.invoice_id
--            ,pos_invoice_id as invoice_id
           -- ,o.platform_id -- 后面注释掉
            ,case when channel.code = 'jingdong' then 'JD'
                  when channel.code = 'douyinxiaodian' then 'DOUYIN'
                  when channel.code = 'taobao' then 'TMALL'  -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
                  else upper(channel.code)
            end as channel_code
            ,case when channel.name = N'京东商城' then N'京东'
                  when channel.name = N'OFF_LINE' then N'线下'
                  when channel.name = N'抖音小店' then N'抖音'
                  when channel.name = N'淘宝' then N'天猫' -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
                  else channel.name
            end as channel_name
            ,upper(o.trade_from) as sub_channel_code
            ,upper(sub_channel.name) as sub_channel_name
            ,o.store_code
            ,o.order_type as type_code
            ,'' as member_id -- 暂时没有会员id
            ,o.member_card_no as member_card          -- 空值
            ,o.member_level_name as member_card_grade -- 空值
            ,case when o.pay_state = 0 then N'支付状态'
                  when o.pay_state = 1 then N'部分付款'
                  when o.pay_state = 2 then N'已付款'
             end as payment_status
--            ,case when o.status = 0 then N'未确认'
--                  when o.status = 1 then N'已确认'
--                  when o.status = 2 then N'异常'
--                  when o.status = 8 then N'已完成'
--                  when o.status = 9 then N'作废单'
--                  when o.status = 10 then N'取消'
--            end as order_status -- 已弃用
--            ,o.distribution_state -- 0-待预检\n1-等待适配快递 2-等待下发仓 3-发货异常挂起 6-已发货 8-已签收 9-已作废 10-取消 11-异常 12-等待路由 13-订单待下发 14-等待仓库处理 15-缺货 16-拒收
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
            ,o.bill_date as order_time -- 下单时间
            ,o.pay_date as payment_time
            ,case when o.pay_state = 2 then 1 else 0 end as is_placed
            ,o.pay_date as place_time
            ,sku.code as item_sku_code
            ,sku.name as item_sku_name
    --        ,item.outer_sku_id as item_sku_code
            ,item.qty as item_quantity
            ,item.price as item_sale_price
            ,item.amount as item_total_amount
            ,item.share_payment as item_apportion_amount
            ,item.discount as item_discount_amount
            ,item.vb_code as virtual_sku_code
            ,item.vb_qty as virtual_quantity
            ,item.vb_total_amount as virtual_apportion_amount
            ,item.vb_origin_price - item.vb_total_amount as virtual_discount_amount
            ,o.delivery_time as shipping_time
            ,o.express_fee as shipping_amount
--            ,pos.create_time as pos_sync_time
--            ,case when pos.bill_no is not null then 1 else 0 end as pos_sync_status
            ,o.push_pos_time as pos_sync_time
            ,o.push_pos as pos_sync_status     -- 推送pos 0-待推送，1-推送成功，2-推送失败
            ,current_timestamp as insert_timestamp
    from    ODS_New_OMS.OMS_Retail_Order_Bill o
    left    join ODS_New_OMS.OMS_Retail_Goods_Detalis item
    on      o.id = item.retail_order_bill_id
--    left    join ODS_OMS_Order.ORD_Retail_Order_Receipt invoice -- 无数据
--    on      o.bill_no = invoice.bill_no
--    and     o.id = invoice.bill_id
    left    join ODS_New_OMS.OMNI_Retail_Order_Receipt invoice
    on      o.bill_no = invoice.bill_no
    and     o.id = invoice.bill_id
    left    join ODS_OIMS_System.SYS_Dict_Detail channel
    on      o.platform_id = channel.id
    left    join ODS_OIMS_System.SYS_Dict_Detail sub_channel
    on      o.trade_from = sub_channel.code
    left    join ODS_OIMS_Goods.Gds_Btsinglprodu sku
    --on      item.outer_sku_id = sku.code
    on      item.singleproduct_id = sku.id
--    left    join ODS_OMS_Order.OMS_Sync_Order_To_Pos pos -- 现在无数据
--    on      o.bill_no = pos.bill_no
),

-- 获取发货仓
warehouse as
(
    select  addr.purchase_order_number
            ,addr.logistics_number
            ,def_warehouse.code as def_warehouse
            ,real_warehouse.code as actual_warehouse
    from
    (
         select  bill_no as purchase_order_number
    --            ,province_id
    --            ,province_name
    --            ,city_id
    --            ,district_id
    --            ,district_name
                ,delivery_no as logistics_number -- 物流公司需要关联ord_logistics_trail
                ,ware_house_default_id
                ,ware_house_real_id
        from    ODS_New_OMS.ORD_Retail_ORD_DIS_Info
        group   by bill_no,delivery_no,ware_house_default_id,ware_house_real_id
    ) addr
    left    join ODS_OIMS_Support.Bas_Warehouse def_warehouse -- 需要改成 ODS_IMS 下面的表，现在因为和O2O的表重名了，没有调整
    on      addr.ware_house_default_id = def_warehouse.id
    left    join ODS_OIMS_Support.Bas_Warehouse real_warehouse
    on      addr.ware_house_real_id = real_warehouse.id
)

insert into DW_OMS_Order.DW_OMS_Sales_Order_With_SKU
select  so.sales_order_number
        ,so.joint_order_number
        ,po.purchase_order_number
        ,po.invoice_no
        ,po.invoice_id
        ,so.channel_code
        ,so.channel_name
        ,so.sub_channel_code
--        ,so.sub_channel_name
        ,so.sub_channel_name
        ,so.store_code
        ,so.province
        ,so.city
        ,so.district
        ,coalesce(po.type_code, so.type_code) as type_code -- 老系统也是先的po单的订单类型，取不到再取so单的值
        ,null as sub_type_code
        ,so.member_id
        ,so.member_card
        ,so.member_card_grade
        ,so.payment_amount
        ,so.payment_status
        ,coalesce(po.order_status, so.order_status) as order_status
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
        ,po.virtual_sku_code
        ,po.virtual_quantity
        ,po.virtual_apportion_amount
        ,po.virtual_discount_amount
        ,null as logistics_company -- 先控值，新老OMS的物流公司名称不一样，老OMS是物流公司的编码
        ,warehouse.logistics_number
        ,po.shipping_time
        ,po.shipping_amount
        ,warehouse.def_warehouse
        ,warehouse.actual_warehouse
        ,po.pos_sync_time
        ,po.pos_sync_status
        ,current_timestamp as insert_timestamp
from    so_order so
left    join po_order po
on      so.sales_order_number = po.sales_order_number
left    join warehouse
on      so.purchase_order_number = warehouse.purchase_order_number
;
END
GO
