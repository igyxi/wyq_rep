/****** Object:  StoredProcedure [STG_IMS].[TRANS_GDS_Platformgoods]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_GDS_Platformgoods] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.GDS_Platformgoods;
insert into STG_IMS.GDS_Platformgoods
select 
		id,
		case when trim(platformgoodsid) in ('','null','None') then null else trim(platformgoodsid) end as platformgoodsid,
		case when trim(platformgoodsskuid) in ('','null','None') then null else trim(platformgoodsskuid) end as platformgoodsskuid,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		singleproductid,
		case when trim(singleproductcode) in ('','null','None') then null else trim(singleproductcode) end as singleproductcode,
		case when trim(singleproductname) in ('','null','None') then null else trim(singleproductname) end as singleproductname,
		shopid,
		case when trim(shopcode) in ('','null','None') then null else trim(shopcode) end as shopcode,
		case when trim(shopname) in ('','null','None') then null else trim(shopname) end as shopname,
		case when trim(createby) in ('','null','None') then null else trim(createby) end as createby,
		createdate,
		case when trim(modifyby) in ('','null','None') then null else trim(modifyby) end as modifyby,
		modifydate,
		case when trim(issetmeal) in ('','null','None') then null else trim(issetmeal) end as issetmeal,
		issyn,
		enabled,
		sj_type,
		sync_kc,
		case when trim(syn_oms_status) in ('','null','None') then null else trim(syn_oms_status) end as syn_oms_status,
		case when trim(syn_platform_status) in ('','null','None') then null else trim(syn_platform_status) end as syn_platform_status,
		case when trim(error_msg) in ('','null','None') then null else trim(error_msg) end as error_msg,
		syn_date,
		syn_qty,
		online_shop_stock,
		platform_goods_price,
		platform_id,
		case when trim(outer_id) in ('','null','None') then null else trim(outer_id) end as outer_id,
		approve_status,
		case when trim(goods_code) in ('','null','None') then null else trim(goods_code) end as goods_code,
		current_timestamp as insert_timestamp
from  ODS_IMS.GDS_Platformgoods
where dt = @dt
END
GO
