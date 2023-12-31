/****** Object:  StoredProcedure [ODS_CRM].[usp_199_account_offer]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_CRM].[usp_199_account_offer] AS
delete a from ODS_CRM.account_Offer a
where exists (select 1 from STG_CRM.account_Offer b
where a.[account_Offer_id]=b.[account_offer_id])

insert into [ODS_CRM].[account_offer]
SELECT [account_offer_id]
      ,[offer_id]
      ,[account_id]
      ,[qty]
      ,[related_operation_id]
      ,[effective_from_date]
      ,[effective_to_date]
      ,[status]
      ,[active_flag]
      ,[create_time]
      ,[setting_time]
      ,[create_by]
      ,[setting_by]
      ,[operation_id]
      ,[used_time]
      ,[used_times]
      ,[exported_time]
      ,[communication_track_linked_obj_id]
      ,[redeem_times]
      ,[exported_flag]
      ,[is_first]
      ,[black_first_flag]
      ,[gold_first_flag]
      ,[expired_time]
      ,[expired_times]
      ,[remark]
      ,[has_redemption]
      ,[redemption_time]
      ,[timestamp]
      ,[place_id]
  FROM [STG_CRM].[account_offer]
GO
