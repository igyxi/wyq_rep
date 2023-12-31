/****** Object:  StoredProcedure [TEMP].[TRANS_PROD_Product_Bak_20230608]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_PROD_Product_Bak_20230608] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Product.PROD_Product ;
insert into STG_Product.PROD_Product
select 
    id,
    type,
    case when trim(lower(name_cn)) in ('null', '') then null else trim(name_cn) end as name_cn,
    case when trim(lower(name_en)) in ('null', '') then null else trim(name_en) end as name_en,
    case when trim(lower(origin_name_cn)) in ('null', '') then null else trim(origin_name_cn) end as origin_name_cn,
    case when trim(lower(origin_name_en)) in ('null', '') then null else trim(origin_name_en) end as origin_name_en,
    case when trim(lower(slogan)) in ('null', '') then null else trim(slogan) end as slogan,
    case when trim(lower(desc_attr)) in ('null', '') then null else trim(desc_attr) end as desc_attr,
    status,
    o2o,
    offline,
    publish_time,
    unpublish_time,
    update_time,
    case when trim(lower(update_user)) in ('null', '') then null else trim(update_user) end as update_user,
    case when trim(lower(store)) in ('null', '') then null else trim(store) end as store,
    case when trim(lower(series_cn)) in ('null', '') then null else trim(series_cn) end as series_cn,
    case when trim(lower(series_en)) in ('null', '') then null else trim(series_en) end as series_en,
    case when trim(lower(desc_text)) in ('null', '') then null else trim(desc_text) end as desc_text,
    is_search,
    is_black,
    create_time,
    case when trim(lower(create_user)) in ('null', '') then null else trim(create_user) end as create_user,
    is_delete,
    case when trim(lower(findation)) in ('null', '') then null else trim(findation) end as findation,
    case when trim(lower(video_image_url)) in ('null', '') then null else trim(video_image_url) end as video_image_url,
    case when trim(lower(video_url)) in ('null', '') then null else trim(video_url) end as video_url,
    video_status,
    case when trim(lower(video_id)) in ('null', '') then null else trim(video_id) end as video_id,
    case when trim(lower(video_duration)) in ('null', '') then null else trim(video_duration) end as video_duration,
    spu_average_score,
	spu_average_count,
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_Product
where dt = @dt;
delete from ODS_Product.PROD_Product where dt <= cast(DATEADD(day,-3,convert(date, @dt)) as VARCHAR);
END


GO
