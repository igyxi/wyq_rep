/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_OBA_Performance_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_OBA_Performance_Monthly] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- 2023-06-19       tianjinzhao    all_oba_orders/amount去掉ABS逻辑
-- ========================================================================================
DELETE FROM [DW_SmartBA].[RPT_OBA_Performance_Monthly] WHERE statistic_month = CAST(@dt AS VARCHAR(7));
INSERT INTO [DW_SmartBA].[RPT_OBA_Performance_Monthly]
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

--[DW_SmartBA].[SP_RPT_OBA_Performance_Monthly] '2021-09-30'

--[DW_SmartBA].[SP_RPT_OBA_Performance_Monthly] '2021-10-31'

--[DW_SmartBA].[SP_RPT_OBA_Performance_Monthly] '2021-09-30'
GO
