/****** Object:  StoredProcedure [TEMP].[SP_DIM_Promotion_Bak20230223]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Promotion_Bak20230223] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-06       Eric               Change Sourse
-- ========================================================================================
truncate table DWD.DIM_Promotion;
insert into DWD.DIM_Promotion
select
	promotion_sys_id as promotion_id
	,promotion_name
	,promotion_type
	,create_time
	,start_time
	,end_time
	,'OMS' as source
	,current_timestamp as insert_timestamp
from 
    [STG_Promotion].[Promotion]
;
END


GO
