/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Product_DESC]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Product_DESC] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Product.PROD_Product_DESC ;
insert into STG_Product.PROD_Product_DESC
select 
    id,
    case when trim(desktop_html) in ('null', '') then null else trim(desktop_html) end as desktop_html,
    case when trim(mobile_html) in ('null', '') then null else trim(mobile_html) end as mobile_html,
    case when trim(miniprogram_html) in ('null', '') then null else trim(miniprogram_html) end as miniprogram_html,
    update_time, 
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    desktop_switch, 
    mobile_switch, 
    miniprogram_switch,
    create_time,    
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_Product_DESC
where dt = @dt
END


GO
