/****** Object:  StoredProcedure [STG_Promotion].[TRANS_Promotion_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Promotion].[TRANS_Promotion_REL] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-14       wangzhichun        Initial Version
-- ========================================================================================
truncate table STG_Promotion.Promotion_REL;
insert into STG_Promotion.Promotion_REL
select 
    promotion_rel_id,
    case when trim(out_key) in ('null','','None') then null else trim(out_key) end as out_key,
    rel_type,
    group_level,
    include,
    case when trim(promotion_sys_id) in ('null','','None') then null else trim(promotion_sys_id) end as promotion_sys_id,
    case when trim(key_desc) in ('null','','None') then null else trim(key_desc) end as key_desc,
    create_time,
    update_time,
    case when trim(create_user) in ('null','','None') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','','None') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(sku_name) in ('null','','None') then null else trim(sku_name) end as sku_name,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by promotion_rel_id order by dt desc) rownum from ODS_Promotion.Promotion_REL
) t
where rownum = 1;
END
GO
