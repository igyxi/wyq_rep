/****** Object:  StoredProcedure [TEMP].[SP_RPT_Refund_of_Return_Order_Bak_20230316]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Refund_of_Return_Order_Bak_20230316] AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-03-10       wangzhichun 
-- ========================================================================================
truncate table [DW_OMS].[RPT_Refund_of_Return_Order_New];
insert into [DW_OMS].[RPT_Refund_of_Return_Order_New]
select
    b.refund_no,--退单号
    b.oms_order_code,--平台订单号（需要匹配回正向单原来的订单号
    b.refund_sum,--退款金额
    item.apply_qty as item_apply_qty,--退款商品数量
    item.sku_code as item_sku_cd,--退款商品编码
    b.store_id,--退款店铺/平台
    b.refund_type,--退款单类型
    b.refund_status,--退款状态
    b.apply_time,--退款申请时间
    b.refund_time,--退款完成时间
    current_timestamp as inster_timestamp
from
    STG_OMS.OMS_Order_Refund b
-- left join
--    STG_OMS.OMS_Refund_Apply_Order a
-- on 
--     a.refund_code = b.refund_no
left join
    STG_OMS.OMS_Refund_Order_Items item
on 
    b.oms_refund_apply_order_sys_id = item.oms_refund_apply_order_sys_id
where 
    b.refund_type in ('RETURN_REFUND','ONLINE_RETURN_REFUND')

-- 直接从DWD.Fact_Refund_Order取，数据量会变多，因为会取到STG_OMS.Online_Return_Apply_Order_Item表中的sku_code,而原表是从
-- STG_OMS.OMS_Refund_Order_Items中取的，部分数据的item_sku_code是空的

-- select 
--     refund.refund_number as refund_no,--退单号
--     refund.sales_order_number as oms_order_code,--平台订单号（需要匹配回正向单原来的订单号
--     refund.refund_amount as refund_sum,--退款金额
--     refund.item_quantity,--退款商品数量
--     refund.item_sku_code,--退款商品编码
--     refund.store_code,--退款店铺/平台
--     refund.refund_type,--退款单类型
--     refund.refund_status,--退款状态
--     refund.apply_time,--退款申请时间
--     refund.refund_time,--退款完成时间
--     current_timestamp as inster_timestamp
-- from    
--     DWD.Fact_Refund_Order refund
-- where refund.refund_type in ('RETURN_REFUND','ONLINE_RETURN_REFUND')
-- and source='OMS'
;
END 

GO
