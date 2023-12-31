/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_OBA_Sales_Order_Detail_new]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_OBA_Sales_Order_Detail_new] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-02-21       wangzhichun        update source table
-- 2023-06-27       zeyuan             change item_brand_name&item_brand_type&item_category&item_segment columns
-- ========================================================================================
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
    trim(sku.sap_brand_name) as item_brand_name,
    trim(sku.market_description) as item_brand_type,
    trim(sku.category) as item_category,
    trim(sku.segment) as item_segment,
    a.utm_term,
    a.utm_content,
    a.member_id,
    a.member_card,
    a.member_card_grade,
    so.member_new_status as new_to_eb_cd,
    case
         when so.channel_order_placed_seq = 1 and c.store_cd = 'MINIPROGRAM' and c.member_card_level <= 2 then 'BRAND_NEW' 
         when so.channel_order_placed_seq = 1 and c.store_cd = 'MINIPROGRAM' and c.member_card_level >= 3 then 'CONVERT_NEW' 
         when so.channel_order_placed_seq <> 1 and c.store_cd = 'MINIPROGRAM' then 'RETURN'
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
(   
    select 
        fso.order_time,
        fso.payment_time,
        case when fso.channel_code='SOA' THEN 'S001' ELSE fso.sub_channel_code end store_cd,
        case when fso.sub_channel_code='TMALL006' then 'TMALL_WEI'
            when fso.sub_channel_code='TMALL004' then 'TMALL_CHALING'
            when fso.sub_channel_code='TMALL005' then 'TMALL_PTR'
            when fso.sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
            when fso.sub_channel_code='DOUYIN001' then 'DOUYIN'
            when fso.sub_channel_code='REDBOOK001' then 'REDBOOK'
            when fso.sub_channel_code='JD003' then 'JD_FCS'
            when fso.sub_channel_code in ('JD001','JD002') then 'JD'
            when fso.sub_channel_code='GWP001' then 'OFF_LINE'
            else fso.sub_channel_code 
            end as channel_cd,
        fso.province,
        fso.city,
        fso.type_code as type_cd,
        fso.item_sku_name as item_name,
        fso.sales_order_number,
        fso.purchase_order_number,
        fso.item_sku_code as item_sku_cd,
        case 
            when fso.member_card_grade = 'PINK'  then 1
            when fso.member_card_grade = 'NEW' then 2
            when fso.member_card_grade = 'WHITE' then 3
            when fso.member_card_grade = 'BLACK' then 4
            when fso.member_card_grade = 'GOLD' then 5
            else 0
        end as member_card_level
    from
        DWD.Fact_Sales_Order fso
    where
        isnull(type_code,0)<>2
        and fso.source='OMS'
) c
on a.sales_order_number = c.sales_order_number
and a.purchase_order_number = c.purchase_order_number
and a.item_sku_cd = c.item_sku_cd
left join 
(
    select 
        member_new_status,
        channel_order_placed_seq,
        sales_order_number
    from 
        [RPT].[RPT_Sales_Order_Basic_Level]

) so
on c.sales_order_number=so.sales_order_number
left join 
    DWD.DIM_SKU_Info sku
on c.item_sku_cd=sku.sku_code
left join
     DW_Transcosmos.DWS_IM_Service_Sales_Order_Detail b
on a.sales_order_number = b.sales_order_number
;
end
GO
