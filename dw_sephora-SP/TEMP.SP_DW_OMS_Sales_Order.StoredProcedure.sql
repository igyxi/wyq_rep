/****** Object:  StoredProcedure [TEMP].[SP_DW_OMS_Sales_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_OMS_Sales_Order] @dt [nvarchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-13       houshuangqiang     Initial Version
-- ========================================================================================
truncate table [DW_New_OMS].[DW_OMS_Sales_Order];
insert into [DW_New_OMS].[DW_OMS_Sales_Order]
select  o.tid as sales_order_sys_id
        ,item.id as sales_order_item_sys_id
        ,o.tid as sales_order_number
        ,tag.name as type_cd
        ,o.shop_code as store_code
        ,o.platform as channel_code
        ,channel.code as shop_code -- 正式数据之后，需要转化为和老系统名称一样
        ,o.receiver_state as province
        ,o.receiver_city as city
        ,o.receiver_district as district
        ,null as member_id
        ,null as open_id
        ,o.vip_card_no as member_card
        ,coalesce(receiver_mobile,receiver_phone) as member_mobile
        ,null as order_consumer
        ,o.pay_time as payment_time
        ,format(o.pay_time, 'yyyy-MM-dd') as payment_date
        ,o.created as order_time
        ,format(o.created, 'yyyy-MM-dd') as order_date
        ,null as basic_status
        ,null as internal_status
        ,o.pay_status as payment_status
        ,o.total_fee as product_amount
        ,o.post_fee as shipping_amount
        ,o.total_fee + o.post_fee as order_amount -- 商品总额  + 快递费 = 订单总金额
        ,o.payment as payed_amount
        ,o.discount_fee as adjustment_amount
        ,null as coupon_adjustment_amount
        ,null as promotion_adjustment_amount
        ,o.is_invoice as need_invoice_flag
        ,o.seller_memo as buyer_comment
        ,o.buyer_message as buyer_memo  -- 这两个字段顺序，需要结合数据来调整
        ,null as o2o_shop_cd
        ,null as origin_shipping_amount
        ,o.is_black_card as black_card_user_flag -- new_oms 是否为黑卡会员 0否，1 是；老oms:首次黑卡用户标识。1代表“是”，0代表“否”
        ,null as platform_flag
        ,null as member_card_grade -- 备注为业务不需要？？
        ,null as packing_box_flag
        ,null as packing_box_price
        ,o.delivery_time as seller_delivery_time -- 老OMS是商家发货时间，New_OMS是预计发货时间。可能需要关联 ORD_Logistics_Trail 获取真实的发货时间，create_time
        ,format(o.delivery_time, 'yyyy-MM-dd') as seller_delivery_date
        ,o.is_store_delivery as shipping_type  -- 发货方式 (店发：1 仓发：0)
        ,null as shop_pick
        ,null as order_expected_ware_house
        ,null as related_order_number -- 关联订单号。
        ,null as cancel_times_flag
        ,null as cancel_type -- 取消类型，需要找负向单
        ,o.super_order_id
        ,null as food_order_flag
        ,null as payable_amount -- 应付金额，没有对应的字段，需要计算
        ,null as coupon_amount -- 优惠券总金额
        ,null deal_type
        ,null deposit_flag
        ,case when coalesce(merged_code, '') <> '' then 1 else 0 end merge_flag -- merged_code	合包码-用不到, 待确认
        ,o.smart_ba_flag as smartba_flag
        ,o.is_plit as split_flag
        ,item.num as item_quantity
        ,item.list_price as item_market_price
        ,item.sales_price  as item_sale_price -- 网店销售价
        ,item.discount_fee / item.num as item_adjustment_unit_price
        ,item.discount_fee as item_adjustment_amount
        ,item.payment / item.num as item_apportion_unit_price
        ,item.payment as item_apportion_amount
        ,sku.code as item_sku_cd
--        ,sku.name as item_name
        ,item.title as item_name
        ,null as item_description
        ,item.brand as item_brand
        ,item.product_id as item_product_id
        ,null as item_type -- 需要查sku表
        ,o.trade_from as item_source
        ,null as item_category -- 需要关联商品类别表
        ,null as item_returned_quantity -- 已退换货数量。需要关联负向单表
        ,null as item_apply_quantity	-- 申请中数量-退换货和取消
        ,null as item_sale_org -- 销售门店编码
        ,null as item_have_srv_flag -- 是否有服务商品
        ,null as task_flag	-- 无需作业标识
        ,null as item_deal_type -- 业务类型标识
        ,null as item_deal_type_flag --	业务标识
        ,o.activity_id as item_promotion_number	--
        ,null as item_tmall_oid -- 天猫子订单号
        ,null as item_jd_sku_id -- 京东内部SKU的ID
        ,null as item_tax_amount	-- 子订单关税税费
        ,null as item_discount_amount	-- 子订单级订单优惠金额
        ,null as item_tax_promotion_amount  --	子订单计税优惠金额
        ,null as presales_date
        ,null as douyin_oid
        ,null as source
        ,null as super_id --	每个super_id的订单序号
        ,null as place_time -- 付款时间和订单时间的聚合字段
        ,null as place_date	-- 付款日期和订单日期的聚合字段
        ,null as is_valid_flag  --	是否有效-聚合字段
        ,null as is_placed_flag --	是否支付-聚合字段
        ,null as member_card_level	-- 会员卡号等级聚合分类
--        ,o.data_create_time as create_time --	创建时间, 用data_create_time不大合理
        ,o.created as create_time
        ,format(o.created, 'yyyy-MM-dd') as create_date
        ,o.modified as update_time
        ,format(o.modified, 'yyyy-MM-dd') as update_date
        ,null as end_time
        ,null as end_date
        ,o.stock_version as version
        ,0 as is_delete
        ,current_timestamp as insert_timestamp
from    ODS_OMS_Order.OMS_STD_Trade o
left    join ODS_OMS_Order.OMS_STD_Trade_Item item
on      o.tid = item.tid
left    join ODS_IMS.Gds_Btsinglprodu sku
on      item.outer_sku_id = sku.id
left    join ODS_OMS_Order.OMS_STD_Tag_Relation relation
on      o.tid = relation.tid
left    join ODS_IMS.Bas_Tag tag
on      relation.tag_id = tag.id
left    join STG_IMS.Bas_Channel_STG channel -- 测试环境中数据，测试版和O2O正式表名相同，冲突了
on      o.shop_id = channel.id
--left    join ODS_OMS_Order.ORD_Logistics_Trail express
--on
where   tag.dt = @dt
END
GO
