/****** Object:  StoredProcedure [TEMP].[SP_DWS_O2O_Sales_Ticket]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_O2O_Sales_Ticket] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-21       houshuangqiang    O2O SKU级发票信息表      Initial Version
-- ========================================================================================
truncate table DW_New_OMS.DWS_O2O_Sales_Ticket;
insert into DW_New_OMS.DWS_O2O_Sales_Ticket
select
--    receipt_number, -- 发票号为什么空，transaction_number 是发票号吗《
    ticket.invoice_id as combine_number,
    ticket.invoice_id as transaction_number, -- 在DW_SAP.DWS_Sales_Ticket表中combine_number和transaction_number有区别，transaction_number多几个00000
    --null as till_number,
	ticket.invoice_id  as till_number, -- 这里的编号是什么？
	format(ticket.create_time, 'yyyyMMdd') as ticket_date,
	concat(format(ticket.create_time, 'HH'),'00') as ticket_hour,
    ticket.store_code,
    item.barcode as item_sku_code,
--    sku.item_amount,
    item.qty as item_quantity,
    item.invoice_price_total as item_amount,
--	sum(item.invoice_price_total) over(partition by item.retail_order_bill_id) as sum_invoice_price_total,
--    ticket.receipt_price,	-- 开票金额
--	ticket.amount,		-- 实付金额
--	ticket.discount_amount, -- 订单商家总额
    null as item_cogs,  -- item_cogs 是什么？
    'O2O' as source,
    current_timestamp as insert_timestamp
--	ticket.need_invoice_flag
from
    STG_New_OMS.OMNI_Retail_Order_Receipt ticket
left  join
    STG_New_OMS.OMNI_Retail_Order_Bill po
on  ticket.bill_id = po.id
left join
    STG_New_OMS.Omni_Retail_Ord_Goods_Detail item
on  po.id = item.retail_order_bill_id
where ticket.invoice_id is not null
--where ticket.need_invoice_flag = 1, 现在这个状态为NULL
;
END
GO
