/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Store_Warning_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Store_Warning_Detail] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Store_Warning_Detail;
insert into STG_IMS.STK_Store_Warning_Detail
select 
		id,
		store_warning_id,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Store_Warning_Detail
where dt = @dt
END
GO
