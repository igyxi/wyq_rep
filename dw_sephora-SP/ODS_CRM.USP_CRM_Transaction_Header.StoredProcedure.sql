/****** Object:  StoredProcedure [ODS_CRM].[USP_CRM_Transaction_Header]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_CRM].[USP_CRM_Transaction_Header] AS 

insert into [ODS_CRM].[CRM_Transaction_Header]
( [account_number]
      ,[place_code]
      ,[Invc_id]
      ,[Invc_no]
      ,[Created_date]
      ,[Modified_date]
      ,[Transaction_type]
      ,[Cashier_id]
      ,[Cashier_name]
      ,[Rounding_offset]
      ,[Orig_invc_id]
      ,[Orig_invc_no]
      ,[Comment1]
      ,[Comment2]
      ,[real_amount_currency]
      ,[SBS_NO]
      ,[Time_Stamp]
      ,[BatchNo]
      ,[CreateTime]
      ,[purchase_date]
	  ,declaration_id
	  --,TS
	  )
 select [account_number]
      ,[place_code]
      ,[Invc_id]
      ,[Invc_no]
      ,[Created_date]
      ,[Modified_date]
      ,[Transaction_type]
      ,[Cashier_id]
      ,[Cashier_name]
      ,[Rounding_offset]
      ,[Orig_invc_id]
      ,[Orig_invc_no]
      ,[Comment1]
      ,[Comment2]
      ,[real_amount_currency]
      ,[SBS_NO]
      ,[Time_Stamp]
      ,[BatchNo]
      ,[CreateTime]
      ,[purchase_date]
	  ,declaration_id
	  --,[TS]
from [STG_CRM].[STG_CRM_Transaction_Header]



GO
