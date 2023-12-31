/****** Object:  StoredProcedure [STG_Promotion].[TRANS_CRM_Coupon]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_CRM_Coupon] AS
BEGIN
truncate table STG_Promotion.CRM_Coupon;
insert into STG_Promotion.CRM_Coupon
select 
    id,
    case when trim(card_num) in ('null','') then null else trim(card_num) end as card_num,
    case when trim(offer_id) in ('null','') then null else trim(offer_id) end as offer_id,
    case when trim(crm_coupon_id) in ('null','') then null else trim(crm_coupon_id) end as crm_coupon_id,
    case when trim(crm_status) in ('null','') then null else trim(crm_status) end as crm_status,
    start_time,
    end_time,
    create_time,
    update_time,
    case when trim(status) in ('null','') then null else trim(status) end as status,
    sharding_param,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Promotion.CRM_Coupon
) t
where rownum = 1
END
GO
