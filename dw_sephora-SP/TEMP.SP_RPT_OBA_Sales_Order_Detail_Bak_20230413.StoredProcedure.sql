/****** Object:  StoredProcedure [TEMP].[SP_RPT_OBA_Sales_Order_Detail_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OBA_Sales_Order_Detail_Bak_20230413] AS
begin
truncate table [DW_SmartBA].[RPT_OBA_Sales_Order_Detail];
insert into [DW_SmartBA].[RPT_OBA_Sales_Order_Detail]
select
    a.sales_order_number,
    a.purchase_order_number,
    c.order_time,
    c.payment_time,
    a.shipping_time,
    a.fin_time,
    a.fin_cd,
    a.placed_cd,
    c.store_cd,
    c.channel_cd,
    c.province,
    c.city,
    c.type_cd,
    a.item_sku_cd,
    a.item_quantity,
    a.item_apportion_amount,
    c.item_name,
    c.item_brand_name,
    c.item_brand_type,
    c.item_category,
    c.item_segment,
    a.utm_term,
    a.utm_content,
    a.member_id,
    a.member_card,
    a.member_card_grade,
    c.member_new_status as new_to_eb_cd,
    case
         when c.channel_order_placed_seq = 1 and c.channel_cd = 'MINIPROGRAM' and c.member_card_level <= 2 then 'BRAND_NEW' 
         when c.channel_order_placed_seq = 1 and c.channel_cd = 'MINIPROGRAM' and c.member_card_level >= 3 then 'CONVERT_NEW' 
         when c.channel_order_placed_seq <> 1 and c.channel_cd = 'MINIPROGRAM' then 'RETURN'
         else null end 
    as new_to_mnp_cd,
    a.is_checked_unionid,
    a.pay_method,
	CASE WHEN b.sales_order_number is NULL THEN 0 ELSE 1 END AS [oba_overlap],
    current_timestamp as insert_timestamp
from
(
    select
        *
    from
        [DW_SmartBA].[RPT_SmartBA_Orders]
    where 
        utm_content='2222'
)a
left join 
    (select 
        order_time,
        payment_time,
        store_cd,
        channel_cd,
        province,
        city,
        type_cd,
        item_name,
        item_brand_name,
        item_brand_type,
        item_category,
        item_segment,
        sales_order_number,
        purchase_order_number,
        item_sku_cd,
        member_new_status,
        channel_order_placed_seq,
        member_card_level
    from
        DW_OMS.RPT_Sales_Order_SKU_Level
    where
        isnull(split_type_cd,'')<>'SPLIT_ORIGIN'
    and 
        isnull(type_cd,0)<>2
    ) c
on a.sales_order_number = c.sales_order_number
and a.purchase_order_number = c.purchase_order_number
and a.item_sku_cd = c.item_sku_cd
left join
     DW_Transcosmos.DWS_IM_Service_Sales_Order_Detail b
on a.sales_order_number = b.sales_order_number
--where 
--    b.sales_order_number is null
;
end
GO
