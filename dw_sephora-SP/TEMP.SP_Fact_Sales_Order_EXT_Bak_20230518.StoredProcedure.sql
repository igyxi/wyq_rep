/****** Object:  StoredProcedure [TEMP].[SP_Fact_Sales_Order_EXT_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Sales_Order_EXT_Bak_20230518] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-22       Tali           Initial Version
-- 2022-11-29       houshuangqiang add sap_ex_vat_amount
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
    b.Store_Code as sap_store_code,
    a.source,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DWD.Fact_Sales_Order a
left join
    DW_SAP.DWS_Sales_Ticket b
on a.invoice_id = b.combine_number
and a.store_code = b.store_code
and a.item_sku_code = b.item_sku_code
;
END
GO
