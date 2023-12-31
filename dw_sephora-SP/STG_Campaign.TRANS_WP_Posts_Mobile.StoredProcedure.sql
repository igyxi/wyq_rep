/****** Object:  StoredProcedure [STG_Campaign].[TRANS_WP_Posts_Mobile]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Campaign].[TRANS_WP_Posts_Mobile] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-19       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Campaign.WP_Posts_Mobile;
insert into STG_Campaign.WP_Posts_Mobile
select 
		ID,
		post_author,
		post_date,
		post_date_gmt,
		case when trim(post_content) in ('','null') then null else trim(post_content) end as post_content,
		case when trim(post_title) in ('','null') then null else trim(post_title) end as post_title,
		case when trim(post_excerpt) in ('','null') then null else trim(post_excerpt) end as post_excerpt,
		case when trim(post_status) in ('','null') then null else trim(post_status) end as post_status,
		case when trim(comment_status) in ('','null') then null else trim(comment_status) end as comment_status,
		case when trim(ping_status) in ('','null') then null else trim(ping_status) end as ping_status,
		case when trim(post_password) in ('','null') then null else trim(post_password) end as post_password,
		case when trim(post_name) in ('','null') then null else trim(post_name) end as post_name,
		case when trim(to_ping) in ('','null') then null else trim(to_ping) end as to_ping,
		case when trim(pinged) in ('','null') then null else trim(pinged) end as pinged,
		post_modified,
		post_modified_gmt,
		case when trim(post_content_filtered) in ('','null') then null else trim(post_content_filtered) end as post_content_filtered,
		post_parent,
		case when trim(guid) in ('','null') then null else trim(guid) end as guid,
		menu_order,
		case when trim(post_type) in ('','null') then null else trim(post_type) end as post_type,
		case when trim(post_mime_type) in ('','null') then null else trim(post_mime_type) end as post_mime_type,
        comment_count,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by ID order by dt desc) rownum from [ODS_Campaign].[WP_Posts_Mobile]
) t
where rownum = 1
END
GO
