/****** Object:  StoredProcedure [STG_Promotion].[TRANS_PX_Coupon]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_PX_Coupon] AS
BEGIN
truncate table STG_Promotion.PX_Coupon ;
insert into STG_Promotion.PX_Coupon
select 
    px_coupon_id,
    user_id,
    type,
    case when trim(lower(code)) in ('','null') then null else trim(code) end as code,
    case when trim(lower(promotion_id)) in ('','null') then null else trim(promotion_id) end as promotion_id,
    promotion_version,
    case when trim(lower(name)) in ('','null') then null else trim(name) end as name,
    effective,
    expire,
    show_time,
    case when trim(lower(order_id)) in ('','null') then null else trim(order_id) end as order_id,
    status,
    valid,
    case when trim(lower(origin)) in ('','null') then null else trim(origin) end as origin,
    priority,
    use_time,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('','null') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('','null') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(lower(coupon_event_id)) in ('','null') then null else trim(coupon_event_id) end as coupon_event_id,
    case when trim(lower(source)) in ('','null') then null else trim(source) end as source,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by px_coupon_id order by dt desc) rownum from ods_Promotion.PX_Coupon
)t
where rownum = 1
END


GO
