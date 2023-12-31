/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Sharegroupdetail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Sharegroupdetail] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Sharegroupdetail;
insert into STG_IMS.STK_Sharegroupdetail
select 
		id,
		warehouseid,
		case when trim(warehousename) in ('','null','None') then null else trim(warehousename) end as warehousename,
		case when trim(sharegroupname) in ('','null','None') then null else trim(sharegroupname) end as sharegroupname,
		createdate,
		case when trim(sharegroupcode) in ('','null','None') then null else trim(sharegroupcode) end as sharegroupcode,
		case when trim(warehousecode) in ('','null','None') then null else trim(warehousecode) end as warehousecode,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		sharegroupid,
		whareatypeid,
		case when trim(whareatypecode) in ('','null','None') then null else trim(whareatypecode) end as whareatypecode,
		case when trim(whareatypename) in ('','null','None') then null else trim(whareatypename) end as whareatypename,
		case when trim([percent]) in ('','null','None') then null else trim([percent]) end as [percent],
		safe_qty,
		priority,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Sharegroupdetail
where dt = @dt
END
GO
