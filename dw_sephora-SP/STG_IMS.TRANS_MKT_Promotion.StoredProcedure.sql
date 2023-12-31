/****** Object:  StoredProcedure [STG_IMS].[TRANS_MKT_Promotion]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_MKT_Promotion] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.MKT_Promotion;
insert into STG_IMS.MKT_Promotion
select 
		id,
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		bill_date,
		case when trim(source_bill_no) in ('','null','None') then null else trim(source_bill_no) end as source_bill_no,
		channel_id,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		start_date,
		end_date,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		case when trim(auditing_by) in ('','null','None') then null else trim(auditing_by) end as auditing_by,
		auditing_date,
		case when trim(term_by) in ('','null','None') then null else trim(term_by) end as term_by,
		term_date,
		is_audit,
		is_term,
		condition_type,
		date_type,
		case when trim(remarks) in ('','null','None') then null else trim(remarks) end as remarks,
		is_pure_gift,
		is_repeat_gift,
		is_partial_delivery,
		is_out_must_deliver,
		scope_type,
		gift_rules,
		priority,
		miscible_group,
		is_contain_freight,
		is_use,
		case when trim(miscible_groups) in ('','null','None') then null else trim(miscible_groups) end as miscible_groups,
		is_ranking_flag_present,
		case when trim(promotion_flag) in ('','null','None') then null else trim(promotion_flag) end as promotion_flag,
		trade_control_jhs,
		trade_control_taobao_pre_sale,
		free_by_size,
		is_goods_tag,
		is_member_limit,
		member_limit_num,
		member_total_num,
		member_total_amount,
		event_type,
		stock_type,
		case when trim(user_group) in ('','null','None') then null else trim(user_group) end as user_group,
		case when trim(detail_code) in ('','null','None') then null else trim(detail_code) end as detail_code,
		event_count,
		case when trim(event_remark) in ('','null','None') then null else trim(event_remark) end as event_remark,
		case when trim(rule_info) in ('','null','None') then null else trim(rule_info) end as rule_info,
		current_timestamp as insert_timestamp
from  ODS_IMS.MKT_Promotion
where dt = @dt
END

GO
