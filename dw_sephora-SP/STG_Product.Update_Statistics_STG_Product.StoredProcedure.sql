/****** Object:  StoredProcedure [STG_Product].[Update_Statistics_STG_Product]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[Update_Statistics_STG_Product] AS 
begin
update statistics STG_Product.PROD_ATTR;
update statistics STG_Product.PROD_Attrval;
update statistics STG_Product.PROD_Group;
update statistics STG_Product.PROD_Product;
update statistics STG_Product.PROD_Product_Comment;
update statistics STG_Product.PROD_Product_Group_REL;
update statistics STG_Product.PROD_Product_Score;
update statistics STG_Product.PROD_SKU;
update statistics STG_Product.PROD_SKU_Attrval_REL;
update statistics STG_Product.PROD_VB_SKU_REL;
update statistics STG_Product.SAP_SKU;
update statistics STG_Product.PROD_Product_DESC;
update statistics STG_Product.PROD_SKU_Image;
end
GO
