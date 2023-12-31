/****** Object:  StoredProcedure [ODS_OMS_Order].[SP_IMP_OMS_Sync_Order_To_ESB]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS_Order].[SP_IMP_OMS_Sync_Order_To_ESB] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-27       wangzhichun           Initial Version
-- ========================================================================================
delete ods from ODS_OMS_Order.OMS_Sync_Order_To_ESB ods inner join STG.OMS_Sync_Order_To_ESB stg on ods.id = stg.id;

insert into ODS_OMS_Order.OMS_Sync_Order_To_ESB
select 
		id,
		case when trim(tid) in ('','null','None') then null else trim(tid) end as tid,
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		case when trim(biz_type) in ('','null','None') then null else trim(biz_type) end as biz_type,
		case when trim(sync_info) in ('','null','None') then null else trim(sync_info) end as sync_info,
		create_time,
		case when trim(api_method) in ('','null','None') then null else trim(api_method) end as api_method,
		case when trim(api_code) in ('','null','None') then null else trim(api_code) end as api_code,
		case when trim(return_content) in ('','null','None') then null else trim(return_content) end as return_content,
		start_date,
		end_date,
		case when trim(api_direction) in ('','null','None') then null else trim(api_direction) end as api_direction,
		case when trim(request_no) in ('','null','None') then null else trim(request_no) end as request_no,
		data_update_time,
		data_create_time,
		dt as dt
from  STG.OMS_Sync_Order_To_ESB
END
GO
