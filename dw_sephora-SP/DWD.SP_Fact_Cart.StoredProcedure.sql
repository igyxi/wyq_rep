/****** Object:  StoredProcedure [DWD].[SP_Fact_Cart]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Cart] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-20       lizeyuan           Initial Version
-- 2023-03-24       houshuangqiang     change logic
-- ========================================================================================
truncate table DWD.Fact_Cart;
insert into DWD.Fact_Cart
select 
    concat_ws('|', user_id, store, sku_id, type) as id
	,a.user_id
	,member.member_card
	,a.channel
	,a.store
	,a.sku_id
	,sku.sku_code
	,sku.eb_sku_name
    ,sku.eb_sku_name_cn
	,sku.eb_brand_name
	,sku.eb_category
	,a.quantity
	,a.live_roomId
    ,a.type
	,a.checked
	,a.create_time
    ,a.last_update
	,a.expire_time
    ,current_timestamp as insert_timestamp
from
    ODS_ShopCart.Cart a
left join
    DWD.DIM_SKU_INFO sku
on a.sku_id = sku.eb_sku_id
left join
     DWD.DIM_Member_Info member
on a.user_id = member.eb_user_id
END

GO
