/****** Object:  StoredProcedure [DW_OrderHub].[SP_DWS_Hub_Refund_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OrderHub].[SP_DWS_Hub_Refund_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-25       houshuangqiang     Initial Version
-- 2022-11-18       houshuangqiang     Add duplication logic
-- 2022-11-25       houshuangqiang     Add order_type column
-- ========================================================================================
truncate table DW_OrderHub.DWS_Hub_Refund_Order;
insert into DW_OrderHub.DWS_Hub_Refund_Order
select
       refund.refund_no,
       refund.channel_code,
       null as sub_channel_code,
       o.store_code,
       null as store_name,
       refund.order_type,
       refund.refund_status,
       refund.refund_type,
       refund.refund_reason,
       refund.apply_time,
       null as refund_time,
       refund.refund_amount,
       null as product_amount,
       null as delivery_amount,
       null as refund_mobile,
       null as refund_comments,
       null as return_pos_flag,
       o.order_id as sales_order_number,
       null as purchase_order_number,
       o.card_code as member_card,
       case when o.channel_id = 'MEITUAN' and o.order_status = 8 then 1
			when o.s_order_status = 8 then 1
            else 0
       end as is_placed,
       o.order_pay_time as place_time,
       coalesce(vb.sku_code, item.sku_code) as item_sku_code, -- 新系統中有VB
       coalesce(vb.sku_name, item.sku_name) as item_sku_name,
       coalesce(vb.quantity, item.quantity) as item_quantity,
       -- vb 退款优惠金额。涉及到不是全退的情况，有折扣，按件数折扣
       coalesce(vb.list_price * vb.quantity, item.origin_price * item.quantity) as item_total_amount, -- 总金额，sku级的实际支付金额+sku级的优惠金额
    --       item.price * item.quantity as item_apportion_amount, -- 实际总金额
       coalesce(vb.price_total, item.refund_price_total) as item_apportion_amount,
       coalesce(vb.list_price * vb.quantity - vb.price_total, item.origin_price * item.quantity - item.refund_price_total) as item_discount_amount,-- 实际总价-退款总金额
       null as sync_type,
       null as sync_status,
       null as sync_time,
       o.invoice_no as invoice_id,
       refund.create_time,
       refund.update_time,
       refund.is_delete,
       current_timestamp as insert_timestamp
from
(
	select 	refund_order_id as refund_no,
			refund_order_sys_id,
			sales_order_id,
			channel_id as channel_code,
			case when event_type in (1, 2, 3) then 'CANCELED' when event_type in (4, 5) then 'RETURN' else null end order_type,
			case when channel_id = 'MEITUAN' and res_type = 0 then N'退款中'
				when channel_id = 'MEITUAN' and res_type in (2, 4, 5, 6) then N'退款成功'
				when channel_id = 'MEITUAN' and res_type in (1, 3, 7, 8) then N'退款失败'
				when channel_id = 'DIANPING' and res_type = 1 then N'退款中'
				when channel_id = 'DIANPING' and res_type = 2 then N'退款成功'
				when channel_id = 'DIANPING' and res_type = 3 then N'退款失败'
				when channel_id = 'JDDJ' and res_type = 0 then N'退款中'
				when channel_id = 'JDDJ' and res_type in (1, 2) then N'退款成功'
				when channel_id = 'JDDJ' and res_type = 3 then N'退款失败'
			end as refund_status,
			refund_type,
			refund_reason,
			refund_time as apply_time,
			refund_amount,
			create_time,
			update_time,
			is_delete,
			row_number() over(partition by sales_order_id,refund_type,notify_type,refund_time,refund_amount,refund_id, res_type order by refund_order_sys_id desc) row_rank
	from 	STG_OrderHub.Refund_Order
	where 	notify_type in ('agree', 'sysAgree') -- 有重复数据sales_order_id in ('125043592374805838', '125043661124706872')
) refund
left    join STG_OrderHub.Refund_Order_Item item
on  	refund.refund_order_sys_id = item.refund_order_sys_id
inner 	join STG_OrderHub.Store_Order o
on   	refund.sales_order_id = o.sales_order_id
and 	o.derived_type = 'NEW'
left 	join STG_OrderHub.Store_Order_Item storeitem
on 		storeitem.store_order_sys_id = o.store_order_sys_id
and     storeitem.sku_code = item.sku_code
left 	join STG_OrderHub.Store_Order_Item_VB vb
on 		storeitem.store_order_item_sys_id = vb.order_item_sys_id
where   refund.row_rank = 1
;
end

GO
