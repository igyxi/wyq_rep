/****** Object:  StoredProcedure [ODS_OrderCenter].[Update_Statistics_ODS_OrderCenter]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OrderCenter].[Update_Statistics_ODS_OrderCenter] AS 
begin
update statistics ODS_OrderCenter.Offline_OrderItems;
update statistics ODS_OrderCenter.Offline_Orders;
end
GO
