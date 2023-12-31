/****** Object:  StoredProcedure [DWD].[SP_DIM_WeChat_Group]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_WeChat_Group] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-01-06       Eric           Change Sourse
-- 2022-01-10       Eric           Change Sourse
-- ========================================================================================

truncate table DWD.DIM_WeChat_Group;
insert into DWD.DIM_WeChat_Group
select 
	id
	,chat_name
	,chat_id
	,chat_type
	,channel_name
	,owner_name
	,tenant_id
	,create_time
	,'CRM' as source
	,current_timestamp as insert_timestamp
from 
    [STG_SmartBA].[T_WXChat_Sale_Config]
END

GO
