/****** Object:  StoredProcedure [TEMP].[SP_RPT_Employee_Frequent_Purchase_Detail_Bak20221013]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Employee_Frequent_Purchase_Detail_Bak20221013] @dt [date] AS
BEGIN

-- EXECUTE [RPT].[SP_RPT_Employee_Frequent_Purchase_Detail] '2022-05-31'
    -- TRUNCATE TABLE [RPT].[Employee_Frequent_Purchase_Detail];
    -- drop table [RPT].[Employee_Frequent_Purchase_Detail]
DELETE FROM [RPT].[Employee_Frequent_Purchase_Detail] 
WHERE FORMAT([Purchase Date],'yyyy-MM') = FORMAT(@dt, 'yyyy-MM');

    WITH
        sales_detail
        as
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
            FROM DW_CRM.DWS_Trans_Order_With_SKU a
                JOIN DWD.DIM_Member_Info b
                on a.member_id = b.member_id
                -- JOIN ODS_CRM.DimProduct c
                -- ON a.item_sku_code = c.product_id
                JOIN DWD.DIM_SKU_Info c
                ON a.item_sku_code = c.sku_code
            where  1 = 1
                -- and FORMAT(a.trans_time,'yyyy-MM') = FORMAT(@dt, 'yyyy-MM')
                and a.trans_time > DATEADD(MONTH, -1,EOMONTH(@dt))
                and a.trans_time < DATEADD(DAY, 1, EOMONTH(@dt))
                and b.is_employee = 1
                -- AND a.item_apportion_amount > 0.1
                -- AND a.item_quantity > 0
        )

    INSERT INTO [RPT].[Employee_Frequent_Purchase_Detail]
    SELECT [a].[Year],
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
        case when ([a].[Real Amount] = 0 or a.price = 0 or a.[Product Qty] = 0) then 0 else 1 - ([a].[Real Amount]/[a].[Product Qty])/a.price end as [Discount]
    -- INTO [RPT].[Employee_Frequent_Purchase_Detail]
    FROM sales_detail a
        JOIN (
SELECT [Invc No], SUM([Real Amount]) as [Purchase Amount]
        FROM sales_detail
        GROUP BY [Invc No]
) b
        ON a.[Invc No] = b.[Invc No]
        JOIN (
    SELECT [Year], [Month], [Card Number], SUM([Real Amount]) AS [Sum of Purchase Amount]
        FROM sales_detail
        GROUP BY [Year], [Month], [Card Number]
) c
        ON a.[Year] = c.[Year]
            and a.[Month] = c.[Month]
            and a.[Card Number] = c.[Card Number]

END
GO
