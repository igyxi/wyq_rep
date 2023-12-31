/****** Object:  StoredProcedure [STG_Promotion].[TRANS_CRM_EB_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_CRM_EB_REL] AS
BEGIN
truncate table STG_Promotion.CRM_EB_REL;
insert into STG_Promotion.CRM_EB_REL
select 
    case when trim(crm_promotion_code) in ('null','') then null else trim(crm_promotion_code) end as crm_promotion_code,
    case when trim(promotion_id) in ('null','') then null else trim(promotion_id) end as promotion_id,
    coupon_type,
    case when trim(descrption) in ('null','') then null else trim(descrption) end as descrption,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by crm_promotion_code order by dt desc) rownum from ODS_Promotion.CRM_EB_REL
) t
where rownum = 1;
END
GO
