/****** Object:  StoredProcedure [ODS_SmartBA].[Update_Statistics_ODS_SmartBA]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SmartBA].[Update_Statistics_ODS_SmartBA] AS
begin
--update statistics ODS_SmartBA.SmartBA;
update statistics ODS_SmartBA.T_Order;
update statistics ODS_SmartBA.T_Order_Detail;
update statistics ODS_SmartBA.T_Order_Package;
update statistics ODS_SmartBA.T_Order_Package_Detail;
update statistics ODS_SmartBA.T_Order_Refund;
update statistics ODS_SmartBA.T_Order_Refund_Detail;
update statistics ODS_SmartBA.T_WXChat_Sale;
update statistics ODS_SmartBA.T_WXChat_Sale_Config;
update statistics ODS_SmartBA.BA_Transfer_History;
update statistics ODS_SmartBA.Staff_Info;
update statistics ODS_SmartBA.Customer_Staff_REL;
end
GO
