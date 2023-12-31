/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_Customer_Staff_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_Customer_Staff_REL] AS
BEGIN
truncate table STG_SmartBA.Customer_Staff_REL;
insert into STG_SmartBA.Customer_Staff_REL
select 
    id,
    case when trim(unionid) in ('null', '') then null else trim(unionid) end as unionid, 
    case when trim(staff_no) in ('null', '') then null else trim(staff_no) end as staff_no, 
    bind_time,
    case when trim(external_user_id) in ('null', '') then null else trim(external_user_id) end as external_user_id, 
    status,
    created_at,
    case when trim(shop_info_code) in ('null', '') then null else trim(shop_info_code) end as shop_info_code, 
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SmartBA.Customer_Staff_REL 
) t
where t.rownum = 1
END

GO
