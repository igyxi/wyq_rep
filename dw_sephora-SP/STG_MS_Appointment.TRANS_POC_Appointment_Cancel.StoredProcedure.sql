/****** Object:  StoredProcedure [STG_MS_Appointment].[TRANS_POC_Appointment_Cancel]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MS_Appointment].[TRANS_POC_Appointment_Cancel] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-07       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MS_Appointment.POC_Appointment_Cancel;
insert into STG_MS_Appointment.POC_Appointment_Cancel
select 
		appointment_id,
		case when trim(main_cancel) in ('','null') then null else trim(main_cancel) end as main_cancel,
		case when trim(custom_cancel) in ('','null') then null else trim(custom_cancel) end as custom_cancel,
        created_at,
        updated_at,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by appointment_id order by dt desc) rownum from ODS_MS_Appointment.POC_Appointment_Cancel
) t
where rownum = 1
END
GO
