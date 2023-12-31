/****** Object:  StoredProcedure [TEMP].[SP_Fact_Instore_Service_Record_Bak_20230420]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Instore_Service_Record_Bak_20230420] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-01-27       tali           delete collate
-- 2022-01-28       tali           delete collate
-- 2023-03-30       houshuangqiang new version(原来的表名是：DW_Marketing.RPT_Instore_Service_Record)
-- ========================================================================================
truncate table [DWD].[Fact_Instore_Service_Record];
insert into [DWD].[Fact_Instore_Service_Record]
select
		appointment.store_code,
		appointment.open_id,
		member.member_card as memerb_card,
		substring(account.card_type_name, 3, 50) as memerb_grade,
		case when appointment.is_canceled = 1 then N'已取消'
			 when appointment.sign_code IS NOT NULL then N'已签到'
			 else N'已预约'
		end	as status,
		appointment.create_time as created_at,
		appointment.[remark] as booking_remark,
		appointment.channel as source,
		appointment.start_time as book_time,
		store.name as store_name,
		case
			when appointment.sign_code IS NOT NULL
			and appointment.is_canceled <> 1 then appointment.update_time
			else NULL
		end as checkin_time,
		activity.event_name as service_code,
		current_timestamp as insert_timestamp
from	[STG_Marketing].[Activity_Store_Book_User] appointment
inner 	join [STG_Marketing].[Store_Activity] activity 
on 		appointment.activity_id = activity.activity_id
inner 	join [STG_Marketing].[Store] store 
on 		appointment.store_code = store.code
left 	join [DWD].[DIM_Member_Info] member 
on 		appointment.user_id = member.eb_user_id
left 	join [DW_CRM].[DIM_CRM_Account_SCD] account 
on 		account.[account_number] = member.member_card 
and 	appointment.start_time between account.start_time
and 	account.end_time
union all
select
		[store_code] ,
		[open_id] ,
		[card_num] ,
		[card_type],
		[status],
		cast([create_time] as datetime) as created_at,
		[booking_remark] ,
		[source] ,
		null as book_time,
		[store_name] ,
		cast([签到时间] as datetime) as checkin_time,
		N'玩美丝芙兰' as service_code,
		current_timestamp as insert_timestamp
FROM	[STG_Marketing].[Activity_Store_Book_User_History_Keep];
END

GO
