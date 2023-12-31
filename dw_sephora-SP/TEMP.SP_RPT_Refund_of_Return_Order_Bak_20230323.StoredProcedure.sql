/****** Object:  StoredProcedure [TEMP].[SP_RPT_Refund_of_Return_Order_Bak_20230323]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Refund_of_Return_Order_Bak_20230323] AS 
begin
truncate table [DW_OMS].[RPT_Refund_of_Return_Order];
insert into [DW_OMS].[RPT_Refund_of_Return_Order]
select
    b.refund_no,--退单号
    b.oms_order_code,--平台订单号（需要匹配回正向单原来的订单号
    b.refund_sum,--退款金额
    a.item_apply_qty,--退款商品数量
    a.item_sku_cd,--退款商品编码
    b.store_id,--退款店铺/平台
    b.refund_type,--退款单类型
    b.refund_status,--退款状态
    b.apply_time,--退款申请时间
    b.refund_time,--退款完成时间
    current_timestamp as inster_timestamp
from
    STG_OMS.OMS_Order_Refund b
left join
    DW_OMS.DWS_OMS_Refund_Apply_Order a
on 
    a.refund_code = b.refund_no
where 
    b.refund_type in ('RETURN_REFUND','ONLINE_RETURN_REFUND')
;
END 

GO
