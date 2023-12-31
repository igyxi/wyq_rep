/****** Object:  StoredProcedure [DW_StoreAssortment].[SP_DWS_TXN_Store_SKU_SDL]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_StoreAssortment].[SP_DWS_TXN_Store_SKU_SDL] @start_date [varchar](10),@end_date [varchar](10) AS 
BEGIN
truncate table [DW_StoreAssortment].[DWS_TXN_Store_SKU_SDL];
insert into [DW_StoreAssortment].[DWS_TXN_Store_SKU_SDL]
select 
    format(trans_time, 'yyyy-MM') as statistic_period,
    store_id,
    product_id,
    sum(qtys) as qty,
    sum(sales) as sales,
    year(trans_time) [year],
    quarter,
    CURRENT_TIMESTAMP
from
(
    SELECT 
        FT.[trans_time],
        DT.quarter,
        FT.[trans_id],
        FT.[product_id] ,
        FT.[store_id],
        -- FT.[account_id] as [customer_id],
        FT.[qtys],
        -- DP.[price] as [sales_at_fullprice],
        FT.[sales]
        -- FT.[qtys] * DP.[price] as raw_sales,
        -- FT.[animation_sku_id] as [promo_code],
        -- DAS.[animation_name] as [promo_type],
        -- (FT.[qtys] * DP.[price] - FT.[sales]) as [margin],
        -- (FT.[qtys] * DP.[price] - FT.[sales]) as [discount],
        -- case when  FT.[qtys] * DP.[price] <> 0 then  (1 - FT.[sales] /  FT.[qtys] * DP.[price]) else 0 end  [discount_pct]
    FROM 
        [ODS_CRM].[FactTrans] FT
    -- inner join [ODS_CRM].[DimProduct] DP on FT.[product_id] = DP.[product_id]
    -- inner join [ODS_CRM].[DimStore] DS on FT.[store_id] = DS.[store_id]
    -- inner join [ODS_CRM].[DimAccount] DA on FT.[account_id] = DA.[account_id]
    -- left join [ODS_CRM].[DimAnimationsku] DAS on FT.[animation_sku_id] = DAS.[animation_sku_id]
    left join ODS_StoreAssortment.Dim_Date DT on cast(trans_time as date) = DT.date
    where cast(FT.[trans_time] as date) >= @start_date
    and cast(FT.[trans_time] as date) <= @end_date
) t
group by 
    format(trans_time, 'yyyy-MM'), 
    year(trans_time),
    store_id,
    product_id,
    quarter
END

GO
