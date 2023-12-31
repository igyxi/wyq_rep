/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Promotion_Bind]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Promotion_Bind] AS
BEGIN
truncate table STG_Promotion.Promotion_Bind;
insert into STG_Promotion.Promotion_Bind
select 
    id,
    case when trim(bind_promotion_sys_id) in ('null','') then null else trim(bind_promotion_sys_id) end as bind_promotion_sys_id,
    case when trim(promotion_sys_id) in ('null','') then null else trim(promotion_sys_id) end as promotion_sys_id,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Promotion.Promotion_Bind
) t
where rownum = 1;
END
GO
