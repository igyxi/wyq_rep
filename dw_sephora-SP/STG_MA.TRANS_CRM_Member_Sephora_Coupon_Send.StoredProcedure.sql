/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Member_Sephora_Coupon_Send]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Member_Sephora_Coupon_Send] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       wangzhichun           Initial Version
-- 2022-07-18       wangzhichun           update effective_to_date type
-- ========================================================================================
truncate table STG_MA.CRM_Member_Sephora_Coupon_Send;
insert into STG_MA.CRM_Member_Sephora_Coupon_Send
select
		id,
		mkt_type,
		mkt_id,
		case when trim(loop_id) in ('','null') then null else trim(loop_id) end as loop_id,
		node_id,
		case when trim(member_code) in ('','null') then null else trim(member_code) end as member_code,
		send_status,
		offer_id,
		date_type,
		rolling_days,
        case when trim(effective_to_date) in ('','null') then null else cast(trim(effective_to_date) as datetime) end as effective_to_date,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		create_timestamp,
		update_timestamp,
		send_type,
		case when trim(offer_sku) in ('','null') then null else trim(offer_sku) end as offer_sku,
		case when trim(channel) in ('','null') then null else trim(channel) end as channel,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_MA.CRM_Member_Sephora_Coupon_Send
) t
where rownum = 1;
END
GO
