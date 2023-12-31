/****** Object:  StoredProcedure [ODS_OrderHub].[Update_Statistics_ODS_OrderHub]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OrderHub].[Update_Statistics_ODS_OrderHub] AS 
begin
update statistics [ODS_OrderHub].[Refund_Order_Item];
update statistics [ODS_OrderHub].[Refund_Order];
update statistics [ODS_OrderHub].[Store_Order_Item];
update statistics [ODS_OrderHub].[Store_Order_Record];
update statistics [ODS_OrderHub].[Store_Order_Statistics];
update statistics [ODS_OrderHub].[Store_Order];
end
GO
