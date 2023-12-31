/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Order_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Order_Detail] AS
BEGIN
truncate table STG_SmartBA.T_Order_Detail ;
insert into STG_SmartBA.T_Order_Detail
select 
    id,
    case when trim(order_code) in ('null','') then null else trim(order_code) end as order_code,
    parent_id,
    product_id,
    case when trim(product_code) in ('null','') then null else trim(product_code) end as product_code,
    case when trim(product_name) in ('null','') then null else trim(product_name) end as product_name,
    case when trim(brand_name) in ('null','') then null else trim(brand_name) end as brand_name,
    case when trim(img_url) in ('null','') then null else trim(img_url) end as img_url,
    pre_price,
    sell_price,
    price,
    number,
    activity_id,
    is_gift,
    discount_amount,
    real_amount,
    take_amount,
    return_number,
    return_amount,
    spec_id,
    case when trim(spec_code) in ('null','') then null else trim(spec_code) end as spec_code,
    case when trim(spec_content) in ('null','') then null else trim(spec_content) end as spec_content,
    delivery_number,
    case when trim(bar_codes) in ('null','') then null else trim(bar_codes) end as bar_codes,
    case when trim(return_bar_codes) in ('null','') then null else trim(return_bar_codes) end as return_bar_codes,
    case when trim(unique_code) in ('null','') then null else trim(unique_code) end as unique_code,
    status,
    comment_status,
    tenant_id,
    create_time,
    update_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by order_code,spec_code order by dt desc) rownum from ODS_SmartBA.T_Order_Detail
) t
where t.rownum = 1
END

GO
