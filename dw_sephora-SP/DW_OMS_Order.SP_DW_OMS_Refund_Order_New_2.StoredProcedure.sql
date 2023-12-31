/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_OMS_Refund_Order_New_2]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_OMS_Refund_Order_New_2] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       houshuangqiang     Initial Version
-- 2023-04-20       houshuangqiang     add column
-- 2023-04-24       zeyuan             修改主题域
-- 2023-05-16 	  houshuangqiang 	   add apply_order logic
-- 2023-05-28 	  houshuangqiang 	   update logic
-- ========================================================================================
truncate table DW_OMS_Order.DW_OMS_Refund_Order_New;
insert into DW_OMS_Order.DW_OMS_Refund_Order_New
select 	p.refund_no
		,p.channel_code
		,p.sub_channel_code
		,p.refund_status
		,p.refund_status_name
		,p.refund_type
		,p.refund_type_name
		,p.refund_reason
		,max(p.apply_time) as apply_time
		,max(p.refund_time) as refund_time
		,sum(p.refund_amount) as refund_amount
		,sum(p.product_amount) as product_amount
		,sum(p.delivery_amount) as delivery_amount
		,p.product_in_status
		,p.product_out_status
		,p.refund_mobile
		,p.refund_comments
		,min(p.return_pos_flag) as return_pos_flag
		,p.refund_source
		,p.sales_order_number
		,p.purchase_order_number
		,p.member_card
		,p.item_sku_code
		,p.item_sku_name
		,sum(p.item_quantity) as item_quantity
		,sum(p.item_total_amount) as item_total_amount
		,sum(p.item_apportion_amount) as item_apportion_amount
		,sum(p.item_discount_amount) as item_discount_amount
		,p.sync_type
		,p.sync_status
		,p.sync_time
		,max(p.invoice_id) as invoice_id
		,max(p.create_time) as create_time
		,max(p.update_time) as update_time
		,p.is_delete
		,current_timestamp as insert_timestamp
from 	
(
	select  [return].bill_no as refund_no
			,case when channel.code = 'jingdong' then 'JD'
				  when channel.code = 'douyinxiaodian' then 'DOUYIN'
				  when channel.code = 'taobao' then 'TMALL'  -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
				  else upper(channel.code)
			end as channel_code
			,[return].shop_code as sub_channel_code
			,task.status as refund_status
			,case when task.status = 0 then N'退款中'
				  when task.status = 1 then N'退款成功'
				  when task.status = 2 then N'退款失败'
				  when task.status = 3 then N'等待退款'
				  when task.status = 4 then N'无需退款'
			end as refund_status_name
			,task.type as refund_type
			,case when task.type = 1 then N'商家取消'
				  when task.type = 2 then N'客户取消'
				  when task.type = 3 then N'客户拒单'
				  when task.type = 4 then N'客户售后'
				  when task.type = 5 then N'商家售后'
				  when task.type = 6 then N'整单取消退定金（当支付状态为“部分支付”且OMS后台客服勾选“退定金”）'
				  when task.type = 7 then N'整单取消'
				  when task.type = 8 then N'部分取消'
				  when task.type = 9 then N'PO整单取消'
				  when task.type = 10 then N'PO部分取消'
				  when task.type = 11 then N'拒收'
				  when task.type = 12 then N'退货'
			end as refund_type_name -- 退单类型1退货2追件3拒收
			,[return].return_reason as refund_reason
			,task.apply_time
			,task.complete_date as refund_time
			,task.refund_amount as refund_amount
			,task.refund_goods as product_amount --0511确认字段
			,task.refund_shipping as delivery_amount
			,[return].return_shipping_status as product_in_status -- 退货物流状态：0未收货、1已收货,未入库、2已入库、3可入库、4已退回给客户
			,[return].shipping_status as product_out_status       -- 发货物流状态：0未收货、1已收货,未入库、2已入库、3可入库、4已退回给客户
			,[return].desensitization_receiver_tel as refund_mobile
			,task.remark as refund_comments
			,task.push_return_pos return_pos_flag --  是否生成负销售创建记录标记 1表示去生成负销售 0为不去生成负销售
			,'RETURNED' as refund_source
			,item.sales_order_number as sales_order_number
			,item.purchase_order_number as purchase_order_number
			-- ,task.source_bill_no as sales_order_number
			-- ,task.order_bill_no as purchase_order_number		
	--        ,[return].deal_code as sales_order_number
	--        ,[return].relate_order_bill_no as purchase_order_number
			,case when channel.code = 'jingdong' and [return].vip_card_no like 'JD%' then SUBSTRING([return].vip_card_no, 3, len([return].vip_card_no)-2) else [return].vip_card_no end as member_card
			--,sku.code as item_sku_code
			--,sku.name as item_sku_name
			,item.item_sku_code
			,'' as item_sku_name
			,item.item_quantity
			,item.item_apportion_amount + item.item_discount_amount as item_total_amount
			,item.item_apportion_amount
			,item.item_discount_amount
			--,coalesce(item.average_price, 0) + coalesce(item.average_discount_fee, 0) as item_total_amount
			--,item.average_price as item_apportion_amount
			--,item.average_discount_fee as item_discount_amount
			,'' as sync_type   --?
			,[return].is_push_sap as sync_status --?
	--        ,task.push_return_pos as sync_status
			,[return].push_return_pos_time as sync_time
			,o.pos_invoice_id as invoice_id
			,task.data_create_time as create_time
			,task.data_update_time as update_time
	--        ,case when task.return_amount_status =  退款状态 0-退款中，1-退款成功，2-退款失败 3-等待退款 4-无需退款
			,0 as is_delete
			,current_timestamp as insert_timestamp
	from    ODS_New_OMS.OMNI_Refund_Task_Bill task
	left    join ODS_New_OMS.ORD_Retail_Return_Bill [return]
	on      task.refund_bill_id = [return].id
	left    join
	(
		select return_bill_id
				,sku as item_sku_code
				,original_deal_code as sales_order_number
				,original_order_bill_no as purchase_order_number
				,sum(notice_in_qty) as item_quantity
			,max(average_payed_amount) as item_apportion_amount
				,sum(isnull(average_discount_fee,0) * return_qty) as item_discount_amount
			-- ,sum(isnull(market_price,0)) as item_discount_amount
		from 	ODS_New_OMS.ORD_Retail_Return_GDS_DE
		where 	data_update_time >= '2023-05-29 11:00:00'
		and 	data_update_time <= '2023-05-30 11:00:00'
		group 	by return_bill_id,sku,original_deal_code,original_order_bill_no
	) item
	on      [return].id = item.return_bill_id
	and 	[return].data_update_time >= '2023-05-29 11:00:00'
	and 	[return].data_update_time <= '2023-05-30 11:00:00'
	--left    join ODS_OIMS_Goods.Gds_Btsinglprodu sku
	--on      item.single_product_id = sku.id
	left    join ODS_OIMS_System.SYS_Dict_Detail channel
	on      task.platform_id = channel.id
	left 	join ODS_New_OMS.oms_retail_order_bill o
	on 		task.order_bill_id = o.id
	and 	o.data_update_time >= '2023-05-29 11:00:00'
	and 	o.data_update_time <= '2023-05-30 11:00:00'
	where   task.refund_bill_type = '0'  -- EB 退款订单
	and 	task.data_update_time >= '2023-05-29 11:00:00'
	and 	task.data_update_time <= '2023-05-30 11:00:00'
	--and    	task.status = 1
	union 	all
	select  apply.bill_no as refund_no
			,case when channel.code = 'jingdong' then 'JD'
				  when channel.code = 'douyinxiaodian' then 'DOUYIN'
				  when channel.code = 'taobao' then 'TMALL'  -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
				  else upper(channel.code)
			end as channel_code
			,apply.shop_code as sub_channel_code
			,task.status as refund_status
			,case when task.status = 0 then N'退款中'
					  when task.status = 1 then N'退款成功'
					  when task.status = 2 then N'退款失败'
					  when task.status = 3 then N'等待退款'
					  when task.status = 4 then N'无需退款'
			end as refund_status_name
			,task.type as refund_type
			,case when task.type = 1 then N'商家取消'
				  when task.type = 2 then N'客户取消'
				  when task.type = 3 then N'客户拒单'
				  when task.type = 4 then N'客户售后'
				  when task.type = 5 then N'商家售后'
				  when task.type = 6 then N'整单取消退定金（当支付状态为“部分支付”且OMS后台客服勾选“退定金”）'
				  when task.type = 7 then N'整单取消'
				  when task.type = 8 then N'部分取消'
				  when task.type = 9 then N'PO整单取消'
				  when task.type = 10 then N'PO部分取消'
				  when task.type = 11 then N'拒收'
				  when task.type = 12 then N'退货'
			end as refund_type_name -- 退单类型1退货2追件3拒收
			,apply.refund_reason
			,task.apply_time
			,task.complete_date as refund_time
			,task.refund_amount as refund_amount
			,task.refund_goods as product_amount --0511确认字段
			,task.refund_shipping as delivery_amount
			,null as product_in_status
			,null as product_out_status
			,null as refund_mobile
			,task.remark as refund_comments
			,task.push_return_pos return_pos_flag --  是否生成负销售创建记录标记 1表示去生成负销售 0为不去生成负销售
			,'CANCELLED' as refund_source
			,apply.source_bill_no as sales_order_number
			-- ,apply.order_bill_no as purchase_order_number -- 没有值，让在item中取值，取值逻辑真混乱。item中又没有so单
				,item.order_bill_no as purchase_order_number 
	--        ,apply.source_bill_no as sales_order_number
	--        ,apply.order_bill_no as purchase_order_number
			--,o.member_card_no
			--,apply.member_level_name
			,case when channel.code = 'jingdong' and so.vip_card_no like 'JD%' then SUBSTRING(so.vip_card_no, 3, len(so.vip_card_no)-2) else so.vip_card_no end as member_card
			,item.item_sku_code
			,'' as item_sku_name
			,item.apply_qty as item_quantity
			--,coalesce(item.average_price, 0) + coalesce(item.average_discount_fee, 0) as item_total_amount
			,item.item_total_amount
			,item.item_apportion_amount
			,item.item_total_amount - item.item_apportion_amount as item_discount_amount
			,'' as sync_type   --?
			,null as sync_status --?
	--        ,task.push_return_pos as sync_status
			,null as sync_time --?
			,o.pos_invoice_id as invoice_id  -- task.ticket_sa
			,task.data_create_time as create_time
	--       ,task.data_update_time as update_time
			,task.data_update_time as update_time
	--        ,case when task.return_amount_status =  退款状态 0-退款中，1-退款成功，2-退款失败 3-等待退款 4-无需退款
			,0 as is_delete
			,current_timestamp as insert_timestamp
	from    ODS_New_OMS.OMNI_Refund_Task_Bill task
	left 	join ODS_New_OMS.ORD_Refund_Apply_Bill apply
	on 		task.refund_bill_id = apply.id
	left 	join
	(
		select ord_refund_apply_bill_id
				,order_bill_no
				,sku as item_sku_code
				,sum(qty) as apply_qty
				,sum(origin_price * qty) as item_total_amount
				,sum(refund_price * qty) as item_apportion_amount
		from 	ODS_New_OMS.ORD_Refund_Apply_Item
		where 	data_update_time >= '2023-05-29 11:00:00'
		and 	data_update_time <= '2023-05-30 11:00:00'
		group 	by ord_refund_apply_bill_id,order_bill_no,sku
	) item
	on 	    apply.id = item.ord_refund_apply_bill_id
	left 	join ODS_New_OMS.OMS_STD_Trade so
	on 	    apply.source_bill_no = so.tid
	and 	so.data_update_time >= '2023-05-29 11:00:00'
	and 	so.data_update_time <= '2023-05-30 11:00:00'
	left 	join ODS_New_OMS.oms_retail_order_bill o
	on 		task.order_bill_id = o.id
	and 	o.data_update_time >= '2023-05-29 11:00:00'
	and 	o.data_update_time <= '2023-05-30 11:00:00'
	left    join ODS_OIMS_System.SYS_Dict_Detail channel
	on      task.platform_id = channel.id
	where   task.refund_bill_type = '5'  -- EB 退款订单
	and 	task.data_update_time >= '2023-05-29 11:00:00'
	and 	task.data_update_time <= '2023-05-30 11:00:00'
) p 
group by p.refund_no,p.channel_code,p.sub_channel_code,p.refund_status,p.refund_status_name,p.refund_type,p.refund_type_name,p.refund_reason,p.product_in_status,p.product_out_status,p.refund_mobile,p.refund_comments,p.refund_source,p.sales_order_number,p.purchase_order_number,p.member_card,p.item_sku_code,p.item_sku_name,p.sync_type,p.sync_status,p.sync_time,p.is_delete

;
END
GO
