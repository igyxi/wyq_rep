/****** Object:  StoredProcedure [STG_Order].[Update_Statistics_STG_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Order].[Update_Statistics_STG_Order] AS 
begin
update statistics STG_Order.Order_Promotion;
update statistics STG_Order.Order_Source;
update statistics STG_Order.OrderItems;
update statistics STG_Order.Orders;
end

GO
