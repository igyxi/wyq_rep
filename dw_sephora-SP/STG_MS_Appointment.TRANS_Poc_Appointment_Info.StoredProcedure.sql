/****** Object:  StoredProcedure [STG_MS_Appointment].[TRANS_Poc_Appointment_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MS_Appointment].[TRANS_Poc_Appointment_Info] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-14       hsq           Initial Version
-- ========================================================================================
truncate table STG_MS_Appointment.Poc_Appointment_Info;
insert into STG_MS_Appointment.Poc_Appointment_Info
select  id,
        case when trim(card_num) in ('','null') then null else trim(card_num) end as card_num,
        case when trim(user_id) in ('','null') then null else trim(user_id) end as user_id,
        case when trim(card_level) in ('','null') then null else trim(card_level) end as card_level,
        case when trim(openid) in ('','null') then null else trim(openid) end as openid,
        case when trim(alipay_user_id) in ('','null') then null else trim(alipay_user_id) end as alipay_user_id,
        alipay_followmsg_flag,
        case when trim(customer_name) in ('','null') then null else trim(customer_name) end as customer_name,
        case when trim(mobile) in ('','null') then null else trim(mobile) end as mobile,
        activity_id,
        activity_type,
        case when trim(store_code) in ('','null') then null else trim(store_code) end as store_code,
        book_date,
        case when trim(book_time) in ('','null') then null else trim(book_time) end as book_time,
        beaut_scene,
        beaut_level,
        skin_type,
        case when trim(customer_remarks) in ('','null') then null else trim(customer_remarks) end as customer_remarks,
        case when trim(random_code) in ('','null') then null else trim(random_code) end as random_code,
        status,
        channel,
        case when trim(recommend_json) in ('','null') then null else trim(recommend_json) end as recommend_json,
        case when trim(imgs_path) in ('','null') then null else trim(imgs_path) end as imgs_path,
        ba_status,
        case when trim(staff_remarks) in ('','null') then null else trim(staff_remarks) end as staff_remarks,
        created_at,
        updated_at,
        cancellation_time,
        done_time,
        case when trim(staff_no) in ('','null') then null else trim(staff_no) end as staff_no,
        case when trim(inviter_staff_no) in ('','null') then null else trim(inviter_staff_no) end as inviter_staff_no,
        case when trim(coupon_id) in ('','null') then null else trim(coupon_id) end as coupon_id,
        modification_times,
        case when trim(item_id) in ('','null') then null else trim(item_id) end as item_id,
        case when trim(mobile_asc) in ('','null') then null else trim(mobile_asc) end as mobile_asc,
        case when trim(name_asc) in ('','null') then null else trim(name_asc) end as name_asc,
        staff_channel,
        case when trim(customer_extra) in ('','null') then null else trim(customer_extra) end as customer_extra,
        case when trim(sub_channel) in ('','null') then null else trim(sub_channel) end as sub_channel,
        outside_id,
        case when trim(unionid) in ('','null') then null else trim(unionid) end as unionid,
        lianwei_id,
        current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_MS_Appointment.Poc_Appointment_Info
) t
where rownum = 1 
END
GO
