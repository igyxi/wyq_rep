/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Pay_Discount_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Pay_Discount_Activity] AS
BEGIN
truncate table STG_Promotion.Pay_Discount_Activity;
insert into STG_Promotion.Pay_Discount_Activity
select 
    pay_discount_activity_id,
    case when trim(name) in ('null','') then null else trim(name) end as name,
    case when trim(third_channel) in ('null','') then null else trim(third_channel) end as third_channel,
    case when trim(user_group) in ('null','') then null else trim(user_group) end as user_group,
    case when trim(channel) in ('null','') then null else trim(channel) end as channel,
    activity_start_time,
    activity_end_time,
    pay_adjustment,
    case when trim(order_discount_mark) in ('null','') then null else trim(order_discount_mark) end as order_discount_mark,
    case when trim(brand_id) in ('null','') then null else trim(brand_id) end as brand_id,
    case when trim(status) in ('null','') then null else trim(status) end as status,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    create_time,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    update_time,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by pay_discount_activity_id order by dt desc) rownum from ODS_Promotion.Pay_Discount_Activity
) t
where rownum = 1;
END
GO
