/****** Object:  StoredProcedure [STG_OMS].[Update_Statistics_STG_OMS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[Update_Statistics_STG_OMS] AS 
BEGIN
update statistics STG_OMS.Merge_Order_Log;
update statistics STG_OMS.Order_Guid_Info;
update statistics STG_OMS.OMS_Exchange_Apply_Order;
update statistics STG_OMS.OMS_Exchange_Apply_Order_Item;
update statistics STG_OMS.OMS_Inventory_Allocate_Data;
update statistics STG_OMS.OMS_Inventory_Allocate_Log;
update statistics STG_OMS.OMS_Order_Refund;
update statistics STG_OMS.OMS_Order_Return;
update statistics STG_OMS.OMS_Order_Return_Item;
update statistics STG_OMS.OMS_Partial_Cancel_Apply_Order;
update statistics STG_OMS.OMS_Partial_Cancel_Item;
update statistics STG_OMS.OMS_Refund_Apply_Order;
update statistics STG_OMS.OMS_Refund_Order_Items;
update statistics STG_OMS.OMS_SAP_Actual_Inventory;
update statistics STG_OMS.OMS_Sap_Shipping;
update statistics STG_OMS.OMS_Stkin_DTL;
update statistics STG_OMS.OMS_Stkin_HD;
update statistics STG_OMS.OMS_Sync_Orders_To_SAP;
update statistics STG_OMS.OMS_SYNC_Store_INV_Data;
update statistics STG_OMS.Online_Return_Apply_Order;
update statistics STG_OMS.Online_Return_Apply_Order_Item;
update statistics STG_OMS.Online_Stkin_Order;
update statistics STG_OMS.Online_Stkin_Order_Item;
update statistics STG_OMS.Purchase_Logistics;
update statistics STG_OMS.Purchase_Order;
update statistics STG_OMS.Purchase_Order_Address;
update statistics STG_OMS.Purchase_Order_Item;
update statistics STG_OMS.Purchase_To_SAP;
update statistics STG_OMS.Sales_Order;
update statistics STG_OMS.Sales_Order_Address;
update statistics STG_OMS.Sales_Order_Item;
update statistics STG_OMS.Sales_Order_Payment;
update statistics STG_OMS.Sales_Order_Promo;
update statistics STG_OMS.Sap_Order_Cancel_Task;
END
GO
