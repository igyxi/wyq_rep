/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Offer_Code_EB_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Offer_Code_EB_REL] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Promotion.Offer_Code_EB_REL ;
insert into STG_Promotion.Offer_Code_EB_REL
select 
    offer_rel_id,
    case when trim(lower(offer_code)) in ('null','') then null else trim(offer_code) end as offer_code,
    case when trim(lower(promotion_id)) in ('null','') then null else trim(promotion_id) end as promotion_id,
    code_type,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
    ODS_Promotion.Offer_Code_EB_REL
where dt = @dt;
delete from ODS_Promotion.Offer_Code_EB_REL where dt <= format(DATEADD(day, -7, @dt), 'yyyy-MM-dd');
END
GO
