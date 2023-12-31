/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Promotion_Product_Discount]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Promotion_Product_Discount] AS
BEGIN
truncate table STG_Promotion.Promotion_Product_Discount;
insert into STG_Promotion.Promotion_Product_Discount
select 
    promotion_pro_discount_id,
    case when trim(promotion_sys_id) in ('null','') then null else trim(promotion_sys_id) end as promotion_sys_id,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    case when trim(sap_price) in ('null','') then null else trim(sap_price) end as sap_price,
    case when trim(discount) in ('null','') then null else trim(discount) end as discount,
    case when trim(amount) in ('null','') then null else trim(amount) end as amount,
    case when trim(offer_price) in ('null','') then null else trim(offer_price) end as offer_price,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(sku_name) in ('null','') then null else trim(sku_name) end as sku_name,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by promotion_pro_discount_id order by dt desc) rownum from ODS_Promotion.Promotion_Product_Discount
) t
where rownum = 1;
END
GO
