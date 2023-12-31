/****** Object:  StoredProcedure [STG_IMS].[TRANS_MKT_Promotionprocesslog]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_MKT_Promotionprocesslog] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.MKT_Promotionprocesslog;
insert into STG_IMS.MKT_Promotionprocesslog
select 
		id,
		promotion_id,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		case when trim(promotion_info) in ('','null','None') then null else trim(promotion_info) end as promotion_info,
		case when trim(log_content) in ('','null','None') then null else trim(log_content) end as log_content,
		create_time,
		case when trim(order_bill_no) in ('','null','None') then null else trim(order_bill_no) end as order_bill_no,
		order_amount,
		case when trim(member_name) in ('','null','None') then null else trim(member_name) end as member_name,
		current_timestamp as insert_timestamp
from  ODS_IMS.MKT_Promotionprocesslog
where dt = @dt
END

GO
