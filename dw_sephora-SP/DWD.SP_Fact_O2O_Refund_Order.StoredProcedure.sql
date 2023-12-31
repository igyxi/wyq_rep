/****** Object:  StoredProcedure [DWD].[SP_Fact_O2O_Refund_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_O2O_Refund_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description      version
-- ----------------------------------------------------------------------------------------
-- 2022-10-20       houshuangqiang   O2O退款订单     Initial Version, 最终版需要合并到DWD.Fact_Refund_Order下 union all 上去
-- 2022-10-23       houshuangqiang   O2O退款订单     delete join DWS_Store_Order_With_SKU
-- 2023-03-18       chenwei                          修改[DW_NEW_OMS].[DWS_Refund_Order]表名为[DW_OMS_Order].[DW_O2O_Refund_Order]
-- ========================================================================================
truncate table [DWD].[Fact_O2O_Refund_Order];
insert into DWD.Fact_O2O_Refund_Order
select
    p.refund_no as refund_number,
    p.channel_code,
    p.channel_name,
    p.store_code,
    p.refund_status,
    p.refund_type,
    p.refund_reason,
    p.apply_time,
    p.refund_time,
    p.refund_amount,
    p.product_amount,
    p.delivery_amount,
    p.refund_mobile,
    p.refund_comments as comments,
    p.return_pos_flag,
    p.sales_order_number,
    p.purchase_order_number,
    p.member_card,
    p.is_placed,
    p.place_time,
    p.item_sku_code,
--    t.eb_sku_name as item_sku_name, -- new_oms表中的item_sku_name与dim_sku_info中的eb_sku_name不一致，在这里使用eb_sku_name，上游表的DWS_Refund_Order中的item_sku_name可能会删除
    p.item_sku_name,
    p.item_quantity,
    p.item_total_amount,
    p.item_apportion_amount,
    p.item_discount_amount,
    p.sync_type,
    p.sync_status,
    p.sync_time,
    p.create_time as create_time,
    p.update_time as update_time,
    p.is_delete,
    'O2O' as source,
    current_timestamp as insert_timestamp
from
    [DW_OMS_Order].[DW_O2O_Refund_Order] p
--left
--	join DWD.DIM_SKU_Info t
--on  p.item_sku_code = t.sku_code
END


-- select top 100 * from DWD.Fact_O2O_Refund_Order
GO
