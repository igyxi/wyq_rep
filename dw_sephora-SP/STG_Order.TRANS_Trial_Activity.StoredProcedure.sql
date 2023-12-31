/****** Object:  StoredProcedure [STG_Order].[TRANS_Trial_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Order].[TRANS_Trial_Activity] AS
BEGIN
truncate table STG_Order.Trial_Activity;
insert into STG_Order.Trial_Activity
select 
    id,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    case when trim(sku_id) in ('null','') then null else trim(sku_id) end as sku_id,
    case when trim(activity_id) in ('null','') then null else trim(activity_id) end as activity_id,
    case when trim(order_id) in ('null','') then null else trim(order_id) end as order_id,
    user_id,
    case when trim(promotion_id) in ('null','') then null else trim(promotion_id) end as promotion_id,
    px_coupon_id,
    type,
    status,
    create_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    update_time,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_del,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Order.Trial_Activity
)t
where rownum = 1;
END


GO
