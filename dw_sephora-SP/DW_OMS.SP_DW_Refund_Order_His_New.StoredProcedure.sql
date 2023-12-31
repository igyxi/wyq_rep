/****** Object:  StoredProcedure [DW_OMS].[SP_DW_Refund_Order_His_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DW_Refund_Order_His_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-09       tali           Initial Version
-- 2022-07-10       tali           fix refund_number
-- 2022-10-11       wangzhichun    update
-- 2023-02-21	    houshuangqiang add product_in_status/product_out_status & rename table name
-- 2023-03-14       houshuangqiang 取消 basic_status = 'DELETED'的限制，因为ps两张报表数据切换数据源时，影响到这边的数据了, 下游取数时，需要注意refund_status状态
-- 2023-03-17       tali           add refund source
-- ========================================================================================
truncate table DW_OMS.DW_Refund_Order_His;
insert  into DW_OMS.DW_Refund_Order_His
select 	refund.refund_no
        ,refund.channel_code
        ,refund.sub_channel_code
        ,refund.refund_status
        ,refund.refund_type
        ,refund.refund_reason
        ,refund.apply_time
        ,refund.refund_time
        ,refund.refund_amount
        ,refund.product_amount
        ,refund.delivery_amount
        ,refund.product_in_status
        ,refund.product_out_status
        ,refund.refund_mobile
        ,refund.refund_comments
        ,refund.return_pos_flag
        ,refund.refund_source
        ,refund.sales_order_number
        ,refund.purchase_order_number
        ,refund.item_sku_code
        ,refund.item_sku_name
        ,refund.item_quantity
        ,refund.item_total_amount
        ,refund.item_apportion_amount
        ,refund.item_discount_amount
        ,refund.sync_type
        ,refund.sync_status
        ,refund.sync_time
        ,refund.invoice_id
        ,refund.create_time
        ,refund.update_time
        ,refund.is_delete
        ,current_timestamp insert_timestamp
from 	DW_OMS.DW_Refund_Order refund 
inner join stg_oms.oms_to_oims_sync_fail_log fail
on  refund.sales_order_number = fail.sales_order_number
and fail.sync_status = 1
and fail.update_time >= '2023-06-01 18:00:00'
end 
GO
