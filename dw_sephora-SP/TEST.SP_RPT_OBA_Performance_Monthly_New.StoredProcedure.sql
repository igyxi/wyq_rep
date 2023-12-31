/****** Object:  StoredProcedure [TEST].[SP_RPT_OBA_Performance_Monthly_New]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_OBA_Performance_Monthly_New] @dt [VARCHAR](10) AS
BEGIN
DELETE FROM [DW_SmartBA].[RPT_OBA_Performance_Monthly_New] WHERE statistic_month = CAST(@dt AS VARCHAR(7));
INSERT INTO [DW_SmartBA].[RPT_OBA_Performance_Monthly_New]
SELECT
	CAST(@dt AS VARCHAR(7)) AS statistic_month
   ,utm_content
   ,utm_term
   ,COUNT(DISTINCT sales_order_number) AS all_oba_orders
   ,COUNT(DISTINCT member_id) AS all_oba_buyers
   ,SUM(item_apportion_amount) AS all_oba_amount
   ,COUNT(DISTINCT CASE WHEN oba_overlap = 0 THEN sales_order_number ELSE NULL END) AS orders
   ,COUNT(DISTINCT CASE WHEN oba_overlap = 0 THEN member_id ELSE NULL END) AS buyers
   ,SUM(CASE WHEN oba_overlap = 0 THEN item_apportion_amount ELSE NULL END) AS amount
   ,COUNT(DISTINCT CASE WHEN oba_overlap = 0 AND fin_cd = 1 THEN sales_order_number ELSE NULL END) AS acutal_orders
   ,COUNT(DISTINCT CASE WHEN oba_overlap = 0 AND fin_cd = 1 THEN member_id ELSE NULL END) AS acutal_buyers
   ,SUM(CASE WHEN oba_overlap = 0 AND fin_cd = 1 THEN item_apportion_amount ELSE NULL END) AS acutal_amount
   ,current_timestamp AS insert_timestamp
FROM [DW_SmartBA].[RPT_OBA_Sales_Order_Detail]
WHERE CAST(CAST(fin_time AS DATE) AS VARCHAR(7)) = CAST(@dt AS VARCHAR(7))
AND fin_cd >= 1
GROUP BY utm_content
		,utm_term
;
END
GO
