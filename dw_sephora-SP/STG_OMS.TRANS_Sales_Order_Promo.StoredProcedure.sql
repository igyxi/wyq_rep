/****** Object:  StoredProcedure [STG_OMS].[TRANS_Sales_Order_Promo]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Sales_Order_Promo] AS
BEGIN
truncate table STG_OMS.Sales_Order_Promo ;
insert into STG_OMS.Sales_Order_Promo
select 
    sales_order_promo_sys_id,
    sales_order_sys_id,
    case when trim(lower(r_oms_order_sys_id)) in ('null','') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    case when trim(lower(promotion_code)) in ('null','') then null else trim(promotion_code) end as promotion_code,
    case when trim(lower(promotion_name)) in ('null','') then null else trim(promotion_name) end as promotion_name,
    crm_coupon_flag,
    case when trim(lower(sku_id)) in ('null','') then null else trim(sku_id) end as sku_id,
    create_time,
    update_time,
    case when trim(lower(create_op)) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(lower(update_op)) in ('null','') then null else trim(update_op) end as update_op,
    promotion_amount,
    case when trim(lower(promotion_description)) in ('null','') then null else trim(promotion_description) end as promotion_description,
    priority,
    case when trim(lower(source_promotion_description)) in ('null','') then null else trim(source_promotion_description) end as source_promotion_description,
    case when trim(lower(coupon_id)) in ('null','') then null else trim(coupon_id) end as coupon_id,
    case when trim(lower(coupon_type)) in ('null','') then null else trim(coupon_type) end as coupon_type,
    gift_item_quantity,
    px_coupon_id,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *,row_number() over(partition by sales_order_sys_id, sales_order_promo_sys_id order by dt desc) rownum from ODS_OMS.Sales_Order_Promo 
) t
where rownum = 1
END


GO
