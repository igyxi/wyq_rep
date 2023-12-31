/****** Object:  StoredProcedure [DWD].[SP_Fact_Redeem_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Redeem_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       Mac            Initial Version
-- 2022-01-17       Tali           change store_id to store_code
-- 2022-03-08       Tali           rebuild
-- 2022-03-23       Tali           change olap to oltp table
-- ========================================================================================

truncate table DWD.Fact_Redeem_Order;
insert into DWD.Fact_Redeem_Order            
select
    a.redemption_order_id as redeem_order_id,
    a.serial_num as serial_number,
    da.member_card,
    a.redemption_time as redeem_time,
    b.[status] as redeem_order_status,
    s.store_code as redeem_store_code,
    b.points as redeem_points,
    ri.sku  as redeem_item_sku_code,
    ri.title  as redeem_item_name,
    ric.redeemable_item_channel_name  as redeemable_item_channel,
    rit.redeemable_item_type_name  as redeemable_item_type,
    b.account_offer_id as coupon_offer_id,
    a.covert_type,
    a.process_type,
    b.create_time,
    b.setting_time,
	'CRM' as source,
	current_timestamp as insert_timestamp 
FROM  
    ods_crm.redemption_order a  
join
    ods_crm.redemption_order_detail b
on a.redemption_order_id = b.redemption_order_id
INNER JOIN 
    ODS_CRM.redeemable_item ri
ON ri.redeemable_item_id = b.redeemable_item_id
INNER JOIN 
    ODS_CRM.redeemable_item_type rit
ON rit.redeemable_item_type_id = ri.redeemable_item_type_id
INNER JOIN 
    ODS_CRM.redeemable_item_channel ric
ON ric.redeemable_item_channel_id = ri.redeemable_item_channel_id
left join
    DW_CRM.dim_store s
on a.redemption_place_id = s.store_id
left JOIN 
    DWD.DIM_Member_Info da 
ON da.member_id = a.account_id
END

GO
