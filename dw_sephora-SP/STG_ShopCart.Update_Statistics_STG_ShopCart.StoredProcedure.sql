/****** Object:  StoredProcedure [STG_ShopCart].[Update_Statistics_STG_ShopCart]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ShopCart].[Update_Statistics_STG_ShopCart] AS
begin
update statistics STG_ShopCart.Addr_City;
update statistics STG_ShopCart.Addr_Province;
end
GO
