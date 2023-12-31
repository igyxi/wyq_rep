/****** Object:  StoredProcedure [ODS_OMS].[Update_Statistics_ODS_OMS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[Update_Statistics_ODS_OMS] AS 
BEGIN
update statistics ODS_OMS.Merge_Order_Log;
update statistics ODS_OMS.Mobile_Mapping;
update statistics ODS_OMS.OMS_Exchange_Apply_Order;
update statistics ODS_OMS.OMS_Exchange_Apply_Order_Item;
update statistics ODS_OMS.OMS_Inventory_Allocate_Data;
update statistics ODS_OMS.OMS_Inventory_Allocate_Log;
update statistics ODS_OMS.OMS_Order_Refund;
update statistics ODS_OMS.OMS_Order_Return;
update statistics ODS_OMS.OMS_Order_Return_Item;
update statistics ODS_OMS.OMS_Partial_Cancel_Apply_Order;
update statistics ODS_OMS.OMS_Partial_Cancel_Item;
update statistics ODS_OMS.OMS_Refund_Apply_Order;
update statistics ODS_OMS.OMS_Refund_Order_Items;
update statistics ODS_OMS.OMS_SAP_Actual_Inventory;
update statistics ODS_OMS.OMS_Sap_Shipping;
update statistics ODS_OMS.OMS_Stkin_DTL;
update statistics ODS_OMS.OMS_Stkin_HD;
update statistics ODS_OMS.OMS_Sync_Orders_To_SAP;
update statistics ODS_OMS.OMS_SYNC_Store_INV_Data;
update statistics ODS_OMS.Online_Return_Apply_Order;
update statistics ODS_OMS.Online_Return_Apply_Order_Item;
update statistics ODS_OMS.Online_Stkin_Order;
update statistics ODS_OMS.Online_Stkin_Order_Item;
update statistics ODS_OMS.Purchase_Logistics;
update statistics ODS_OMS.Purchase_Order;
update statistics ODS_OMS.Purchase_Order_Address;
update statistics ODS_OMS.Purchase_Order_Item;
update statistics ODS_OMS.Purchase_To_SAP;
update statistics ODS_OMS.Sales_Order;
update statistics ODS_OMS.Sales_Order_Address;
update statistics ODS_OMS.Sales_Order_Item;
update statistics ODS_OMS.Sales_Order_Payment;
update statistics ODS_OMS.Sales_Order_Promo;
update statistics ODS_OMS.Sap_Order_Cancel_Task;
update statistics ODS_OMS.OMS_KMS_Encrypt;
END
GO
