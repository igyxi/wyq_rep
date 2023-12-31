/****** Object:  StoredProcedure [TEMP].[SP_DWS_Sales_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Sales_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-29       houshuangqiang     Initial Version
-- 2022-12-15       wangzhichun        change source table schema
-- ========================================================================================
truncate table [DW_NEW_OMS].[DWS_Sales_Order];
with sub_order as
(
    select  po.id
            ,po.source_bill_no
    --        ,poItem.singleproduct_id as sku_id
            ,poItem.barcode as sku_code
            ,tax_rate as item_tax_amount -- 子订单关税税费
            ,sum(amount_discount) as item_discount_amount -- 子订单级订单优惠金额
            ,null as item_tax_promotion_amount -- 子订单计税优惠金额, 这个暂时不知道怎么计算
    --        ,qty
    from    STG_New_OMS.OMNI_Retail_Order_Bill po
    left    join STG_New_OMS.OMNI_Retail_ORD_Goods_Detail poItem
    on      po.id = poItem.retail_order_bill_id
    group   by po.id,po.source_bill_no,poItem.barcode,tax_rate
)



insert into [DW_NEW_OMS].[DWS_Sales_Order]
select 	coalesce(oitem.id, 1) as sales_order_sys_id -- 为什么还有关联不上的？
		,oitem.id as sales_order_item_sys_id  -- 这里暂时取一样的
--		,o.tid as sales_order_number
        ,o.bill_no as sales_order_number
		,order_ext_type as type_cd              -- 订单类型
		,o.shop_code as store_cd
		,upper(o.platform) as channel_cd
		,o.shop_code as shop_cd
		,o.receiver_state as province
		,o.receiver_city as city
		,o.receiver_district as district
		,null as member_id
		,null as open_id
		,o.vip_card_no as member_card       -- 会员no, 是手机号？？？
		,null as member_mobile
		,o.receiver_name as order_consumer
		,o.pay_time as payment_time
		,cast(o.pay_time as date) as payment_date
		,o.created as order_time
		,cast(o.created as date) as order_date
		,o.status as basic_status
		,null as internal_status            -- 老的oms的状态和物流状态精密想过，包括签收拒收，现在的物流状态只有签收和为签收状态，之前的状态有几十个状态。
		,o.pay_status as payment_status
		,o.total_fee as product_amount
		,o.post_fee as shipping_amount
		,o.payment + o.discount_fee as order_amount  -- 实付金额 + 优惠金额
		,o.payment as payed_amount
		,o.discount_fee as adjustment_amount
		,null as coupon_adjustment_amount       -- 优惠券金额，暂时没有,这里用优惠金额，可以吗？
		,null as promotion_adjustment_amount    -- 促销优惠券金额
--      oms上的是优化券金额和促销优惠金额 都为null
--		coupon_adjustment_total	decimal(20,5)	1	优惠券优惠金额
--      promotion_adjustment_total	decimal(20,5)	1	促销优惠金额
        -- 在O2O上用这里用商家优惠和平台优惠，是不是可以的？
--        ,oitem.platform_discount_fee as coupon_adjustment_amount -- 平台优惠金额作为优惠券金额？
--        ,oitem.merchant_discount_fee as promotion_adjustment_amount -- 商家优惠金额作为促销优惠券金额
		,cast(invoice.need_invoice_flag as int) as need_invoice_flag    -- 是否要发票
		,o.buyer_message as buyer_comment	-- 订单发货备注
		,o.buyer_message as buyer_memo      -- 订单下单留言
		--,o.seller_memo		-- 商家留言
--        ,concat_ws('_', store.code, store.name) as buyer_memo      -- 老的oms的值。是门店id_门店名称，这里也这样用。字典表中的注释有问题，不能完全看字典表
		,store.code as o2o_shop_cd -- nvarchar
		,o.post_fee as origin_shipping_amount
		,null as black_card_user_flag
		,null as platform_flag
		,null as member_card_grade
		,null as packing_box_flag -- 包装礼盒标识。1代表“是”，0代表“否”
		,null as packing_box_price -- 包装礼盒价格
		,express.out_bound_date as seller_delivery_time -- 商家发货时间，需要从物流信息上获取, 可以用出库时间最接近
		,cast(express.out_bound_date as date) as seller_delivery_date
		,null as shipping_type -- 发货类型，sales_order的值，也是null,这里可以直接赋默认值null
		,null as shop_pick  -- 发出地址门店自提，总店发货，分店取货的门店自提订单标识,sales_order的值，也是null,这里可以直接赋默认值null
		,null as order_expected_ware_house -- 期望发货仓，sales_order不是null
		,null as related_order_number  -- 关联订单，不是null
		,null as cancel_times_flag
		,null as cancel_type
		,null as super_order_id
		,null as food_order_flag
		,null as payable_amount -- 应付金额,OMS上的应付金额数据也为NULL
		,oitem.discount_fee as coupon_amount -- 优惠券总金额,需要关联优化券表
		,null as deal_type -- 业务类型标识，[{"02": "01"}, {"08": "01"}]
		,null as deposit_flag
		,null as merge_flag
		,null as smartba_flag
		,oitem.num as item_quantity
		,null as item_market_price -- 市场价和网点销售价，
		,oitem.total_fee as item_sale_price -- 网店销售价
		,(oitem.total_fee - oitem.payment) / oitem.num  as item_adjustment_unit_price -- 商品优惠单价
		,oitem.total_fee - oitem.payment as item_adjustment_amount -- 商品优惠总价
		,oitem.payment / oitem.num as item_apportion_unit_price -- 实付单价
		,oitem.payment as item_apportion_amount -- 实付总价
		,oitem.outer_sku_id as item_sku_cd
		,sku.name as item_name
		,oitem.title as item_description
		,brand.name as item_brand
		,oitem.outer_iid as item_product_id  -- 还没有确定是哪个表中的，gds_btgoods
		--,null as item_type -- ,name_en as item_type -- 暂时缺少name_en字段
		,o.order_ext_type as item_type
		,o.trade_from as item_source
		,category.name as item_category
--		,ritem.num as item_returned_quantity -- 已退换货数量,  为null的，后面需要赋值为0吗？
--		,r0.num - ritem.num as item_apply_quantity -- 申请中数量-退换货和取消
        ,null as item_returned_quantity -- 已退换货数
        ,null as item_apply_quantity  -- 申请中数量-退换货和取消, 暂时还不知道怎么取值
		,null as item_sale_org -- OMS系统中这个字段也全部为null
		,null as item_have_srv_flag -- 是否有服务商品，oms中全部为null
		,null as task_flag -- OMS系统中这个字段也全部为null
		,null as item_deal_type --46638174 个null,36647个01
		,null as item_deal_type_flag --46638174 个null,36647个04
		,null as item_promotion_number -- 活动编码 OMS系统中这个字段也全部为null
		,null as item_tmall_oid
		,null as item_jd_sku_id
		,sub.item_tax_amount -- 子订单关税税费, 不应为null
		,sub.item_discount_amount -- 子订单级订单优惠金额
		,sub.item_tax_promotion_amount -- 子订单计税优惠金额
		,null as presales_date
		,null as douyin_oid
		--,trade_from as source  -- SLT,RELATED,JFDH,ZYDH
		,o.trade_from as source
		,null as super_id
		,o.pay_time as place_time
		,cast(o.pay_time as date) as place_date -- 不知道这和上面的付款时间有什么区别？
		,null as is_valid_flag
		,null as is_placed_flag
		,null as member_card_level
		,o.created as create_time
		,cast(o.created as date) as create_date
		,o.updated_at as update_time
		,cast(o.updated_at as date) as update_date
		,null as start_time
		,null as end_time
		,null as version
        ,null as is_delete
        ,current_timestamp as insert_timestamp
from	STG_New_OMS.OMS_STD_Trade o
left 	join STG_New_OMS.OMS_STD_Trade_Item oitem
on 		o.tid = oitem.tid
and     o.platform = oitem.platform
--left    join STG_New_OMS.OMS_STD_Return ro
--on      o.tid = ro.tid
--left    join STG_New_OMS.OMS_STD_Return_Item ritem
--on      oitem.oid = ritem.oid
--and  	oitem.outer_sku_id = ritem.outer_sku_id
--and 	oitem.platform = ritem.platform  -- 会放大数据量，需要单独处理
--left    join STG_New_OMS.OMNI_Retail_Order_Bill po -- 这里关联了的话，数据量会放大
--on      o.tid = po.source_bill_no
left    join sub_order sub
on      oitem.tid = sub.source_bill_no
and     oitem.outer_sku_id = sub.sku_code
left 	join STG_IMS.Gds_Btsinglprodu sku
on 		oitem.outer_sku_id = sku.code
left 	join STG_IMS.Bas_Brand brand
on 		sku.brand_id = brand.id
left    join STG_IMS.GDS_CategoryTree category
on      sku.category_tree_id = category.id
left 	join
(
    select distinct
            bill_no
            ,out_bound_date
    from  STG_New_OMS.Omni_Retail_Ord_Dis_Info
) express
on 		o.bill_no = express.bill_no
--left 	join STG_New_OMS.Oms_Std_Trade_Promotion coupon -- 优惠券需要验数，检查和OMS_STD_Trade 是不是一样的,有可能优惠金额，需要到优惠券表上取值
--on 		o.tid = coupon.tid
left    join STG_New_OMS.Oms_STD_Trade_Invoice invoice -- 发票
on      o.tid = invoice.tid
and     o.platform = invoice.platform
left    join STG_IMS.Bas_Channel store
on      o.shop_id = store.id

END
GO
