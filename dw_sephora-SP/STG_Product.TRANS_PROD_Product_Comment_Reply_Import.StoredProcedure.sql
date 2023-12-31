/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Product_Comment_Reply_Import]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Product_Comment_Reply_Import] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-06       hsq        Initial Version
-- ========================================================================================
truncate table STG_Product.PROD_Product_Comment_Reply_Import ;
insert into STG_Product.PROD_Product_Comment_Reply_Import
select
    id,
    case when trim(file_name) in ('null', '') then null else trim(file_name) end as file_name,
	total_rows,
	success_rows,
	fail_rows,
	process_rows,
    case when trim(error_code) in ('null', '') then null else trim(error_code) end as error_code,
	case when trim(process_status) in ('null', '') then null else trim(process_status) end as process_status,
    case when trim(origin_file_path) in ('null', '') then null else trim(origin_file_path) end as origin_file_path,
    case when trim(process_file_path) in ('null', '') then null else trim(process_file_path) end as process_file_path,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
	create_time,
	update_time,
	is_deleted,
    current_timestamp as insert_timestamp
from
    ODS_Product.PROD_Product_Comment_Reply_Import
where dt = @dt
END
GO
