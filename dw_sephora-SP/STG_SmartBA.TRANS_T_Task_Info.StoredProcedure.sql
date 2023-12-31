/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Task_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Task_Info] @dt [varchar](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-14       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SmartBA.T_Task_Info;
insert into STG_SmartBA.T_Task_Info
select 
		id,
		task_id,
		rule_id,
		user_id,
		case when trim(wx_unionid) in ('','null','none') then null else trim(wx_unionid) end as wx_unionid,
		case when trim(head_img) in ('','null','none') then null else trim(head_img) end as head_img,
		case when trim(nickname) in ('','null','none') then null else trim(nickname) end as nickname,
		step,
		step_number,
		finsh_number,
		fill_num,
		amount,
		reward,
		case when trim(name) in ('','null','none') then null else trim(name) end as name,
		status,
		store_id,
		case when trim(store_name) in ('','null','none') then null else trim(store_name) end as store_name,
		company_id,
		case when trim(company_name) in ('','null','none') then null else trim(company_name) end as company_name,
		tenant_id,
		create_time,
		update_time,
		finish_time,
		current_timestamp as insert_timestamp
from 
    ODS_SmartBA.T_Task_Info
-- where 
--     dt=@dt
END
GO
