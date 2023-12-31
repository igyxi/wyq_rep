/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Stock_Request]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Stock_Request] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Stock_Request;
insert into STG_IMS.STK_Stock_Request
select 
		id,
		case when trim(out_trade_no) in ('','null','None') then null else trim(out_trade_no) end as out_trade_no,
		case when trim(app_id) in ('','null','None') then null else trim(app_id) end as app_id,
		case when trim(bill_type) in ('','null','None') then null else trim(bill_type) end as bill_type,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		create_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Stock_Request
where dt = @dt
END
GO
