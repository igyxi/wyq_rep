/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Activity_Brand]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Activity_Brand] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Activity_Brand;
insert into STG_SIS.SIS_Activity_Brand
select 
		id,
		activity_id,
		case when trim(brand_name_cn) in ('','null') then null else trim(brand_name_cn) end as brand_name_cn,
		case when trim(brand_name_en) in ('','null') then null else trim(brand_name_en) end as brand_name_en,
		case when trim(logo_image) in ('','null') then null else trim(logo_image) end as logo_image,
		case when trim(recommend_flag) in ('','null') then null else trim(recommend_flag) end as recommend_flag,
		sort,
		status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Activity_Brand
) t
where rownum = 1
END
GO
