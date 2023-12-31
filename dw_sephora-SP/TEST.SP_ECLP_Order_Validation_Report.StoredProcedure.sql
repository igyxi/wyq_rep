/****** Object:  StoredProcedure [TEST].[SP_ECLP_Order_Validation_Report]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_ECLP_Order_Validation_Report] AS
BEGIN

truncate table TEST.ECLP_Order_Validation_Report; 

INSERT INTO TEST.ECLP_Order_Validation_Report
SELECT
a.[create_time] as [OMS_Order_CreateTime],
a.[purchase_order_sys_id],
b.invoice_id as [SAP InvoiceID],
c.Store_Code as Plant,
--Material_Code as [SKU ID],
a.[item_sku] as [SKU ID],
a.[item_name] as [SKU Name], -- SKU名称
right(till_number,3) as [From Location],
d.sales_order_number as [PO order ID],
d.purchase_order_number as [SAP order ID],
d.order_internal_status as [Order Status],
--c.ticket_date as [stock change date],
--[stock change time],
--a.Quantity as [OMS_Qty],
c.Quantity as [SAP_Qty],
a.apportion_amount as [OMS_Payed_Amount], --OMS支付金额
a.[item_quantity] as [OMS_Item_Quantity],
--d.shipping_total as [OMS_Shipping_Fee], --OMS运费金额
c.Sales_VAT as [SAP_Sales_VAT],
c.[Quantity] as [SAP_Quantity]
FROM [STG_OMS].[Purchase_Order_Item] a
JOIN [STG_OMS].[Purchase_Order] d
    ON a.[purchase_order_sys_id] = d.[purchase_order_sys_id]
JOIN [STG_OMS].[Purchase_To_SAP] b
    ON d.purchase_order_number = b.[purchase_order_number] --and a.[item_sku] = b.Material_Code
LEFT JOIN [ODS_SAP].[Sales_Ticket] c
    ON b.invoice_id = case when isnumeric(c.[Transaction_Number]) = 1 then cast(c.[Transaction_Number] as bigint) else 0 end
        AND a.[item_sku] = c.Material_Code collate SQL_Latin1_General_CP1_CI_AS
WHERE 1 = 1
        AND d.channel_id = 'JD'
        AND a.create_time >= FORMAT(DATEADD(DAY,-200,GETDATE()),'yyyy-MM-dd');
        --AND a.create_time < GETDATE() 
        --AND a.create_time >= '2021-05-10'
END



GO
