/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Product_Comment]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Product_Comment] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-31       wangzhichun        Initial Version
-- 2022-04-06       wangzhichun        add column
-- 2023-06-02       Leozhai            Add logic to convert varbinary
-- ========================================================================================
truncate table STG_Product.PROD_Product_Comment ;
insert into STG_Product.PROD_Product_Comment
select 
    case when trim(uuid) in ('null', '') then null else trim(uuid) end as uuid,
    case when trim(order_id) in ('null', '') then null else trim(order_id) end as order_id,
    score,
    case when trim(content) in ('null', '') then null else trim(content) end as content,
    product_id,
    sku_id,
    user_id,
    case when trim(photo) in ('null', '') then null else trim(photo) end as photo,
    case when trim(nick_name) in ('null', '') then null else trim(nick_name) end as nick_name,
    case when trim(card_type) in ('null', '') then null else trim(card_type) end as card_type,
    update_time,
    create_time,
    sequence,
    type,
    is_disable,
    post_id,
    status,
    case when trim(kol_user_level) in ('null', '') then null else trim(kol_user_level) end as kol_user_level,
    case when trim(audit_status) in ('null', '') then null else trim(audit_status) end as audit_status,
    detect_porn,
    case when trim(detect_items) in ('null', '') then null else trim(detect_items) end as detect_items,
    is_show,
    comment_position,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(reply_audit_status) in ('null', '') then null else trim(reply_audit_status) end as reply_audit_status,
    shu_mei_recommend,
    reply_status,
    case when trim(reply_comment) in ('null', '') then null else trim(reply_comment) end as reply_comment,
    reply_time,
    reply_audit_type,
    is_anonymous,
	sync_beauty_status,
	click_count,
	attribute_average,
	total_evaluation_score,
    --case when trim(image_paths) in ('null', '') then null else trim(image_paths) end as image_paths,
    convert(varchar(4000),image_paths,0) as image_paths,
    --case when trim(attr_consumer) in ('null', '') then null else trim(attr_consumer) end as attr_consumer,
    convert(varchar(4000),attr_consumer,0) as attr_consumer,
    --case when trim(attr_log) in ('null', '') then null else trim(attr_log) end as attr_log,
    convert(varchar(4000),attr_log,0) as attr_log,
    --case when trim(label_consumer) in ('null', '') then null else trim(label_consumer) end as label_consumer,
    convert(varchar(4000),label_consumer,0) as label_consumer,
    --case when trim(label_log) in ('null', '') then null else trim(label_log) end as label_log,	
    convert(varchar(4000),label_log,0) as label_log,
	opt_type,
    ve_sku_id,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by uuid order by dt desc) rownum from ODS_Product.PROD_Product_Comment
) t
where rownum = 1
END


GO
