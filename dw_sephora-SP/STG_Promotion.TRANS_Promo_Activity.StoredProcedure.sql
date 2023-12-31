/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Promo_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Promo_Activity] AS
BEGIN
truncate table STG_Promotion.promo_activity;
insert into STG_Promotion.promo_activity
select 
    activity_id,
    case when trim(name) in ('','null') then null else trim(name) end as name,
    case when trim(type) in ('','null') then null else trim(type) end as type,
    case when trim(user_group) in ('','null') then null else trim(user_group) end as user_group,
    case when trim(channel) in ('','null') then null else trim(channel) end as channel,
    sale_start_time,
    sale_end_time,
    balance_pay_start_time,
    balance_pay_end_time,
    balance_pay_remind_time,
    sale_display_time,
    estimated_delivery_time,
    case when trim(deposit_type) in ('','null') then null else trim(deposit_type) end as deposit_type,
    case when trim(deposit_value) in ('','null') then null else trim(deposit_value) end as deposit_value,
    case when trim(normal_buy) in ('','null') then null else trim(normal_buy) end as normal_buy,
    case when trim(nopay_expirt_time) in ('','null') then null else trim(nopay_expirt_time) end as nopay_expirt_time,
    case when trim(discount_value) in ('','null') then null else trim(discount_value) end as discount_value,
    case when trim(shipping_condition_type) in ('','null') then null else trim(shipping_condition_type) end as shipping_condition_type,
    case when trim(shipping_condition_value) in ('','null') then null else trim(shipping_condition_value) end as shipping_condition_value,
    case when trim(fixed_shipping) in ('','null') then null else trim(fixed_shipping) end as fixed_shipping,
    case when trim(depict) in ('','null') then null else trim(depict) end as depict,
    case when trim(status) in ('','null') then null else trim(status) end as status,
    case when trim(create_user) in ('','null') then null else trim(create_user) end as create_user,
    create_time,
    case when trim(update_user) in ('','null') then null else trim(update_user) end as update_user,
    update_time,
    commit_time,
    is_all_product,
    is_delete,
    page_estimated_delivery_time,
    publish_time,
    plp_show,
    plp_tag_show,
    current_timestamp insert_timestamp
from 
(
     select *, row_number() over(partition by activity_id order by dt desc) rownum from [ODS_Promotion].[promo_activity] 
)t
where rownum = 1
END


GO
