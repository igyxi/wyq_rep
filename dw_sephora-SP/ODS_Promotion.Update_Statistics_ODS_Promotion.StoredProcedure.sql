/****** Object:  StoredProcedure [ODS_Promotion].[Update_Statistics_ODS_Promotion]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Promotion].[Update_Statistics_ODS_Promotion] AS
begin
update statistics ODS_Promotion.Promotion;
update statistics ODS_Promotion.PX_Coupon;
end
GO
