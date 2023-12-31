/****** Object:  StoredProcedure [STG_MS_Appointment].[TRANS_System_Defined]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MS_Appointment].[TRANS_System_Defined] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-14       hsq           Initial Version
-- ========================================================================================
truncate table STG_MS_Appointment.System_Defined;
insert into STG_MS_Appointment.System_Defined
select  id,
        case when trim(param_name) in ('','null') then null else trim(param_name) end as param_name,
        case when trim(param_val) in ('','null') then null else trim(param_val) end as param_val,
        case when trim(param_txt) in ('','null') then null else trim(param_txt) end as param_txt,
        case when trim(param_memo) in ('','null') then null else trim(param_memo) end as param_memo,
        param_sort,
        created_at,
        updated_at,
        current_timestamp as insert_timestamp
from    ODS_MS_Appointment.System_Defined
where   dt = @dt
END
GO
