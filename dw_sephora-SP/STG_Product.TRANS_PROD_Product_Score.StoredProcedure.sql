/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Product_Score]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Product_Score] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Product.PROD_Product_Score ;
insert into STG_Product.PROD_Product_Score
select 
    product_id,
    offer_price,
    promotion,
    new_procut,
    official_site,
    exclusive_brand,
    sephora_brand,
    total_amount,
    pv,
    tr_sequence,
    top_or_bottom,
    create_time,
    lastupdate_time,
    tr_score,
    count_score,
    sold_date,
    total_sales,
    tr_score2,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_Product_Score
where dt = @dt
END
GO
