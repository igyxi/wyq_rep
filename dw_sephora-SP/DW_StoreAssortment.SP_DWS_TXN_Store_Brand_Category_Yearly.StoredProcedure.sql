/****** Object:  StoredProcedure [DW_StoreAssortment].[SP_DWS_TXN_Store_Brand_Category_Yearly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_StoreAssortment].[SP_DWS_TXN_Store_Brand_Category_Yearly] AS
BEGIN
truncate table DW_StoreAssortment.DWS_TXN_Store_Brand_Category_Yearly;
with sales_monthly AS
(
select 
    a.[month],
    a.[year],
    b.store_code,
    case when b.store_id is not null then 1 else 0 end as cn_offline,
    c.brand,
    c.brand_type,
    c.category,
    c.[Range],
    c.Segment,
    sum(a.qty) as qty,
    sum(a.sales) as sales
from 
    DW_StoreAssortment.DWS_TXN_Store_SKU_SDL a 
left join
    DW_StoreAssortment.DIM_Offline_Store_Attr b
on a.store_id = b.store_id
left join 
    ODS_CRM.DimProduct c on a.product_id = c.product_id
left join
    ODS_StoreAssortment.Premium_Line d
on c.brand = d.brand collate Chinese_PRC_CS_AI_WS 
and c.sku_code = d.material collate Chinese_PRC_CS_AI_WS
group by 
    a.[month],
    a.[year],
    b.store_code,
    case when b.store_id is not null then 1 else 0 end,
    c.brand,
    c.brand_type,
    c.category,
    c.[Range],
    c.Segment
)

insert into DW_StoreAssortment.DWS_TXN_Store_Brand_Category_Yearly
select 
    store_code,
    year,
    brand,
    brand_type,
    category,
    Range,
    Segment,
    sum(qty) as sum_qty,
    sum(sales) as sum_sales,
    count(1) as cnt_months_w_sales,
    min([month]) as start_month_w_sales,
    CURRENT_TIMESTAMP
from 
    sales_monthly
where 
    cn_offline = 1
and brand is not null
and sales >0
and [month] <> '2020-02'
and upper(category) not in (
    'ESTORE',
    'GIFT FOR PURCHASE',
    'GIFT VOUCHERS',
    'IFLS CODES',
    'MAKE UP TESTER',
    'MAKE-UP SAMPLES',
    'OTHERS',
    'SKINCARE DEMO',
    'SKINCARE SAMPLES',
    'TOILETRIES',
    'UNRECOGNIZED BARCODE'
)
group by 
    store_code,
    year,
    brand,
    brand_type,
    category,
    Range,
    Segment
END

GO
