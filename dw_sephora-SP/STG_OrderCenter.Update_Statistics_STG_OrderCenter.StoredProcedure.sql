/****** Object:  StoredProcedure [STG_OrderCenter].[Update_Statistics_STG_OrderCenter]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderCenter].[Update_Statistics_STG_OrderCenter] AS 
begin
update statistics STG_OrderCenter.Offline_OrderItems;
update statistics STG_OrderCenter.Offline_Orders;
end
GO
