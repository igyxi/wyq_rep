/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_GWP_Stock_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_GWP_Stock_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_GWP_Stock_Log;
insert into STG_IMS.STK_GWP_Stock_Log
select 
		id,
		case when trim(shop_code) in ('','null','None') then null else trim(shop_code) end as shop_code,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		qty,
		operate_time,
		case when trim(operate_by) in ('','null','None') then null else trim(operate_by) end as operate_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_GWP_Stock_Log
where dt = @dt
END
GO
