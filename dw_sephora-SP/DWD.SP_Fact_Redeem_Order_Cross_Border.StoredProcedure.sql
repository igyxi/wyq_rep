/****** Object:  StoredProcedure [DWD].[SP_Fact_Redeem_Order_Cross_Border]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Redeem_Order_Cross_Border] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-19       wangziming  Initial Version
-- 2023-05-25       wangziming  Alter table DWS_Account  to DW_Account
-- ========================================================================================
truncate table [DWD].[Fact_Redeem_Order_Cross_Border];
insert into [DWD].[Fact_Redeem_Order_Cross_Border]
	select 
		a.redemption_order_cross_border_id as [redemption_order_cross_border_id], 
		da.account_number as [member_card], 
		-- a.account_id,
		a.status as [status], 
		a.total_points as [total_points], 
		a.total_quantity as [total_quantity], 
		a.redemption_time as [redemption_time], 
		ds.store_code as [store_code], 
		-- a.redemption_place_id,
		a.process_type as [process_type],
		a.create_time as [create_time], 
		a.setting_time as [update_time], 
		-- a.create_by as [create_by], 
		-- a.setting_by as [setting_by], 
		-- a.timestamp as [timestamp],
		a.account_balance as [account_balance], 
		a.type as [type],
		--b.redemption_order_detail_cross_border_id as [redemption_order_detail_cross_border_id], 
		b.status as [detail_status],
		b.points as [points], 
		b.redeemable_item_id as [redeemable_item_id], 
		b.account_offer_id as [account_offer_id],
		--b.create_time as [detail_create_time], 
		--b.setting_time as [detail_setting_time], 
		--b.create_by as [detail_create_by], 
		--b.setting_by as [detail_setting_by], 
		--b.timestamp as [detail_timestamp],
		CURRENT_TIMESTAMP AS [insert_timestamp]
	from 
		ODS_CRM.redemption_order_cross_border a
		left join ODS_CRM.redemption_order_detail_cross_border b 
		on a.redemption_order_cross_border_id=b.redemption_order_cross_border_id
		left join DW_CRM.DIM_Store ds on ds.store_id=a.redemption_place_id
		left join DW_CRM.DW_Account da on da.account_id=a.account_id
	;
END
GO
