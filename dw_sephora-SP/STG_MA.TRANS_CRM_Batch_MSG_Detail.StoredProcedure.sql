/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Batch_MSG_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Batch_MSG_Detail] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-14       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Batch_MSG_Detail;
insert into STG_MA.CRM_Batch_MSG_Detail
select 
	id,
	batch_msg_id,
	case when trim(mobile) in ('','null') then null else trim(mobile) end as mobile,
	case when trim(open_id) in ('','null') then null else trim(open_id) end as open_id,
	case when trim(mail) in ('','null') then null else trim(mail) end as mail,
	case when trim(store_no) in ('','null') then null else trim(store_no) end as store_no,
	case when trim(store_name) in ('','null') then null else trim(store_name) end as store_name,
	case when trim(store_phone) in ('','null') then null else trim(store_phone) end as store_phone,
	case when trim(campaign_time) in ('','null') then null else trim(campaign_time) end as campaign_time,
	case when trim(campaign_address) in ('','null') then null else trim(campaign_address) end as campaign_address,
	case when trim(store_address) in ('','null') then null else trim(store_address) end as store_address,
	case when trim(field1) in ('','null') then null else trim(field1) end as field1,
	case when trim(field2) in ('','null') then null else trim(field2) end as field2,
	case when trim(field3) in ('','null') then null else trim(field3) end as field3,
	create_user_id,
	case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
	case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
	cast(concat_ws(' ',cast(create_date as date),concat_ws(':',substring(create_time,1,2),substring(create_time,3,2),substring(create_time,5,2))) as datetime)as create_datetime,
	update_user_id,
	case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
	case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
	version,
	case when trim(data_type) in ('','null') then null else trim(data_type) end as data_type,
	case when trim(ext_field) in ('','null') then null else trim(ext_field) end as ext_field,
	current_timestamp as insert_timestamp
from   
	ODS_MA.CRM_Batch_MSG_Detail
where dt =  @dt
END 
GO
