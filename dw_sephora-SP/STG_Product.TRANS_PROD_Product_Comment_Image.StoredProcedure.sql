/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Product_Comment_Image]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Product_Comment_Image] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-06       hsq        Initial Version
-- ========================================================================================
truncate table STG_Product.PROD_Product_Comment_Image ;
insert into STG_Product.PROD_Product_Comment_Image
select 
    id,
	comment_id,
    case when trim(image_path) in ('null', '') then null else trim(image_path) end as image_path,
	sequence, 
	create_time,
	update_time,
	is_disable,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    case when trim(audit_status) in ('null', '') then null else trim(audit_status) end as audit_status,	
    case when trim(hash) in ('null', '') then null else trim(hash) end as hash,		
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_Product_Comment_Image
where dt = @dt
END
GO
