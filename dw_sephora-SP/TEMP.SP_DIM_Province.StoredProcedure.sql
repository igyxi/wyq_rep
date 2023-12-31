/****** Object:  StoredProcedure [TEMP].[SP_DIM_Province]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Province] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-26       houshuangqiang     Initial Version
-- 2022-12-15       wangzhichun        change source table schema
-- ========================================================================================
truncate table [DW_New_OMS].[DIM_Province];
insert into [DW_New_OMS].[DIM_Province]
select 	id
		,code province_code
		,name province_name
		,status
		,parent_id as country_id
		,remark
		,enable_date
		,disable_date
		,create_time
		,modify_time as update_time
		,current_timestamp as insert_timestamp
from  	STG_IMS.bas_adminarea
where  type = '02'
;
END
GO
