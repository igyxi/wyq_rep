/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_Promotion_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_Promotion_Order] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-20       zeyuan           Initial Version
-- 2023-04-24       zeyuan             修改主题域 
-- ========================================================================================
truncate table [DW_OMS_Order].[DW_Promotion_Order];
insert into [DW_OMS_Order].[DW_Promotion_Order]
select 
	promotion.tid
	,null as merge_oid
	,promotion.promotion_id
	,promotion.promotion_name
	,promotion.promotion_desc as promotion_content
	,promotion.promotion_type
	,promotion.discount_fee as promotion_adjustment
	,promotion.coupon_id as coupon_code
	,null as offer_id
    ,null as offer_type
    ,null as offer
	,item.outer_sku_id as item_sku_code
	,item.num as quantity
	,item.total_fee as total_amount
	,sum(item.total_fee) over(partition by item.tid, promotion.promotion_id) as promotion_total_amount
	,promotion.data_create_time as create_time
	,promotion.data_update_time as update_time
    ,CURRENT_TIMESTAMP
from 
    ODS_New_OMS.OMS_STD_Trade_Promotion promotion 
inner join 
    ODS_New_OMS.OMS_STD_Trade_Item item 
on promotion.tid = item.tid
end
GO
