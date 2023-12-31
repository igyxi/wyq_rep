/****** Object:  StoredProcedure [TEMP].[SP_RPT_Douyin_Order_Item_Analysis_Bak20230227]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Douyin_Order_Item_Analysis_Bak20230227] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-24       litao           Initial Version
-- ========================================================================================


truncate table RPT.RPT_Douyin_Order_Item_Analysis; 
insert into RPT.RPT_Douyin_Order_Item_Analysis
select
    author_name as store_name,
    order_date as dt,
    order_source,
    category,
    brand_type,
    brand_name,
    item_name,
    item_sku as item_code,
    sum(apportion_amount) as order_amt,
    count(distinct sales_order_number) as order_cnts,
    sum(item_quantity) as order_item_cnts,
    sum(case when related_id is not null then refund_amount else 0 end) as refund_order_amt,
    count(distinct case when related_id is not null then sales_order_number end) as refund_order_cnts,
    max(third_server_rate) as third_server_rate,
    sum(third_server_amount) as third_server_amount,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DW_OMS.DWS_Douyin_Sales_Order_With_VB
where
    is_placed = 1
group by
    author_name,
    order_date,
    category,
    brand_type,
    item_name,
    item_sku,
    order_source,
    brand_name
;
END
GO
