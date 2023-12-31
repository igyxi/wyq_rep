/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Goods_Stock_History]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Goods_Stock_History] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Goods_Stock_History;
insert into STG_SIS.SIS_Goods_Stock_History
select 
		id,
		case when trim(sku_code) in ('','null') then null else trim(sku_code) end as sku_code,
		case when trim(location_id) in ('','null') then null else trim(location_id) end as location_id,
		case when trim(warehouse) in ('','null') then null else trim(warehouse) end as warehouse,
		stock,
		init_stock,
		update_flag,
		case when trim(location_id_description) in ('','null') then null else trim(location_id_description) end as location_id_description,
		ttl_plan_stock,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Goods_Stock_History
) t
where rownum = 1
END
GO
