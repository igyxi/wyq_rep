/****** Object:  StoredProcedure [ODS_CRM].[usp_delete_object_records]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_CRM].[usp_delete_object_records] AS
begin
delete from  [ODS_CRM].DimAccount
where exists (select 1 from  [ODS_CRM].ODS_deleted_obj_record  a
where [ODS_CRM].DimAccount.account_id=a.obj_id and a.from_table_name='account') 

--delete from  [ODS_CRM].DimAccount_new
--where exists (select 1 from  [ODS_CRM].ODS_deleted_obj_record  a
--where [ODS_CRM].DimAccount_new.account_id=a.obj_id and a.from_table_name='account') 


delete  from  [ODS_CRM].DimAccount_Log
where exists (select 1 from  [ODS_CRM].ODS_deleted_obj_record  a
where [ODS_CRM].DimAccount_Log.account_log_id=a.obj_id and a.from_table_name='account_log') 

delete from  [ODS_CRM].DimAccount_Status_History
where exists (select 1 from  [ODS_CRM].ODS_deleted_obj_record  a
where [ODS_CRM].DimAccount_Status_History.up_down_log_id=a.obj_id and a.from_table_name='account_upgrade_downgrade_log') 

delete  from  [ODS_CRM].DimTrans
where exists (select 1 from  [ODS_CRM].ODS_deleted_obj_record  a
where [ODS_CRM].DimTrans.trans_id=a.obj_id and a.from_table_name='declaration') 


delete from  [ODS_CRM].FactAccount_Offer
where exists (select 1 from  [ODS_CRM].ODS_deleted_obj_record  a
where [ODS_CRM].FactAccount_Offer.account_offer_id=a.obj_id and a.from_table_name='account_offer') 


delete   from  [ODS_CRM].DimOperation
where exists (select 1 from  [ODS_CRM].ODS_deleted_obj_record  a
where [ODS_CRM].DimOperation.operation_id=a.obj_id and a.from_table_name='operation') 


	
delete  from  [ODS_CRM].FactTrans
where exists (select 1 from  [ODS_CRM].ODS_deleted_obj_record  a
where [ODS_CRM].FactTrans.detail_id=a.obj_id and a.from_table_name='purchase_detail') 
end
GO
