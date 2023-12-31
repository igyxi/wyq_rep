/****** Object:  StoredProcedure [TEMP].[TRANS_Staff_Info_Bak_20230619]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_Staff_Info_Bak_20230619] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_SmartBA.Staff_Info ;
insert into STG_SmartBA.Staff_Info
select  
    case when trim(userid) in ('null', '') then null else trim(userid) end as userid,
    case when trim(pwd) in ('null', '') then null else trim(pwd) end as pwd,
    case when trim(name) in ('null', '') then null else trim(name) end as name,
    case when trim(gender) in ('null', '') then null else trim(gender) end as gender,
    case when trim(bir) in ('null', '') then null else trim(bir) end as bir,
    case when trim(email) in ('null', '') then null else trim(email) end as email,
    case when trim(tel) in ('null', '') then null else trim(tel) end as tel,
    case when trim(fax) in ('null', '') then null else trim(fax) end as fax,
    case when trim(title) in ('null', '') then null else trim(title) end as title,
    case when trim(join_date) in ('null', '') then null else trim(join_date) end as join_date,
    case when trim(source) in ('null', '') then null else trim(source) end as source,
    case when trim(shop_info_code) in ('null', '') then null else trim(shop_info_code) end as shop_info_code,
    case when trim(fax_code) in ('null', '') then null else trim(fax_code) end as fax_code,
    case when trim(now_job_start_time) in ('null', '') then null else trim(now_job_start_time) end as now_job_start_time,
    case when trim(id_card_no) in ('null', '') then null else trim(id_card_no) end as id_card_no,
    case when trim(now_era_start_time) in ('null', '') then null else trim(now_era_start_time) end as now_era_start_time,
    case when trim(eba) in ('null', '') then null else trim(eba) end as eba,
    case when trim(role) in ('null', '') then null else trim(role) end as role,
    case when trim(leader) in ('null', '') then null else trim(leader) end as leader,
    case when trim(max_group) in ('null', '') then null else trim(max_group) end as max_group,
    case when trim(en_name) in ('null', '') then null else trim(en_name) end as en_name,
    case when trim(status) in ('null', '') then null else trim(status) end as status,
    created_at,
    modify_time,
    current_timestamp as insert_timestamp
from 
    ODS_SmartBA.Staff_Info 
where dt =  @dt
END

GO
