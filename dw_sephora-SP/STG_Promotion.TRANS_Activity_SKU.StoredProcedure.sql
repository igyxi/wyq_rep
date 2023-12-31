/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Activity_SKU]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Activity_SKU] AS
BEGIN
truncate table STG_Promotion.Activity_SKU;
insert into STG_Promotion.Activity_SKU
select 
    id,
    activity_id,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    case when trim(type) in ('null','') then null else trim(type) end as type,
    quantity,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    sku_status,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Promotion.Activity_SKU
) t
where rownum = 1;
END
GO
