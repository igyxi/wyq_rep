/****** Object:  StoredProcedure [TEMP].[SP_Fact_OMS_Refund_Order_Bak_20230605]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_OMS_Refund_Order_Bak_20230605] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-20       houshuangqiang           initial(new oms)
-- ========================================================================================
truncate table DWD.Fact_OMS_Refund_Order;
insert into DWD.Fact_OMS_Refund_Order
select
    t.refund_no,
    so.channel_code,
    so.sub_channel_code,
    so.store_code as store_code,
    t.refund_status,
    t.refund_type,
    t.refund_reason,
    t.apply_time,
    t.refund_time,
    t.refund_amount,
    t.product_amount,
    t.delivery_amount,
    t.product_in_status,
    t.product_out_status,
    t.refund_mobile,
    t.refund_comments,
    t.return_pos_flag,
    t.refund_source,
    t.sales_order_number,
    isnull(t.purchase_order_number, so.purchase_order_number) as purchase_order_number,
    so.member_card,
    so.order_status,
    so.is_placed,
    so.place_time,
    t.item_sku_name,
    t.item_sku_code,
    t.item_quantity,
    t.item_total_amount,
    t.item_apportion_amount,
    t.item_discount_amount,
    t.sync_type,
    t.sync_status,
    t.sync_time,
    t.create_time as create_time,
    t.update_time as update_time,
    t.is_delete,
    'New OMS' as source,
    current_timestamp as insert_timestamp
from
    DW_OMS_Order.DW_OMS_Refund_Order t
join
(
    select 
        distinct sales_order_number, 
        purchase_order_number, 
        channel_code, 
        sub_channel_code, 
        store_code, 
        member_card, 
        order_status, 
        is_placed, 
        place_time 
    from DWD.Fact_OMS_Sales_Order_New
--     where source = 'OMS'
)so
on t.sales_order_number = so.sales_order_number
and (t.purchase_order_number = so.purchase_order_number or t.purchase_order_number is null)
where t.refund_no is not null
;
end
GO
