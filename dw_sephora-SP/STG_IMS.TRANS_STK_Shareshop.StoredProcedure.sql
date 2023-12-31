/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Shareshop]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Shareshop] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Shareshop;
insert into STG_IMS.STK_Shareshop
select 
		shop_id,
		sharegroup_id,
		case when trim(createby) in ('','null','None') then null else trim(createby) end as createby,
		createdate,
		case when trim(modifyby) in ('','null','None') then null else trim(modifyby) end as modifyby,
		modifydate,
		id,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Shareshop
where dt = @dt
END
GO
