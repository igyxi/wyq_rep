/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Promotion]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Promotion] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Promotion.Promotion ;
insert into STG_Promotion.Promotion
select 
    case when trim(promotion_sys_id) in ('','null') then null else trim(promotion_sys_id) end as promotion_sys_id,
    case when trim(promotion_name) in ('','null') then null else trim(promotion_name) end as promotion_name,
    promotion_type,
    case when trim(order_type) in ('','null') then null else trim(order_type) end as order_type,
    use_type,
    exclude_discount,
    combination_type,
    optional,
    priority,
    action_limit_type,
    action_limit_value,
    start_time,
    end_time,
    case when trim(customer_group) in ('','null') then null else trim(customer_group) end as customer_group,
    case when trim(channel_id) in ('','null') then null else trim(channel_id) end as channel_id,
    case when trim(store_id) in ('','null') then null else trim(store_id) end as store_id,
    isAllProduct,
    status,
    case when trim(prom_pdp_show) in ('','null') then null else trim(prom_pdp_show) end as prom_pdp_show,
    create_time,
    update_time,
    case when trim(create_user) in ('','null') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('','null') then null else trim(update_user) end as update_user,
    publish_env,
    publish_ver,
    case when trim(origin) in ('','null') then null else trim(origin) end as origin,
    code_type,
    bought_times,
    case when trim(bought_channel) in ('','null') then null else trim(bought_channel) end as bought_channel,
    is_delete,
    case when trim(channel_url) in ('','null') then null else trim(channel_url) end as channel_url,
    public_code_used_times,
    combination_coupon,
    only_to_deposit,
    is_pim_hide,
    case when trim(o2o_promotion_code) in ('', 'null') then null else trim(o2o_promotion_code) end as o2o_promotion_code,
    plp_show,
    plp_tag_show,
    coupon_auto_apply,
    case when trim(limit_area_type) in ('', 'null') then null else trim(limit_area_type) end as limit_area_type,
    participation_times,
    deposit_show_priority,
    current_timestamp as insert_timestamp
from 
    ODS_Promotion.Promotion
where dt = @dt;
delete from ODS_Promotion.Promotion where dt <= format(DATEADD(day, -7, @dt), 'yyyy-MM-dd');
END


GO
