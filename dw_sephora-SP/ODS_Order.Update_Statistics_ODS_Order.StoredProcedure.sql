/****** Object:  StoredProcedure [ODS_Order].[Update_Statistics_ODS_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Order].[Update_Statistics_ODS_Order] AS 
begin
update statistics ODS_Order.Order_Promotion;
update statistics ODS_Order.Order_Source;
update statistics ODS_Order.OrderItems;
update statistics ODS_Order.Orders;
end

GO
