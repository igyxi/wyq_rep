/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_OMS_Refund_Order_Bak_20230607]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_OMS_Refund_Order_Bak_20230607] AS
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
DECLARE @start_time datetime = null;
DECLARE @end_time datetime = null;
select
    -- get max timestamp of the day before
    @start_time = start_time,
    @end_time = end_time
from
(
   select top 1 start_time, end_time from [DW_OMS_Order].[DW_Datetime_Config] where is_delete = '0'  order by start_time desc
) t
;
truncate table DW_OMS_Order.DW_OMS_Refund_Order;
insert into DW_OMS_Order.DW_OMS_Refund_Order
select  [return].bill_no as refund_no
		,case when channel.code = 'jingdong' then 'JD'
			  when channel.code = 'douyinxiaodian' then 'DOUYIN'
			  when channel.code = 'taobao' then 'TMALL'  -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
              when channel.code = 'XIAOHONGSHU' then 'REDBOOK'
			  else upper(channel.code) 
		end as channel_code
		,[return].shop_code as sub_channel_code
		--,task.status as refund_status
		,case when task.status = 0 then 'REFUNDING'
			  when task.status = 1 then 'REFUNDED'
			  when task.status = 2 then 'WAIT_REFUND_TEMP'
			  when task.status = 3 then 'WAIT_REFUND'
			  when task.status = 4 then 'NOT_NEED_REFUND'
		end as refund_status
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
		,trim(task.remark) as refund_comments
		,task.push_return_pos return_pos_flag --  是否生成负销售创建记录标记 1表示去生成负销售 0为不去生成负销售
		,'RETURNED' as refund_source
		,item.sales_order_number as sales_order_number
		,item.purchase_order_number as purchase_order_number
		-- ,task.source_bill_no as sales_order_number
		-- ,task.order_bill_no as purchase_order_number		
--        ,[return].deal_code as sales_order_number
--        ,[return].relate_order_bill_no as purchase_order_number
		,case when channel.code = 'jingdong' and [return].vip_card_no like 'JD%' then SUBSTRING([return].vip_card_no, 3, len([return].vip_card_no)-2) else [return].vip_card_no end as member_card
		,sku.code as item_sku_code
		--,sku.name as item_sku_name
		-- ,item.item_sku_code
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
		-- ,o.pos_invoice_id as invoice_id
        ,'' as invoice_id
		,task.data_create_time as create_time
		,task.data_update_time as update_time
--        ,case when task.return_amount_status =  退款状态 0-退款中，1-退款成功，2-退款失败 3-等待退款 4-无需退款
		,0 as is_delete
		,current_timestamp as insert_timestamp
from 
(
	select 
        refund_bill_id
        ,platform_id
        -- ,order_bill_id
        ,status
        ,bill.type
        ,remark
        ,max(apply_time) as apply_time
        ,max(complete_date) as complete_date
        ,sum(refund_amount) as refund_amount
        ,sum(refund_goods) as refund_goods
        ,sum(refund_shipping) as refund_shipping
        ,min(push_return_pos) as push_return_pos
        ,max(data_create_time) as data_create_time
        ,max(data_update_time) as data_update_time
    from ODS_New_OMS.OMNI_Refund_Task_Bill bill
	inner  join stg_oms.oms_to_oims_sync_fail_log fail
    on   bill.source_bill_no = fail.sales_order_number
    and fail.sync_status = 1
    and fail.update_time >= @start_time
	and fail.update_time <= @end_time
    where refund_bill_type = '0'  -- EB 退款订单
    and  data_update_time >= @start_time
    and  data_update_time <= @end_time
    group by status,bill.type,remark,refund_bill_id,platform_id
    -- ,order_bill_id
) task
left    join ODS_New_OMS.ORD_Retail_Return_Bill [return]
on      task.refund_bill_id = [return].id
and 	[return].data_update_time >= @start_time
and 	[return].data_update_time <= @end_time
left    join
(
	select return_bill_id
            ,single_product_id
			-- ,sku as item_sku_code
			,original_deal_code as sales_order_number
			,original_order_bill_no as purchase_order_number
			,sum(notice_in_qty) as item_quantity
		    ,max(average_payed_amount) as item_apportion_amount
			,sum(isnull(average_discount_fee,0) * return_qty) as item_discount_amount
		-- ,sum(isnull(market_price,0)) as item_discount_amount
	from 	ODS_New_OMS.ORD_Retail_Return_GDS_DE
	where 	data_update_time >= @start_time
	and 	data_update_time <= @end_time
	group 	by return_bill_id,original_deal_code,original_order_bill_no,single_product_id
) item
on      [return].id = item.return_bill_id
left    join ODS_OIMS_Goods.Gds_Btsinglprodu sku
on      item.single_product_id = sku.id
left    join ODS_OIMS_System.SYS_Dict_Detail channel
on      task.platform_id = channel.id
-- left 	join ODS_New_OMS.oms_retail_order_bill o
-- on 		task.order_bill_id = o.id
-- and 	o.data_update_time >= @start_time
-- and 	o.data_update_time <= @end_time
-- where   task.refund_bill_type = '0'  -- EB 退款订单
-- and 	task.data_update_time >= @start_time
-- and 	task.data_update_time <= @end_time
--and    	task.status = 1
union 	all
select  apply.bill_no as refund_no
		,case when channel.code = 'jingdong' then 'JD'
			  when channel.code = 'douyinxiaodian' then 'DOUYIN'
			  when channel.code = 'taobao' then 'TMALL'  -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
                          when channel.code = 'XIAOHONGSHU' then 'REDBOOK'
			  else upper(channel.code)
		end as channel_code
		,apply.shop_code as sub_channel_code
		--,task.status as refund_status
		,case when task.status = 0 then 'REFUNDING'
			  when task.status = 1 then 'REFUNDED'
			  when task.status = 2 then 'WAIT_REFUND_TEMP'
			  when task.status = 3 then 'WAIT_REFUND'
			  when task.status = 4 then 'NOT_NEED_REFUND'
		end as refund_status		
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
		,trim(task.remark) as refund_comments
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
        --,sku.code as item_sku_code
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
		-- ,o.pos_invoice_id as invoice_id  -- task.ticket_sa
        ,'' as invoice_id
		,task.data_create_time as create_time
--       ,task.data_update_time as update_time
		,task.data_update_time as update_time
--        ,case when task.return_amount_status =  退款状态 0-退款中，1-退款成功，2-退款失败 3-等待退款 4-无需退款
		,0 as is_delete
		,current_timestamp as insert_timestamp
from     
(
	select 
        refund_bill_id
        ,platform_id
        -- ,order_bill_id
        ,status
        ,bill.type
        ,remark
        ,max(apply_time) as apply_time
        ,max(complete_date) as complete_date
        ,sum(refund_amount) as refund_amount
        ,sum(refund_goods) as refund_goods
        ,sum(refund_shipping) as refund_shipping
        ,min(push_return_pos) as push_return_pos
        ,max(data_create_time) as data_create_time
        ,max(data_update_time) as data_update_time
    from ODS_New_OMS.OMNI_Refund_Task_Bill bill 
	inner  join stg_oms.oms_to_oims_sync_fail_log fail
    on   bill.source_bill_no = fail.sales_order_number
    and fail.sync_status = 1
    and fail.update_time >= @start_time
	and fail.update_time <= @end_time
    where refund_bill_type = '5'  -- EB 退款订单
    and  data_update_time >= @start_time
    and  data_update_time <= @end_time
    group by status,bill.type,remark,refund_bill_id,platform_id
    -- ,order_bill_id
)task
left 	join ODS_New_OMS.ORD_Refund_Apply_Bill apply
on 		task.refund_bill_id = apply.id
left 	join
(
	select 
            --sku_id
			sku as item_sku_code
            ,ord_refund_apply_bill_id
			,order_bill_no
			-- ,sku as item_sku_code
			,sum(qty) as apply_qty
			,sum(origin_price * qty) as item_total_amount
			,sum(refund_price * qty) as item_apportion_amount
	from 	ODS_New_OMS.ORD_Refund_Apply_Item
	where 	data_update_time >= @start_time
	and 	data_update_time <= @end_time
	and 	(order_bill_no is not null 
	or 		vb_code is null)
	group 	by ord_refund_apply_bill_id,order_bill_no, sku --,sku_id
	union 	all 
	-- vb 
	select  
            vb_code as item_sku_code
            ,ord_refund_apply_bill_id
			,order_bill_no
			-- ,sku as item_sku_code
			,max(vb_qty) as apply_qty
			,max(vb_origin_price) as item_total_amount
			,max(vb_refund_price_total) as item_apportion_amount
	from 	ODS_New_OMS.ORD_Refund_Apply_Item
	where 	data_update_time >= @start_time
	and 	data_update_time <= @end_time
	and 	order_bill_no is null 
	and 	vb_code is not null 
	group 	by ord_refund_apply_bill_id,order_bill_no,vb_code
) item
on 	    apply.id = item.ord_refund_apply_bill_id
--left    join ODS_OIMS_Goods.Gds_Btsinglprodu sku
--on      item.sku_id = sku.id
left 	join ODS_New_OMS.OMS_STD_Trade so
on 	    apply.source_bill_no = so.tid
and 	so.data_update_time >= @start_time
and 	so.data_update_time <= @end_time
left    join ODS_OIMS_System.SYS_Dict_Detail channel
on      task.platform_id = channel.id

END
GO
