/****** Object:  StoredProcedure [STG_MS_Appointment].[TRANS_Poc_Appointment_Extra]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MS_Appointment].[TRANS_Poc_Appointment_Extra] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-14       hsq           Initial Version
-- ========================================================================================
truncate table STG_MS_Appointment.Poc_Appointment_Extra;
insert into STG_MS_Appointment.Poc_Appointment_Extra
select  appointment_id,
        case when trim(customer_extra) in ('','null') then null else trim(customer_extra) end as customer_extra,
        case when trim(ba_extra) in ('','null') then null else trim(ba_extra) end as ba_extra,
        case when trim(imgs_path) in ('','null') then null else trim(imgs_path) end as imgs_path,
        created_at,
        updated_at,
        current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by appointment_id order by dt desc) rownum from ODS_MS_Appointment.Poc_Appointment_Extra
) t
where rownum = 1
END
GO
