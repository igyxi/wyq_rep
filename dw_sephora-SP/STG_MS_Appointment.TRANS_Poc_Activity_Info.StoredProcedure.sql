/****** Object:  StoredProcedure [STG_MS_Appointment].[TRANS_Poc_Activity_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MS_Appointment].[TRANS_Poc_Activity_Info] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-14       hsq           Initial Version
-- ========================================================================================
truncate table STG_MS_Appointment.Poc_Activity_Info;
insert into STG_MS_Appointment.Poc_Activity_Info
select  id,
        case when trim(name) in ('','null') then null else trim(name) end as name,
        case when trim(pic) in ('','null') then null else trim(pic) end as pic,
        create_at,
        update_at,
        case when trim(event_type) in ('','null') then null else trim(event_type) end as event_type,
        ordering,
        case when trim(main_pic) in ('','null') then null else trim(main_pic) end as main_pic,
        event_start_time,
        event_end_time,
        reservation_start_time,
        reservation_end_time,
        total_count,
        case when trim(app_event_detail) in ('','null') then null else trim(app_event_detail) end as app_event_detail,
        case when trim(mobile_event) in ('','null') then null else trim(mobile_event) end as mobile_event,
        case when trim(mobile_event_detail) in ('','null') then null else trim(mobile_event_detail) end as mobile_event_detail,
        case when trim(pc_event) in ('','null') then null else trim(pc_event) end as pc_event,
        case when trim(pc_event_detail) in ('','null') then null else trim(pc_event_detail) end as pc_event_detail,
        case when trim(identity_marker) in ('','null') then null else trim(identity_marker) end as identity_marker,
        case when trim(appo_count_type) in ('','null') then null else trim(appo_count_type) end as appo_count_type,
        appo_count,
        reservation_end_days_before,
        case when trim(investment_channels) in ('','null') then null else trim(investment_channels) end as investment_channels,
        [external],
        case when trim(external_url) in ('','null') then null else trim(external_url) end as external_url,
        case when trim(error_messages) in ('','null') then null else trim(error_messages) end as error_messages,
        email_notification,
        status,
        type,
        item_id,
        case when trim(ba_department) in ('','null') then null else trim(ba_department) end as ba_department,
        user_sms_notification,
        is_sysc_da,
        is_show_option,
        is_show_upload_img,
        is_show_remark,
        case when trim(extra_params) in ('','null') then null else trim(extra_params) end as extra_params,
        is_show_feedback,
        case when trim(ba_extra_params) in ('','null') then null else trim(ba_extra_params) end as ba_extra_params,
        current_timestamp as insert_timestamp
from    ODS_MS_Appointment.Poc_Activity_Info
where   dt = @dt
END
GO
