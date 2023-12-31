/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Coupon_Send_Record]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Coupon_Send_Record] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Coupon_Send_Record;
insert into STG_MA.CRM_Coupon_Send_Record
select 
		id,
		send_id,
		case when trim(act_instance_id) in ('','null') then null else trim(act_instance_id) end as act_instance_id,
		campaign_id,
		case when trim(coupon_code) in ('','null') then null else trim(coupon_code) end as coupon_code,
		case when trim(member_code) in ('','null') then null else trim(member_code) end as member_code,
		case when trim(error_code) in ('','null') then null else trim(error_code) end as error_code,
		case when trim(error_message) in ('','null') then null else trim(error_message) end as error_message,
		case when trim(request_id) in ('','null') then null else trim(request_id) end as request_id,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		create_time,
		case when trim(produce_type) in ('','null') then null else trim(produce_type) end as produce_type,
		current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_MA.CRM_Coupon_Send_Record
) t
where rownum = 1;
END
GO
