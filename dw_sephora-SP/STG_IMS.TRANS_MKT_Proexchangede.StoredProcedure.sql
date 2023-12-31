/****** Object:  StoredProcedure [STG_IMS].[TRANS_MKT_Proexchangede]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_MKT_Proexchangede] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.MKT_Proexchangede;
insert into STG_IMS.MKT_Proexchangede
select 
		id,
		promotion_id,
		promotionde_id,
		goods_id,
		case when trim(goods_code) in ('','null','None') then null else trim(goods_code) end as goods_code,
		qty_gift,
		qty_limit,
		qty_given,
		single_product_id,
		case when trim(single_product_name) in ('','null','None') then null else trim(single_product_name) end as single_product_name,
		case when trim(single_product_code) in ('','null','None') then null else trim(single_product_code) end as single_product_code,
		case when trim(bar_code) in ('','null','None') then null else trim(bar_code) end as bar_code,
		case when trim(single_product_desc) in ('','null','None') then null else trim(single_product_desc) end as single_product_desc,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.MKT_Proexchangede
where dt = @dt
END

GO
