/****** Object:  StoredProcedure [ODS_ShopCart].[Update_Statistics_ODS_ShopCart]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_ShopCart].[Update_Statistics_ODS_ShopCart] AS
begin
update statistics ODS_ShopCart.Addr_City;
update statistics ODS_ShopCart.Addr_Province;
end
GO
