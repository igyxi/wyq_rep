/****** Object:  StoredProcedure [DWD].[SP_Fact_Sales_Order_EXT]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Sales_Order_EXT] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-22       Tali           Initial Version
-- 2022-11-29       houshuangqiang add sap_ex_vat_amount
-- 2023-05-16       wangzhichun    update DW_SAP.DWS_Sales_Ticket
-- ========================================================================================
truncate table DWD.Fact_Sales_Order_EXT;
insert into DWD.Fact_Sales_Order_EXT
select
    a.sales_order_number,
    a.purchase_order_number,
    a.invoice_id,
    a.item_sku_code,
    b.item_cogs,
    b.ticket_date,
    b.ticket_hour,
    b.item_quantity as sap_quantity,
    b.item_amount as sap_amount,
    b.item_ex_vat_amount as sap_ex_vat_amount,
    b.store_code as sap_store_code,
    a.source,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DWD.Fact_Sales_Order a
left join
(
    select
        case when sap.Till_Number in ('0000000997','0000000999','0000000998') then Transaction_Number
            when m.channel_code is not null then cast(try_cast(Transaction_Number as bigint) as nvarchar)
            else sap.combine_number end as combine_number
        ,item_cogs
        ,ticket_date
        ,ticket_hour
        ,item_quantity
        ,item_amount
        ,item_ex_vat_amount
        ,sap.store_code
        ,item_sku_code
    from 
        DW_SAP.DWS_Sales_Ticket sap
    left join 
        DWD.DIM_Store m 
    on sap.store_code=m.store_code
) b
on a.invoice_id = b.combine_number
and a.store_code = b.store_code
and a.item_sku_code = b.item_sku_code
;
END
GO
