/****** Object:  StoredProcedure [dbo].[usp_update_factAccount_offer]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_update_factAccount_offer] AS
BEGIN
   delete a from  [ODS_CRM].[FactAccount_Offer] a
where exists(select 1 
from [STG_CRM].[FactAccount_Offer] b
where a.[account_offer_id] = b.[account_offer_id])

insert [ODS_CRM].[FactAccount_Offer]
SELECT 
[account_offer_id]
      ,[account_id]
      ,[product_id]
      ,[status]
      ,[create_time]
      ,[qty]
      ,[from_date]
      ,[to_date]
      ,[used_time]
      ,[used_times]
      ,[expired_time]
      ,[expired_times]
      ,[country]
      ,[is_boutique]
      ,[boutique_points]
      ,[offer_name]
      ,[sku]
      ,[article_order_id]
      ,[offer_id]
      ,[offer_type_id]
      ,[Offer_CardType]
      ,[process_time]
FROM [STG_CRM].[FactAccount_Offer]

END
GO
