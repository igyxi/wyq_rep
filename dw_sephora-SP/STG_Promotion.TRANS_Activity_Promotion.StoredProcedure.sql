/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Activity_Promotion]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Activity_Promotion] AS
BEGIN
truncate table STG_Promotion.Activity_Promotion;
insert into STG_Promotion.Activity_Promotion
select 
    id,
    activity_id,
    promotion_sys_id,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Promotion.Activity_Promotion
) t
where rownum = 1;
END
GO
