/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Task_Rule]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Task_Rule] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-14       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SmartBA.T_Task_Rule;
insert into STG_SmartBA.T_Task_Rule
select 
		id,
		task_id,
		begin_time,
		end_time,
		type,
		case when trim(link_url) in ('','null','none') then null else trim(link_url) end as link_url,
		case when trim(share_desc) in ('','null','none') then null else trim(share_desc) end as share_desc,
		case when trim(share_img) in ('','null','none') then null else trim(share_img) end as share_img,
		article_id,
		reward,
		activity_id,
		fill_num,
		amount,
		step,
		cd_id,
		tenant_id,
		case when trim(create_at) in ('','null','none') then null else trim(create_at) end as create_at,
		create_time,
		case when trim(update_at) in ('','null','none') then null else trim(update_at) end as update_at,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SmartBA.T_Task_Rule
) t
where rownum = 1
END
GO
