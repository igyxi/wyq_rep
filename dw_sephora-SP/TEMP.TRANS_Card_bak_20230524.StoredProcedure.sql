/****** Object:  StoredProcedure [TEMP].[TRANS_Card_bak_20230524]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_Card_bak_20230524] AS
BEGIN
truncate table STG_User.Card ;
insert into STG_User.Card
select
	trim(card_no) as card_no, 
    case 
        when trim(lower(level)) in ('null', '') then null
        when level = 'GOLDEN' then 'GOLD'
        else level
    end as level,
    status,
    case 
        when trim(lower(source)) in ('null', '') then null 
        when source in ('Offline','offline') then 'Offline'
        else source
    end as source,
    case when trim(lower(store_id)) in ('null', '') then null else trim(store_id) end as store_id,
    available_points,
    pink_upgrade_time,
    white_upgrade_time,
    black_upgrade_time,
    gold_upgrade_time,
    total_sales_points,
    join_time,
    bind_time,
    update_time,
    create_time,
    last_online_update_time,
    last_offline_update_time,
    purchasetimes,
    case when trim(lower(create_user)) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by card_no order by dt desc) as rownum from ODS_User.Card where trim(lower(card_no)) not in ('null', '')
) t
where rownum = 1
END


GO
