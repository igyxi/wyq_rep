/****** Object:  StoredProcedure [STG_Marketing].[TRANS_Activity_Store_Book_Time]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Marketing].[TRANS_Activity_Store_Book_Time] AS
BEGIN
truncate table STG_Marketing.Activity_Store_Book_Time;
insert into STG_Marketing.Activity_Store_Book_Time
select 
	id,
    case when trim(store_code) in ('null','') then null else trim(store_code) end as store_code,
    case when trim(activity_id) in ('null','') then null else trim(activity_id) end as activity_id,
    start_date,
	end_date,
	start_time,
	service_time,
	interval_time,
	service_member,
	service_number,
	lunch_break_start,
	lunch_break_end,
	is_deleted,
	case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
	create_time,
	case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
	update_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Marketing.Activity_Store_Book_Time
) t
where rownum = 1;
END
GO
