/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_OMS_Sales_Order_With_SKU_Bak_20230618]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_OMS_Sales_Order_With_SKU_Bak_20230618] AS
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
-- ========================================================================================
truncate table DW_OMS_Order.DW_OMS_Sales_Order_With_SKU;
with so_order as
(
    select  so.tid as sales_order_number
            ,so.merge_no as joint_order_number
            -- ,so.bill_no as purchase_order_number
            ,case when upper(so.platform) = 'TAOBAO' then 'TMALL'
                  when upper(so.platform) = 'JINGDONG' then 'JD'
                  when upper(so.platform) = 'DOUYINXIAODIAN' then 'DOUYIN'
                  when upper(so.platform) = 'XIAOHONGSHU' then 'REDBOOK'
                  else upper(so.platform)
             end as channel_code
            ,case when upper(so.platform) = 'TAOBAO' then N'天猫'
                  when upper(so.platform) = 'JINGDONG' then N'京东'
                  when upper(so.platform) = 'DOUYINXIAODIAN' then N'抖音'
                  when upper(so.platform) = 'XIAOHONGSHU' then N'小红书'
                  when upper(so.platform) = 'SOA' then N'官网'
                  when upper(so.platform) = 'OFF_LINE' then N'线下'
             end as channel_name
--            ,store.channel_id as channel_code
--            ,store.channel_name
			,case when so.shop_code = 'S001' then so.channel_id
				  else so.shop_code
			end as sub_channel_code
			,case when so.shop_code = 'S001' then so.channel_id
				 -- when so.shop_code = 'TMALL001' and so.shop_id = 'TM2' then N'天猫WEI旗舰店'
--				 when so.shop_code = N'REDBOOK001' then N'小红书旗舰店'
--				 when so.shop_code = N'TMALL001' then N'天猫官方旗舰店'
--				 when so.shop_code = N'JD001' then N'京东官方旗舰店'
				 else channel.name
			end as sub_channel_name
            ,so.shop_code -- 关联mapping表
            -- ,so.store_id as store_id
--            ,so.store_number
            ,customer_id as member_id
            ,case when so.channel_id = 'JD' and so.vip_card_no like 'JD%' then SUBSTRING(so.vip_card_no, 3, len(so.vip_card_no)-2) else so.vip_card_no end as member_card
            ,coalesce(so.member_level_name, o.group_name)  as member_card_grade
            ,case when so.smart_BA_flag is not null then so.smart_BA_flag
                  when os.order_id is not null and so.channel_id = 'MINIPROGRAM' then 1
                  else 0
             end as smartba_flag
            ,so.created as order_time
            ,so.pay_time as payment_time
            ,so.payment as payment_amount
            ,case when so.pay_status = 1 then 2
				  when so.pay_status = 2 then 1
				  else so.pay_status  -- 枚举类型和老oms是相反的，需要转换回去。
			end as payment_status
            ,so.status as order_status
            -- ,case when so.pay_status = 2 then 1 else 0 end as is_placed
            --,so.pay_time as place_time
			,case when so.shop_code not in ('TMALL002', 'GWP001')
				  and po.order_type not in ('2') -- 老oms order_type的枚举是2,9
				  and (so.pay_status = 2 or pay_time is not null) -- or po.order_type = 8
				  and so.total_fee > 1 then 1
				  else 0
			end is_placed
			,case when po.order_type = 8 then so.created else coalesce(so.pay_time, so.created) end as place_time
            --,relation.tag_id -- 值与老系统的订单类型不相同
            --,tag.code as type_code -- 值与老系统的订单类型不相同
            --,tag.name  -- 值与老系统的订单类型不相同
            ,so.receiver_state as province
            ,so.receiver_city as city
            ,so.receiver_district as district
--            ,post_fee as shipping_amount so 单快递费
    from    ODS_New_OMS.OMS_STD_Trade so
--    left    join STG_OMS.OMS_Store_Info store
--    on      so.shop_code = store.store_id
    left    join ODS_OIMS_Support.Bas_Channel channel
    on      so.shop_id = channel.id
    --left    join ODS_New_OMS.OMS_Std_Tag_Relation relation
    --on      so.tid = relation.tid
    --and     so.platform = relation.tid
    --left    join ODS_OIMS_Support.Bas_Tag tag
    --on      relation.tag_id = tag.id
	left 	join
	(
			select order_id, group_name from STG_Order.Orders where group_name <> 'O2O'
	) o
	on 		so.tid = o.order_id
	left 	join
	(
		select order_id from STG_Order.Order_Source where utm_campaign = 'BA'and utm_medium ='seco' group by order_id
	) os
	on  so.tid = os.order_id
	left 	join
	(
		select 	source_bill_no, order_type
		from 	ODS_New_OMS.OMS_Retail_Order_Bill
		where 	data_update_time >= '2023-05-15 18:00:00'
		and   	data_update_time <= '2023-05-15 20:00:00'
		group 	by source_bill_no, order_type
	) po
	on 		so.tid = po.source_bill_no
	where 	so.data_update_time >= '2023-05-15 18:00:00'
	and 	so.data_update_time <= '2023-05-15 20:00:00'
    -- where   so.platform in ('jingdong','SOA','xiaohongshu','OFF_LINE','douyinxiaodian','taobao')
),

po_order as
(
    select  o.source_bill_no as sales_order_number
            ,o.bill_no as purchase_order_number
			,o.bill_no as invoice_no
            ,o.pos_invoice_id as invoice_id
            --,o.store_code
            ,o.order_type as type_code
            ,o.activity_type as sub_type_code
--            ,'' as member_id -- 暂时没有会员id
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
            --,o.bill_date as order_time -- 下单时间
            --,o.pay_date as payment_time
            --,case when o.pay_state = 2 then 1 else 0 end as is_placed
            --,o.pay_date as place_time
            --,sku.code as item_sku_code
            --,sku.name as item_sku_name
			,item.item_sku_code
			,null as item_sku_name
            ,sum(item.item_quantity) as item_quantity
            ,max(item.item_sale_price) as item_sale_price
--            ,sum(item.amount) as item_total_amount
            ,sum(item.item_apportion_amount) + sum(item.item_discount_amount) as item_total_amount
            ,sum(item.item_apportion_amount) as item_apportion_amount
            ,sum(item.item_discount_amount) as item_discount_amount
            ,max(item.vb_code) as virtual_sku_code
            ,sum(item.vb_qty) as virtual_quantity
            ,sum(item.vb_total_amount) as virtual_apportion_amount
            ,sum(item.virtual_discount_amount) as virtual_discount_amount
            ,o.delivery_time as shipping_time
            ,o.express_fee as shipping_amount
            ,o.push_pos_time as pos_sync_time
            ,o.push_pos as pos_sync_status     -- 推送pos 0-待推送，1-推送成功，2-推送失败
            --,current_timestamp as insert_timestamp
    from    ODS_New_OMS.OMS_Retail_Order_Bill o
    left    join

	(
		select 	retail_order_bill_id
				,qty as item_quantity
--				,price as item_sale_price
                ,price_tag as item_sale_price
				--,amount
				,sku_code as item_sku_code
				,share_payment as item_apportion_amount
				,coalesce(merchant_discount_fee, 0)  + coalesce(platform_discount_fee, 0) as item_discount_amount
				,vb_code
				,vb_qty
				,vb_total_amount
				,coalesce(vb_origin_price, 0) - coalesce(vb_total_amount, 0) as virtual_discount_amount
		from 	ODS_New_OMS.OMS_Retail_Goods_Detalis
		where 	data_update_time >= '2023-05-15 18:00:00'
		and   	data_update_time <= '2023-05-15 20:00:00'
		union 	all
		select  id as retail_order_bill_id
				,1 as item_quantity
				,0 as item_sale_price
				--,0 as amount
				,'TRP001' as item_sku_code
				,express_fee as item_apportion_amount
				,0 as item_discount_amount
				,null as vb_code
				,0 as vb_qty
				,0 as vb_total_amount
				,0 as virtual_discount_amount
		from 	ODS_New_OMS.OMS_Retail_Order_Bill
		where 	order_type <> 1
		and 	express_fee > 0
		and 	data_update_time >= '2023-05-15 18:00:00'
		and   	data_update_time <= '2023-05-15 20:00:00'

	) item
    on      o.id = item.retail_order_bill_id
    --left    join ODS_OIMS_Goods.Gds_Btsinglprodu sku
    --on      item.outer_sku_id = sku.code
    --on      item.singleproduct_id = sku.id
	where 	o.data_update_time >= '2023-05-15 18:00:00'
	and 	o.data_update_time <= '2023-05-15 20:00:00'
	--and 	coalesce(o.is_plit, 0) = 0
	--and 	o.is_plit_new = 1
	--and 	item.data_update_time <= '2023-05-15 18:00:00'
	--and 	item.data_update_time <= '2023-05-15 20:00:00'
	group 	by o.source_bill_no,o.bill_no,o.bill_no,o.pos_invoice_id,o.order_type,o.member_card_no,o.member_level_name,o.activity_type,
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
			item.item_sku_code,o.delivery_time,o.express_fee,o.push_pos_time,o.push_pos

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
         select   bill_no as purchase_order_number
                  ,delivery_type_id
    --            ,province_id
    --            ,province_name
    --            ,city_id
    --            ,district_id
    --            ,district_name
                ,delivery_no as logistics_number -- 物流公司需要关联ord_logistics_trail
                ,ware_house_default_id
                ,ware_house_real_id
        from    ODS_New_OMS.ORD_Retail_ORD_DIS_Info
		where 	data_update_time <= '2023-05-15 18:00:00'
		and 	data_update_time <= '2023-05-15 20:00:00'
        group   by bill_no,delivery_type_id,delivery_no,ware_house_default_id,ware_house_real_id
    ) addr
    left    join ODS_OIMS_Support.Bas_Delivery_Type delivery
    on      addr.delivery_type_id = delivery.id
    and     delivery.status = '9'
    left    join ODS_OIMS_Support.Bas_Warehouse def_warehouse -- 需要改成 ODS_IMS 下面的表，现在因为和O2O的表重名了，没有调整
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
--        ,so.sub_channel_name
        ,so.sub_channel_name
        ,store.store_code  -- store
        ,so.province
        ,so.city
        ,so.district
        -- ,coalesce(po.type_code, so.type_code) as type_code -- 老系统也是先的po单的订单类型，取不到再取so单的值
        ,po.type_code
        ,po.sub_type_code
        ,so.member_id
        ,so.member_card
        ,coalesce(po.member_card_grade, so.member_card_grade) as member_card_grade
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
        ,warehouse.logistics_company 
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
on      po.purchase_order_number = warehouse.purchase_order_number
left    join STG_OMS.OMS_Store_Mapping store -- new oms中缺少获取门店code的方式，so单中的store_number门店编码都为空
-- on      so.store_id = store.store_id
on      so.shop_code = store.store_id
and     warehouse.actual_warehouse = store.warehouse
;
END


GO
