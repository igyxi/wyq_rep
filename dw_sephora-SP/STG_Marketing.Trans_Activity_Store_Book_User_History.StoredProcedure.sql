/****** Object:  StoredProcedure [STG_Marketing].[Trans_Activity_Store_Book_User_History]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Marketing].[Trans_Activity_Store_Book_User_History] AS
BEGIN
TRUNCATE TABLE STG_Marketing.Activity_Store_Book_User_History;
insert into STG_Marketing.Activity_Store_Book_User_History
select 
    ROW_number() over (order by create_time) + 20000000 as row_num,
    case when trim(store_code) in ('null','') then null else trim(store_code) end as store_code,
    case when trim(open_id) in ('null','') then null else trim(open_id) end as open_id,
    case when trim(card_num) in ('null','') then null else trim(card_num) end as card_num,
    case when trim(card_type) in ('null','') then null else trim(card_type) end as card_type,
    case when trim([status]) in ('null','') then null else trim([status]) end as [status],
    create_time,
    case when trim(booking_name) in ('null','') then null else trim(booking_name) end as booking_name,
    case when trim(booking_mobile) in ('null','') then null else trim(booking_mobile) end as booking_mobile,
    case when trim(booking_remark) in ('null','') then null else trim(booking_remark) end as booking_remark,
    case when trim(source) in ('null','') then null else trim(source) end as source,
    case when trim(store_name) in ('null','') then null else trim(store_name) end as store_name,
    checkin_time,
    current_timestamp as insert_timestamp
from
(
    select 
        distinct *
    from 
        ODS_Marketing.Activity_Store_Book_User_History
) b
;
END
GO
