/****** Object:  StoredProcedure [TEMP].[SP_Fact_InternalSales_Event_bak20230505]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_InternalSales_Event_bak20230505] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-21       lizeyuan           Initial Version
-- 2023-03-24       houshuangqiang     change schema to ODS_SIS
-- ========================================================================================
truncate table DWD.Fact_InternalSales_Event;
insert into DWD.Fact_InternalSales_Event
select
	o.id
    ,o.activity_id
    ,activity.name as activity_name
	,o.company_id
    ,company.company_name
	,o.open_id
	,o.card_no
	,o.operation_type
	,o.operation_description
	,o.create_time
	,o.update_time
    ,current_timestamp as insert_timestamp
from
	ODS_SIS.SIS_Operation_Log o
left join
	ODS_SIS.SIS_Company company
on o.company_id = company.id
and o.activity_id = company.activity_id
left join
	ODS_SIS.SIS_Activity activity
on o.activity_id = activity.id
END

GO
