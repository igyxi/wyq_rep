/****** Object:  StoredProcedure [STG_ShopCart].[TRANS_Cart_Flow]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ShopCart].[TRANS_Cart_Flow] @dt [VARCHAR](10) AS
BEGIN
delete from STG_ShopCart.Cart_Flow where dt = @dt;
insert into STG_ShopCart.Cart_Flow
select 
    id,
	user_id,
	case when trim(lower(sku_id)) in ('null','') then null else trim(sku_id) end as sku_id,
	change_num,
	case 
	    when trim(lower(channel)) in ('null','') then null 
		when trim(upper(channel)) = 'MONIPROGRAM' then 'MINIPROGRAM'
	else trim(upper(channel)) end as channel,
	type,
	case when trim(lower(store)) in ('null','') then null else trim(store) end as store,
	cart_type,
	create_time,
	update_time,
	case when trim(lower(source)) in ('null','') then null else trim(source) end as source,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
	case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp,
    dt
from 
    ODS_ShopCart.Cart_Flow
where 
    dt = @dt;
END
GO
