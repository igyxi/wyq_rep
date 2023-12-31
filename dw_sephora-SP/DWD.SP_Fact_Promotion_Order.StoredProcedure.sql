/****** Object:  StoredProcedure [DWD].[SP_Fact_Promotion_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Promotion_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       Mac            Initial Version
-- 2022-02-16       Tali           change the oms logic
-- 2022-02-23       Tali           set member_card from member_info
-- 2022-02-23       Tali           filter pos order
-- 2022-02-24       Tali           filter oms order
-- 2022-07-12       Tali           fix oms order
-- 2022-11-30       Aan            add promotion_vb_adjustment_amount
-- 2023-04-24       wangzhichun    change DWS_Order_Promotion to DW_Promotion_Order
-- ========================================================================================

truncate table DWD.Fact_Promotion_Order;
-- insert into [DWD].[Fact_Promotion_Order]
-- select 
--     sales_order_number,
--     is_placed,
--     place_time,
--     channel_code,
--     sub_channel_code,
--     m.member_card,
--     Store_Code,
--     sku_code,
--     Quantity,
--     Sales_amount,
--     Discount,
--     Sales_VAT,
--     promotion_id,
--     promotion_code,
--     promotion_name,
--     promotion_content,
--     promotion_type,
--     promotion_adjustment_amount,
--     promotion_sku_adjustment_amount,
--     coupon_id,
--     offer_id,
--     create_time,
--     pos.source,
--     current_timestamp as  insert_timestamp
-- from
-- (
--     -- POS
--     select 
--         A.szBarcodeComplete as sales_order_number,
--         1 as is_placed,
--         try_cast(cast(CONVERT(date, SUBSTRING(a.szBarcodeComplete,17,8), 112) as nvarchar) + ' ' + SUBSTRING(a.szBarcodeComplete,25,2) + ':'+ SUBSTRING(a.szBarcodeComplete,27,2)+':' + SUBSTRING(a.szBarcodeComplete,29,2) as datetime) as place_time,
--         null as channel_code,
--         null as sub_channel_code,
--         B.KEY_CUSTOMER_szCustomerID as member_card,
--         substring(A.szBarcodeComplete, 3, 4) as Store_Code,
--         A.ARTICLE_szPOSItemID as sku_code,
--         sum(cast(A.dTaQty as int)) as Quantity,
--         sum(cast(A.dTaTotal as decimal)) as Sales_amount,
--         sum(cast(abs(E.dTotalDiscount) as decimal)) as Discount,
--         sum(convert(float, A.dTaTotal) - isnull(abs(E.dTotalDiscount), 0)) as Sales_VAT,
--         E.szDiscountID as promotion_id,
--         null as promotion_code,
--         E.szDiscDesc  as promotion_name,
--         max(E.szDiscountType) as promotion_content, 
--         E.lDiscListType as promotion_type,
--         null as promotion_adjustment_amount,
--         null as promotion_sku_adjustment_amount,
--         null as coupon_id,
--         null as offer_id,
--         CONVERT(varchar, e.CreateTime, 120) as create_time,
--         'POS' as source
--     from 
--         ODS_POS.TLOG_ART_SALE(nolock) A
--     join
--         ODS_POS.TLOG_HEADER H
--     on a.szBarcodeComplete = H.szBarcodeComplete
--     join
--         [ODS_SAP].[Dim_Store] s
--     on substring(A.szBarcodeComplete, 3, 4) = s.store_code
--     inner join 
--         ODS_POS.TLOG_DISC_INFO(nolock) E 
--     on A.szBarcodeComplete = E.szBarcodeComplete 
--     and A.Hdr_lTaCreateNmbr = E.Hdr_lTaRefToCreateNmbr
--     and A.BatchNo = E.BatchNo
--     left join 
--         ODS_POS.TLOG_CUSTOMER (nolock) B 
--     on A.szBarcodeComplete = B.szBarcodeComplete 
--     and A.BatchNo = B.BatchNo
--     where
--         H.szTaType in ('SA', 'RT')
--     and s.country_code = 'CN'
--     group by A.szBarcodeComplete
--             ,B.KEY_CUSTOMER_szCustomerID 
--             ,substring(A.szBarcodeComplete, 3, 4)
--             ,A.ARTICLE_szPOSItemID
--             ,E.szDiscountID
--             ,E.lDiscListType
--             ,E.szDiscDesc
--             ,CONVERT(varchar, e.CreateTime, 120)   
-- ) pos
-- left join
--     DWD.DIM_Member_Info m
-- on pos.member_card = m.member_card;


-- OMS
insert into [DWD].[Fact_Promotion_Order]
select
    a.order_id as sales_order_number,
    b.is_placed,
    b.place_time,
    b.channel_code,
    b.sub_channel_code,
    b.member_card,
    b.store_code as store_code,
    b.payment_amount,
    sku.vb_sku_code as virtual_sku_code,
    case when sku.vb_sku_code is not null then a.item_quantity else null end as vb_quantity,
    case when sku.vb_sku_code is not null then a.item_total_amount else null end as vb_total_amount,
    COALESCE(sku.bind_sku_code,a.item_sku_code) as item_sku_code,
    COALESCE(sku.bind_sku_quantity, a.item_quantity) as item_sku_quantity,
    COALESCE(sku.bind_sku_sap_price * sku.bind_sku_quantity, item_total_amount) as item_sku_total_amount,
    a.promotion_id,
    a.promotion_name,
    a.promotion_content,
    a.promotion_type,
    a.promotion_adjustment_amount,
    case when a.promotion_total_amount = 0 then 0.0 else a.promotion_adjustment_amount * (a.item_total_amount/a.promotion_total_amount) end as promotion_vb_adjustment_amount,
    case when a.promotion_total_amount = 0 then 0.0 else a.promotion_adjustment_amount * (a.item_total_amount/a.promotion_total_amount)*isnull(ratio,1) end as promotion_sku_adjustment_amount,
    a.coupon_code,
    a.offer_id,
    a.offer_type,
    a.offer,
    a.create_time,
    a.update_time,
    'OMS' as source,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DW_Order.DW_Promotion_Order a
join
(
    select distinct sales_order_number, is_placed, place_time, channel_code, sub_channel_code, store_code, member_card, payment_amount
    from DW_OMS.DW_Sales_Order_With_SKU
) b
on a.order_id = b.sales_order_number
left join
(
    select   vb_sku_code,bind_sku_code,bind_sku_quantity,bind_sku_sap_price, bind_sku_sap_price/sum(bind_sku_sap_price) over(partition by vb_sku_code) as ratio 
    from [DWD].[DIM_VB_SKU_REL]
    where bind_sku_type=1
)sku
on a.item_sku_code=sku.vb_sku_code  
;
END

GO
