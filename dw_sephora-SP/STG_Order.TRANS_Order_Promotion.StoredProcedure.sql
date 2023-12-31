/****** Object:  StoredProcedure [STG_Order].[TRANS_Order_Promotion]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Order].[TRANS_Order_Promotion] AS
BEGIN
truncate table STG_Order.Order_Promotion;
insert into STG_Order.Order_Promotion
select 
    id,
    order_id,
    case when trim(lower(promotion_id)) in ('null','') then null else trim(promotion_id) end as promotion_id,
    case when trim(lower(coupon_code)) in ('null','') then null else trim(coupon_code) end as coupon_code,
    coupon_type,
    create_time,
    version,	
    case when trim(lower(sku_id)) in ('null','') then null else trim(sku_id) end as sku_id,
    offer_id,	
    promotion_adjustment,
    case when trim(lower(promotion_content)) in ('null','') then null else trim(promotion_content) end as promotion_content,
    case when trim(lower(promotion_name)) in ('null','') then null else trim(promotion_name) end as promotion_name,
    case when trim(lower(origin)) in ('null','') then null else trim(origin) end as origin,
    case when trim(lower(crm_coupon_code)) in ('null','') then null else trim(crm_coupon_code) end as crm_coupon_code,
    px_coupon_id,	
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Order.Order_Promotion
)t
where rownum = 1
END


GO
