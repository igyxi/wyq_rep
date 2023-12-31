/****** Object:  StoredProcedure [STG_IMS].[TRANS_MKT_Promotiongoodsde]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_MKT_Promotiongoodsde] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.MKT_Promotiongoodsde;
insert into STG_IMS.MKT_Promotiongoodsde
select 
		id,
		promotion_id,
		goods_scope_id,
		goods_id,
		case when trim(goods_code) in ('','null','None') then null else trim(goods_code) end as goods_code,
		case when trim(goods_name) in ('','null','None') then null else trim(goods_name) end as goods_name,
		goods_qty,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(plat_form_goods_sku_id) in ('','null','None') then null else trim(plat_form_goods_sku_id) end as plat_form_goods_sku_id,
		single_product_id,
		shop_id,
		current_timestamp as insert_timestamp
from  ODS_IMS.MKT_Promotiongoodsde
where dt = @dt
END

GO
