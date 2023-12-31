/****** Object:  StoredProcedure [STG_Order].[TRANS_Order_Source]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Order].[TRANS_Order_Source] AS
BEGIN
truncate table STG_Order.Order_Source ;
insert into STG_Order.Order_Source
select 
    order_id,
    case when trim(lower(utm_source)) in ('null', '') then null else trim(utm_source) end as utm_source,
    case when trim(lower(utm_medium)) in ('null', '') then null else trim(utm_medium) end as utm_medium,
    case when trim(lower(utm_campaign)) in ('null', '') then null else trim(utm_campaign) end as utm_campaign,
    case when trim(lower(utm_term)) in ('null', '') then null else trim(utm_term) end as utm_term,
    case when trim(lower(utm_content)) in ('null', '') then null else trim(utm_content) end as utm_content,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by order_id order by dt desc) rownum from ODS_Order.Order_Source
) t
where rownum = 1
END


GO
