/****** Object:  StoredProcedure [STG_Promotion].[Update_Statistics_STG_Promotion]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[Update_Statistics_STG_Promotion] AS
begin
update statistics STG_Promotion.Promotion;
update statistics STG_Promotion.PX_Coupon;
end
GO
