/****** Object:  StoredProcedure [DWD].[SP_Fact_Internal_Sales_Event]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Internal_Sales_Event] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-21       lizeyuan           Initial Version
-- 2023-03-24       houshuangqiang     change schema to ODS_SIS
-- 2023-05-04       zhailonglong       change table name to Fact_Internal_Sales_Event
-- ========================================================================================
truncate table DWD.Fact_Internal_Sales_Event;
insert into DWD.Fact_Internal_Sales_Event
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
