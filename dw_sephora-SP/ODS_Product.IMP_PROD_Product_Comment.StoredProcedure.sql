/****** Object:  StoredProcedure [ODS_Product].[IMP_PROD_Product_Comment]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Product].[IMP_PROD_Product_Comment] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Product.PROD_Product_Comment where dt = @dt;
insert into ODS_Product.PROD_Product_Comment
select 
    a.uuid,
	order_id,
	score,
	content,
	product_id,
	sku_id,
	user_id,
	photo,
	nick_name,
	card_type,
	update_time,
	create_time,
	sequence,
	type,
	is_disable,
	post_id,
	status,
	kol_user_level,
	audit_status,
	detect_porn,
	detect_items,
	is_show,
	comment_position,
	create_user,
	update_user,
	is_delete,
    reply_audit_status,
    shu_mei_recommend,
    reply_status,
    reply_comment,
    reply_time,
    reply_audit_type,
    @dt as dt
from 
(
    select * from ODS_Product.PROD_Product_Comment where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select uuid from ODS_Product.WRK_PROD_Product_Comment
) b
on a.uuid = b.uuid
where b.uuid is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_Product.WRK_PROD_Product_Comment;
delete from ODS_Product.PROD_Product_Comment where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
