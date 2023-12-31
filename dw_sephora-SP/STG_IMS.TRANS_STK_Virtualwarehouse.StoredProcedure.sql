/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Virtualwarehouse]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Virtualwarehouse] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Virtualwarehouse;
insert into STG_IMS.STK_Virtualwarehouse
select 
		id,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		warehousegroupid,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		priority,
		warnqty,
		retainqty,
		case when trim(createby) in ('','null','None') then null else trim(createby) end as createby,
		createdate,
		case when trim(modifyby) in ('','null','None') then null else trim(modifyby) end as modifyby,
		modifydate,
		case when trim(enableby) in ('','null','None') then null else trim(enableby) end as enableby,
		enabledate,
		case when trim(disableby) in ('','null','None') then null else trim(disableby) end as disableby,
		disabledate,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(groupflag) in ('','null','None') then null else trim(groupflag) end as groupflag,
		case when trim(type) in ('','null','None') then null else trim(type) end as type,
		case when trim(isshare) in ('','null','None') then null else trim(isshare) end as isshare,
		supportpreorder,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Virtualwarehouse
where dt = @dt
END
GO
