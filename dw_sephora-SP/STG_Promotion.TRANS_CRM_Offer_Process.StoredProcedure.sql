/****** Object:  StoredProcedure [STG_Promotion].[TRANS_CRM_Offer_Process]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_CRM_Offer_Process] AS
BEGIN
truncate table STG_Promotion.CRM_Offer_Process;
insert into STG_Promotion.CRM_Offer_Process
select 
    case when trim(offer_id) in ('null','') then null else trim(offer_id) end as offer_id,
    case when trim(offer_name) in ('null','') then null else trim(offer_name) end as offer_name,
    case when trim(display_txt) in ('null','') then null else trim(display_txt) end as display_txt,
    case when trim(promotion_code) in ('null','') then null else trim(promotion_code) end as promotion_code,
    start_time,
    end_time,
    case when trim(offer_type) in ('null','') then null else trim(offer_type) end as offer_type,
    case when trim(display_flag) in ('null','') then null else trim(display_flag) end as display_flag,
    case when trim(status) in ('null','') then null else trim(status) end as status,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by offer_id order by dt desc) rownum from ODS_Promotion.CRM_Offer_Process
) t
where rownum = 1;
END
GO
