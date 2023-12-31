/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Task]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Task] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SmartBA.T_Task;
insert into STG_SmartBA.T_Task
select 
		id,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		type,
		case when trim(task_desc) in ('','null') then null else trim(task_desc) end as task_desc,
		case when trim(target) in ('','null') then null else trim(target) end as target,
		case when trim(reward) in ('','null') then null else trim(reward) end as reward,
		case when trim(kpi_range) in ('','null') then null else trim(kpi_range) end as kpi_range,
		case when trim(kpi_rank) in ('','null') then null else trim(kpi_rank) end as kpi_rank,
		begin_time,
		end_time,
		is_reward,
		reward_number,
		step_number,
		is_allow,
		is_close,
		close_time,
		store_type,
		tenant_id,
		case when trim(create_at) in ('','null') then null else trim(create_at) end as create_at,
		create_time,
		case when trim(update_at) in ('','null') then null else trim(update_at) end as update_at,
		update_time,
		is_deleted,
		case when trim(page_title) in ('','null') then null else trim(page_title) end as page_title,
		case when trim(page_url) in ('','null') then null else trim(page_url) end as page_url,
		case when trim(product_ids) in ('','null') then null else trim(product_ids) end as product_ids,
		frequency,
		forward_num,
		case when trim(message) in ('','null') then null else trim(message) end as message,
		notice_time,
		case when trim(msg_id) in ('','null') then null else trim(msg_id) end as msg_id,
		posted_template,
		status,
		posted_notice,
		tag_customer_num,
		case when trim(tag_name) in ('','null') then null else trim(tag_name) end as tag_name,
		case when trim(tag_id) in ('','null') then null else trim(tag_id) end as tag_id,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SmartBA.T_Task
) t
where rownum = 1
END
GO
