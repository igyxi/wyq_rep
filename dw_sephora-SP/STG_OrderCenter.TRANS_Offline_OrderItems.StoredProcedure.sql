/****** Object:  StoredProcedure [STG_OrderCenter].[TRANS_Offline_OrderItems]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderCenter].[TRANS_Offline_OrderItems] AS
BEGIN
truncate table STG_OrderCenter.Offline_OrderItems;
insert into STG_OrderCenter.Offline_OrderItems
select 
    id,
    case when trim(lower(ticket_number)) in ('null','') then null else trim(ticket_number) end as ticket_number,
    case when trim(lower(product_brand_name_en)) in ('null','') then null else trim(product_brand_name_en) end as product_brand_name_en,
    case when trim(lower(product_sku_code)) in ('null','') then null else trim(product_sku_code) end as product_sku_code,
    case when trim(lower(product_sku_id)) in ('null','') then null else trim(product_sku_id) end as product_sku_id,
    case when trim(lower(product_id)) in ('null','') then null else trim(product_id) end as product_id,
    case when trim(lower(product_image_url)) in ('null','') then null else trim(product_image_url) end as product_image_url,
    case when trim(lower(product_name)) in ('null','') then null else trim(product_name) end as product_name,
    case when trim(lower(product_size)) in ('null','') then null else trim(product_size) end as product_size,
    quantity,
    price,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *,row_number() over(partition by id order by dt desc) rownum from ODS_OrderCenter.Offline_OrderItems
) t
where rownum = 1
END


GO
