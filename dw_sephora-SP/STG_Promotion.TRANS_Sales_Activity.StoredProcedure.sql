/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Sales_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Sales_Activity] AS
BEGIN
truncate table STG_Promotion.Sales_Activity;
insert into STG_Promotion.Sales_Activity
select 
    id,
    case when trim(name) in ('null','') then null else trim(name) end as name,
    case when trim(desc_text) in ('null','') then null else trim(desc_text) end as desc_text,
    case when trim(rule_name) in ('null','') then null else trim(rule_name) end as rule_name,
    case when trim(rule_detail) in ('null','') then null else trim(rule_detail) end as rule_detail,
    case when trim(product_prefix) in ('null','') then null else trim(product_prefix) end as product_prefix,
    case when trim(member_group) in ('null','') then null else trim(member_group) end as member_group,
    case when trim(channel) in ('null','') then null else trim(channel) end as channel,
    status,
    case when trim(error_text) in ('null','') then null else trim(error_text) end as error_text,
    start_time,
    end_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    create_time,
    update_time,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Promotion.Sales_Activity
) t
where rownum = 1;
END
GO
