/****** Object:  StoredProcedure [RPT].[SP_RPT_Employee_Frequent_Purchase_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Employee_Frequent_Purchase_Detail] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-01       Joey           Initial Version
-- 2022-10-13       Tali           update
-- 2023-05-15       wangziming     update   where a.trans_time => where FORMAT(a.trans_time,'yyyy-MM-dd')
-- 2023-05-17       leozhai        change source to DW_Trans_Order_With_SKU
-- ========================================================================================
DELETE FROM [RPT].[RPT_Employee_Frequent_Purchase_Detail] 
WHERE FORMAT([Purchase_Date],'yyyy-MM') = FORMAT(@dt, 'yyyy-MM');
WITH sales_detail as
(
    SELECT
        FORMAT(a.trans_time,'yyyy') as [Year]
        , FORMAT(a.trans_time,'MM') as [Month]
        , b.member_card as [Card Number]
        , b.full_name as [Full Name]
        , a.trans_time as [Purchase Date]
        , a.store_code as [Store Code]
        , a.invc_no as [Invc No]
        , a.item_sku_code as [SKU]
        , c.crm_brand  as [Brand Name]
        , c.crm_sku_name as [Product Name]
        , a.item_quantity as [Product Qty]
        , a.item_apportion_amount as [Real Amount]
        , c.crm_price as [price]
            -- FROM [DWD].[Fact_Sales_Order] a
    FROM 
        DW_CRM.DW_Trans_Order_With_SKU a
    JOIN 
        DWD.DIM_Member_Info b
    on a.member_id = b.member_id
    JOIN 
        DWD.DIM_SKU_Info c
    ON a.item_sku_code = c.sku_code
    where  
        1 = 1
    and FORMAT(a.trans_time,'yyyy-MM-dd') > DATEADD(MONTH, -1,EOMONTH(@dt))
    and FORMAT(a.trans_time,'yyyy-MM-dd') < DATEADD(DAY, 1, EOMONTH(@dt))
    and b.is_employee = 1

)

INSERT INTO [RPT].[RPT_Employee_Frequent_Purchase_Detail]
SELECT DISTINCT
    [a].[Year],
    [a].[Month],
    [a].[Card Number],
    [a].[Full Name],
    c.[Sum of Purchase Amount],
    [a].[Purchase Date],
    [a].[Store Code],
    [a].[Invc No],
    b.[Purchase Amount],
    [a].[SKU],
    [a].[Brand Name],
    [a].[Product Name],
    [a].[Product Qty],
    [a].[Real Amount],
    case when ([a].[Real Amount] = 0 or a.[Product Qty] = 0) then 0 else [a].[Real Amount]/[a].[Product Qty] END as [Real Unit Price],
    a.price as [Org Unit Price],
    [a].[Product Qty] * a.price as [Total Org Price wT],
    case when ([a].[Real Amount] = 0 or a.price = 0 or a.[Product Qty] = 0) then 0 else 1 - ([a].[Real Amount]/[a].[Product Qty])/a.price end as [Discount],
    current_timestamp as insert_timestamp
-- INTO [RPT].[Employee_Frequent_Purchase_Detail]
FROM 
    sales_detail a
JOIN 
(
    SELECT [Invc No], SUM([Real Amount]) as [Purchase Amount]  FROM sales_detail  GROUP BY [Invc No]
) b
ON a.[Invc No] = b.[Invc No]
JOIN
(
    SELECT [Year], [Month], [Card Number], SUM([Real Amount]) AS [Sum of Purchase Amount] FROM sales_detail GROUP BY [Year], [Month], [Card Number]
) c
ON a.[Year] = c.[Year]
and a.[Month] = c.[Month]
and a.[Card Number] = c.[Card Number]

END
GO
