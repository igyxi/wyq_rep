/****** Object:  StoredProcedure [TEMP].[SP_DW_OMS_Refund_Order_Bak_20230506]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_OMS_Refund_Order_Bak_20230506] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       houshuangqiang     Initial Version
-- 2023-04-20       houshuangqiang     add column
-- 2023-04-24       zeyuan             修改主题域 
-- ========================================================================================
truncate table DW_OMS_Order.DW_OMS_Refund_Order;
insert into DW_OMS_Order.DW_OMS_Refund_Order
select  [return].bill_no as refund_no
        ,case when channel.code = 'jingdong' then 'JD'
              when channel.code = 'douyinxiaodian' then 'DOUYIN'
              when channel.code = 'taobao' then 'TMALL'  -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
              else upper(channel.code)
        end as channel_code
        ,[return].shop_code as sub_channel_code
--        ,store.code
--        ,store.name as sub_channel_name
        ,task.status as refund_status
        ,case when task.status = 0 then N'退款中'
                  when task.status = 1 then N'退款成功'
                  when task.status = 2 then N'退款失败'
                  when task.status = 3 then N'等待退款'
                  when task.status = 4 then N'无需退款'
        end as refund_status_name
        ,[return].return_order_type as refund_type
        ,case when [return].return_order_type = 1 then N'退货'
              when [return].return_order_type = 2 then N'追件'
              when [return].return_order_type = 3 then N'拒收'
        end as refund_type_name -- 退单类型1退货2追件3拒收
        ,[return].return_reason as refund_reason
        ,[return].apply_time                                                                                               
        ,[return].complete_date as refund_time
        ,[return].returned_amount as refund_amount
        ,[return].total_amount as product_amount
        ,[return].shipping_fee as delivery_amount
        ,return_shipping_status as product_in_status -- 退货物流状态：0未收货、1已收货,未入库、2已入库、3可入库、4已退回给客户
        ,shipping_status as product_out_status       -- 发货物流状态：0未收货、1已收货,未入库、2已入库、3可入库、4已退回给客户
        ,[return].desensitization_receiver_tel as refund_mobile
        ,[return].remark as refund_comments
		,1 return_pos_flag --  是否生成负销售创建记录标记 1表示去生成负销售 0为不去生成负销售
		,'RETURNED' as refund_source
        ,[return].deal_code as sales_order_number
        ,[return].relate_order_bill_no as purchase_order_number
        ,[return].vip_card_no as member_card_no
        ,sku.code as item_sku_code
        ,sku.name as item_sku_name
        ,item.return_qty as item_quantity
        ,coalesce(item.payed_amount, 0) + coalesce(item.discount_fee, 0) as item_total_amount
        ,item.payed_amount as item_apportion_amount
        ,item.discount_fee as item_discount_amount
        ,'' as sync_type
        ,[return].is_push_sap as sync_status
--        ,[return].push_return_pos as sync_status
        ,null as sync_time
        ,invoice.invoice_id
        ,[return].create_date as create_time
--       ,[return].data_update_time as update_time
	    ,[return].data_update_time as update_time
--        ,case when [return].return_amount_status =  退款状态 0-退款中，1-退款成功，2-退款失败 3-等待退款 4-无需退款
		,0 as is_delete
		,current_timestamp as insert_timestamp
from    ODS_New_OMS.ORD_Retail_Return_Bill [return]
left    join ODS_New_OMS.OMNI_Refund_Task_Bill as task
on      task.refund_bill_no = [return].bill_no
left    join ODS_New_OMS.ORD_Retail_Return_GDS_DE item
on      [return].id = item.return_bill_id
left    join ODS_OIMS_Goods.Gds_Btsinglprodu sku
on      item.single_product_id = sku.id
left    join ODS_OIMS_System.SYS_Dict_Detail channel
on      [return].platform_id = channel.id
left    join ODS_New_OMS.OMNI_Retail_Order_Receipt invoice
on      [return].bill_no = invoice.bill_no
--left    join ODS_OMS_Order.Oms_Sync_Order_To_Returnpos returnpos
--on
where   task.status = 1
and     refund_bill_type = '0'  -- EB 退款订单
--left    join STG_IMS.Bas_Channel_stg store
--on 		[return].shop_id = store.id
;
END
GO
