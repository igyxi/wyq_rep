/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_Refund_of_Return_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_Refund_of_Return_Order] AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-03-10       wangzhichun        channge source table
-- ========================================================================================
truncate table [DW_OMS].[RPT_Refund_of_Return_Order];
insert into [DW_OMS].[RPT_Refund_of_Return_Order]
select 
    refund.refund_number as refund_code,--退单号
    refund.sales_order_number,--平台订单号（需要匹配回正向单原来的订单号
    refund.refund_amount as actual_total_fee,--退款金额
    refund.item_quantity as item_apply_qty,--退款商品数量
    refund.item_sku_code as item_sku_cd,--退款商品编码
    refund.store_code as store_id ,--退款店铺/平台
    refund.refund_type,--退款单类型
    refund.refund_status as process_status,--退款状态
    refund.apply_time,--退款申请时间
    refund.refund_time,--退款完成时间
    current_timestamp as inster_timestamp
from    
    DWD.Fact_Refund_Order refund
where refund.refund_type in ('RETURN_REFUND','ONLINE_RETURN_REFUND')
and source='OMS'

;
END 

GO
