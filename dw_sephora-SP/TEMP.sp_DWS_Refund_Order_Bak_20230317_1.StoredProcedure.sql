/****** Object:  StoredProcedure [TEMP].[sp_DWS_Refund_Order_Bak_20230317_1]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[sp_DWS_Refund_Order_Bak_20230317_1] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-09       wangzhichun         Initial Version
-- 2022-12-13       houshuangqiang      add is_sync column
-- 2022-12-15       wangzhichun         change source table schema
-- 2023-03-17       houshuangqiang      add order_status
-- ========================================================================================
truncate table [DW_NEW_OMS].[DWS_Refund_Order];
insert into [DW_NEW_OMS].[DWS_Refund_Order]
select	cancel.bill_no as refund_no
		,case when upper(dict.code) = 'DAZHONGDIANPING' then 'DIANPING'
		      when upper(dict.code) = 'JINGDONGDAOJIA' then 'JDDJ'
		      else upper(dict.code)
		end as channel_code
		,dict.name as channel_name
		,ware.code as store_code
		,ware.name as store_name
	    ,'CANCELED' order_type
        ,case when upper(dict.code) = 'DAZHONGDIANPING' and o.distribution_state = 4 then 8
            when upper(dict.code) = 'DAZHONGDIANPING' and o.distribution_state = 6 then 2
            when upper(dict.code) = 'DAZHONGDIANPING' and o.distribution_state in (1, 2, 3, 5, 9) then o.distribution_state 
            when upper(dict.code) = 'MEITUAN' and o.status = 8 then o.distribution_state
            else o.distribution_state
        end as order_status -- so订单状态
		,case when cancel.res_type = 1 then N'退款中'
			  when cancel.res_type = 2 then N'退款成功'
			  when cancel.res_type = 3 then N'退款失败'
		end as refund_status
		,cancel.refund_type as refund_type
	    ,cancel.refund_reason
		,coalesce(refund.apply_time,cancel.refund_time) as apply_time
		,cancel.complete_date as refund_time -- 退款单上又没有退款时间，但有申请时间
		,coalesce(refund.refund_amount, cancel.refund_amount) as refund_amount
		,null as product_amount
		,null as delivery_amount -- 取消订单的，退运费是否直接赋值0。
        ,o.member_phone as refund_mobile
		,coalesce(refund.remark, cancel.remark) as refund_comments
		,1 as return_pos_flag
        ,cancel.source_bill_no as sales_order_id 
        ,coalesce(refund.order_bill_no, cancel.order_bill_no) as sales_order_number
        -- ,refund.order_bill_id as sales_order_id -- 关联so表使用，可以保证一对一
        ,null as purchase_order_number
		,o.member_card_no as member_card
		,case when o.distribution_state = 8 then 1 else 0 end as is_placed -- so单支付状态
		,o.pay_date as place_time
		,sku.code as item_sku_code
		,sku.name as item_sku_name
		,item.qty as item_quantity
		,item.origin_price * item.qty as item_total_amount  -- 总金额
		,item.refund_price_total as item_apportion_amount   -- 实际总金额
		,(item.origin_price * item.qty - item.refund_price_total) as item_discount_amount
		,null as sync_type
		,null as sync_status
		,null as sync_time
        ,o.invoice_no as invoice_id
        ,o.is_synt as is_sync -- 核对日报数据使用，同步过来的数据和迁移之后数据，报表逻辑有差异
        ,0 as is_delete
		,cancel.create_time as create_time
		,cancel.modify_time as update_time
		,current_timestamp as insert_timestamp
from    STG_New_OMS.OMNI_Refund_Apply_Bill cancel
left    join STG_New_OMS.OMNI_Refund_Apply_Item item
on      cancel.id = item.refund_apply_bill_id
left    join STG_New_OMS.OMNI_Refund_Task_Bill refund
on      cancel.refund_id = refund.refund_id
and     cancel.id = refund.refund_bill_id
left    join STG_New_OMS.Omni_Retail_Order_Bill o
on      refund.order_bill_id = o.id
-- left    join STG_New_OMS.OMNI_Retail_ORD_Goods_Detail detail
-- on      cast(item.order_bill_goods_id as bigint) = detail.id
left    join STG_IMS.gds_btsinglprodu sku
on      item.sku_id = sku.id
left    join STG_IMS.Bas_Warehouse ware
on      cancel.warehouse_id = ware.id
left    join STG_IMS.SYS_Dict_Detail dict
on      cancel.platform_id = dict.id
where    cancel.status = '4' -- 只取同意退款的
union   all
-- return order
select 	[return].bill_no as refund_no			     -- 退款单号
        ,case when upper(dict.code) = 'DAZHONGDIANPING' then 'DIANPING'
		      when upper(dict.code) = 'JINGDONGDAOJIA' then 'JDDJ'
		      else upper(dict.code)
		end as channel_code
        ,dict.name as channel_name
        ,ware.code as store_code
		,ware.name as store_name
	    ,'RETURNED' order_type
        ,case when upper(dict.code) = 'DAZHONGDIANPING' and o.distribution_state = 4 then 8
            when upper(dict.code) = 'DAZHONGDIANPING' and o.distribution_state = 6 then 2
            when upper(dict.code) = 'DAZHONGDIANPING' and o.distribution_state in (1, 2, 3, 5, 9) then o.distribution_state 
            when upper(dict.code) = 'MEITUAN' and o.status = 8 then o.distribution_state
            else o.distribution_state
        end as order_status
		,case when [return].res_type = 0 then N'退款中'
			  when [return].res_type = 1 then N'退款成功'
			  when [return].res_type = 2 then N'退款失败'
		end as refund_status
		,[return].refund_type
		,[return].return_reason as refund_reason
		,[return].apply_time
		,[return].complete_date as refund_time
		,[return].actual_return_amount as refund_amount
		,null as product_amount
		,null as delivery_amount
		,coalesce([return].receiver_tel,[return].receiver_mobile) as refund_mobile
		,[return].remark as refund_comments
		,1 as return_pos_flag
        ,[return].deal_code as sales_order_id
        ,[return].relate_order_bill_no as sales_order_number
 --       ,[return].order_bill_id as sales_order_id   -- 关联so表使用
        ,null as purchase_order_number
		,o.member_card_no as member_card
		,case when o.distribution_state = 8 then 1 else 0 end as is_placed
		,o.pay_date as place_time
		--,item.sku as item_sku_code
		,sku.code as item_sku_code
		,sku.name as item_sku_name
		,item.notice_in_qty as item_quantity
		,item.shop_price * item.notice_in_qty as item_total_amount
		,item.average_payed_amount as item_apportion_amount
		,item.shop_price * item.notice_in_qty - item.average_payed_amount as item_discount_amount
		,null as sync_type
		,null as sync_status
		,null as sync_time
        ,o.invoice_no as invoice_id
        ,o.is_synt as is_sync -- 核对日报数据使用，同步过来的数据和迁移之后数据，报表逻辑有差异
        ,0 as is_delete
		,[return].create_date as create_time
		,[return].modify_date as update_time
		,current_timestamp as insert_timestamp
from 	STG_New_OMS.OMNI_Retail_Return_Bill [return] -- 退货&退款单列表
left 	join STG_New_OMS.Omni_Retail_Return_Gds_De item	-- 退货&退款商品明细
on 		[return].id = item.return_bill_id
left    join STG_New_OMS.Omni_Retail_Order_Bill o
on      [return].order_bill_id = o.id
and     [return].deal_code = o.source_bill_no
left 	join STG_IMS.Gds_Btsinglprodu sku
on 		item.single_product_id = sku.id
left    join STG_IMS.Bas_Warehouse ware
on      [return].return_warehouse_id = ware.id
--and     [return].return_warehouse_code = ware.code
left    join STG_IMS.SYS_Dict_Detail dict
on      [return].platform_id = dict.id
where   [return].return_shipping_status = '6'
END
GO
