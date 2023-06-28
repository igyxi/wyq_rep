/****** Object:  StoredProcedure [STG_OrderHub].[Update_Statistics_STG_OrderHub]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[Update_Statistics_STG_OrderHub] AS 
begin
update statistics [STG_OrderHub].[Refund_Order_Item];
update statistics [STG_OrderHub].[Refund_Order];
update statistics [STG_OrderHub].[Store_Order_Item];
update statistics [STG_OrderHub].[Store_Order_Record];
update statistics [STG_OrderHub].[Store_Order_Statistics];
update statistics [STG_OrderHub].[Store_Order];
end
GO
