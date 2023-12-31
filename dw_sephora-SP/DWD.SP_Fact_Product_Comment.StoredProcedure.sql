/****** Object:  StoredProcedure [DWD].[SP_Fact_Product_Comment]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Product_Comment] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     	Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-22       houshuangqiang  Initial Version
-- 2022-10-27       houshuangqiang  add opt_type field
-- ========================================================================================
truncate table DWD.Fact_Product_Comment;
insert into DWD.Fact_Product_Comment
select  a.uuid,
        a.order_id as sales_order_number,
		d.member_card,
		a.card_type,
		a.product_id,
        b.name_cn as spu_name_cn,
        b.name_en as spu_name_en,
		c.sku_id,
		c.sku_code,
		c.sku_name,
		a.content,
        case when a.type = 1 then N'商品讨论'
	    	 when a.type = 2 then N'购买体验'
	    	 when a.type = 3 then N'口碑中心(KOL)'
	    	 else N'未知'
	    end as comment_type,
		a.score,
        a.total_evaluation_score,
        a.attribute_average,
        a.click_count as like_count,
		a.post_id as beautyin_post_id,
		a.audit_status,
	    a.status,
        a.opt_type,
        case when a.image_paths is not null then 1 else 0 end as is_image,
		a.detect_porn as is_detect,
        a.is_disable,
		a.is_anonymous,
		a.is_delete,
		a.create_time,
		a.update_time,
        current_timestamp as insert_timestamp
from
	STG_Product.PROD_Product_Comment a
left join
	STG_Product.PROD_Product b
on a.product_id = b.id
left join
	STG_Product.PROD_SKU c
on a.sku_id = c.sku_id
left join
	dwd.DIM_Member_Info d
on a.user_id = d.eb_user_id
;
end

GO
