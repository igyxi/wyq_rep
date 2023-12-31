/****** Object:  StoredProcedure [STG_ShopCart].[TRANS_Cart]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ShopCart].[TRANS_Cart] AS
BEGIN
truncate table STG_ShopCart.Cart ;
insert into STG_ShopCart.Cart
select 
    sku_id,
    quantity,
    user_id,
    case when trim(lower(channel)) in ('null','') then null else trim(channel) end as channel,
    case when trim(lower(store)) in ('null','') then null else trim(store) end as store,
    type,
    case when trim(lower(checked)) in ('null','') then null else trim(checked) end as checked,
    create_time,
    last_update,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
	case when trim(lower(source)) in ('null','') then null else trim(source) end as source,
    expire_time,
    case when trim(lower(live_roomId)) in ('null','') then null else trim(live_roomId) end as source,
    case when trim(lower(live_channel)) in ('null','') then null else trim(live_channel) end as source,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by sku_id, user_id, store, [type] order by dt desc) rownum from ODS_ShopCart.Cart
) t
where rownum = 1
END
GO
