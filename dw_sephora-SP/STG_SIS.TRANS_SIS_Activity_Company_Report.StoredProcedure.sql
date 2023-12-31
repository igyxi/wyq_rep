/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Activity_Company_Report]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Activity_Company_Report] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-26       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Activity_Company_Report;
insert into STG_SIS.SIS_Activity_Company_Report
select 
		id,
		activity_id,
		case when trim(activity_name) in ('','null') then null else trim(activity_name) end as activity_name,
		company_id,
		case when trim(company_name) in ('','null') then null else trim(company_name) end as company_name,
		visits_number,
		visitors_number,
		bill_counts,
		bill_amounts,
		customer_unit_price,
		order_conversion_rate,
		payers_number,
		bar_jump_counts,
		register_user_counts,
		bind_user_counts,
		sale_member_counts,
		pink_card_counts,
		white_card_counts,
		dark_card_counts,
		gold_card_counts,
		order_user_new_old_rate,
		login_user_new_old_rate,
		create_time,
		update_time,
		refund_counts,
		refund_amounts,
		current_timestamp as insert_timestamp
from
(
    select *,row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Activity_Company_Report
) t
where rownum = 1
END
GO
