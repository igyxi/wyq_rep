/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Settlemethod_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Settlemethod_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.BAS_Settlemethod_STG;
insert into STG_IMS.BAS_Settlemethod_STG
select 
		enable_time,
		case when trim(built_default) in ('','null','None') then null else trim(built_default) end as built_default,
		case when trim(paydevice_code) in ('','null','None') then null else trim(paydevice_code) end as paydevice_code,
		case when trim(currency_name) in ('','null','None') then null else trim(currency_name) end as currency_name,
		case when trim(is_tax) in ('','null','None') then null else trim(is_tax) end as is_tax,
		case when trim(is_must_upload_attach) in ('','null','None') then null else trim(is_must_upload_attach) end as is_must_upload_attach,
		case when trim(built_in) in ('','null','None') then null else trim(built_in) end as built_in,
		case when trim(is_display) in ('','null','None') then null else trim(is_display) end as is_display,
		case when trim(paydevice_id) in ('','null','None') then null else trim(paydevice_id) end as paydevice_id,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		currency_id,
		case when trim(settle_type) in ('','null','None') then null else trim(settle_type) end as settle_type,
		case when trim(voucher_no) in ('','null','None') then null else trim(voucher_no) end as voucher_no,
		disable_time,
		case when trim(is_allowed_integral) in ('','null','None') then null else trim(is_allowed_integral) end as is_allowed_integral,
		id,
		create_time,
		case when trim(enable_by) in ('','null','None') then null else trim(enable_by) end as enable_by,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(is_change) in ('','null','None') then null else trim(is_change) end as is_change,
		case when trim(card_type) in ('','null','None') then null else trim(card_type) end as card_type,
		exchange_rate,
		case when trim(disable_by) in ('','null','None') then null else trim(disable_by) end as disable_by,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		case when trim(currency_code) in ('','null','None') then null else trim(currency_code) end as currency_code,
		case when trim(is_calculate_achievement) in ('','null','None') then null else trim(is_calculate_achievement) end as is_calculate_achievement,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		createchannel_id,
		procedure_fee,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		case when trim(check_code) in ('','null','None') then null else trim(check_code) end as check_code,
		case when trim(short_cut_key) in ('','null','None') then null else trim(short_cut_key) end as short_cut_key,
		case when trim(paydevice_name) in ('','null','None') then null else trim(paydevice_name) end as paydevice_name,
		fafford_rate,
		shop_deduction_rate_setting,
		case when trim(is_discount) in ('','null','None') then null else trim(is_discount) end as is_discount,
		allocation_coefficient,
		sort_order,
		case when trim(is_exchange) in ('','null','None') then null else trim(is_exchange) end as is_exchange,
		case when trim(calculating_effective_sales) in ('','null','None') then null else trim(calculating_effective_sales) end as calculating_effective_sales,
		case when trim(enabling_deduction_rate) in ('','null','None') then null else trim(enabling_deduction_rate) end as enabling_deduction_rate,
		case when trim(scene) in ('','null','None') then null else trim(scene) end as scene,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.BAS_Settlemethod_STG
where dt = @dt
END

GO
