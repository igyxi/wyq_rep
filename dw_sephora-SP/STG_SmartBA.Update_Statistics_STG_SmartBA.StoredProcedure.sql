/****** Object:  StoredProcedure [STG_SmartBA].[Update_Statistics_STG_SmartBA]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[Update_Statistics_STG_SmartBA] AS
begin
-- update statistics STG_SmartBA.SmartBA;
update statistics STG_SmartBA.T_Order;
update statistics STG_SmartBA.T_Order_Detail;
update statistics STG_SmartBA.T_Order_Package;
update statistics STG_SmartBA.T_Order_Package_Detail;
update statistics STG_SmartBA.T_Order_Refund;
update statistics STG_SmartBA.T_Order_Refund_Detail;
update statistics STG_SmartBA.T_WXChat_Sale;
update statistics STG_SmartBA.T_WXChat_Sale_Config;
update statistics STG_SmartBA.BA_Transfer_History;
update statistics STG_SmartBA.Staff_Info;
update statistics STG_SmartBA.Customer_Staff_REL;
end

GO
