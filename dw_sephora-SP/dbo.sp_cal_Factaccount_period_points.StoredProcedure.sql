/****** Object:  StoredProcedure [dbo].[sp_cal_Factaccount_period_points]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_cal_Factaccount_period_points] AS

DECLARE @period_year INT;
DECLARE @period_month INT ;
DECLARE @period_date DATE;
DECLARE @period_last_month DATE;
--SET @period_date = DATEADD(month, datediff(month, 0, DATEADD(DAY,-1,GETDATE()))+1, 0)-1
SET @period_date = DATEADD(DAY,-2,dateadd(hour,8,GETDATE()))
SET @period_year = YEAR(@period_date);
SET @period_month = MONTH(@period_date);
SET @period_last_month = DATEADD(month, datediff(month, 0, @period_date), 0)

PRINT @period_date
PRINT @period_year
PRINT @period_month
PRINT @period_last_month

DELETE ODS_CRM.Factaccount_period_points
WHERE period_year = @period_year
AND period_month = @period_month


INSERT INTO ODS_CRM.Factaccount_period_points
SELECT o.account_id,da.account_number,@period_year period_year,@period_month period_month,@period_date period_date
,SUM(CASE WHEN o.creation_date <DATEADD(DAY,1,@period_date) THEN o.points ELSE 0 END) point_balances
,SUM(CASE WHEN o.creation_date <@period_last_month THEN o.points ELSE 0 END) last_month_points_balances
,SUM(CASE WHEN YEAR(o.creation_date) =@period_year AND MONTH(o.creation_date) = @period_month AND  p.points_category = 'accumulated' THEN o.points ELSE 0 end) current_month_earned_points
,SUM(CASE WHEN YEAR(o.creation_date) =@period_year AND MONTH(o.creation_date) = @period_month AND  p.points_category = 'used' THEN o.points ELSE 0 end) current_month_used_points
,SUM(CASE WHEN YEAR(o.creation_date) =@period_year AND MONTH(o.creation_date) = @period_month AND  p.points_category = 'expired' THEN o.points ELSE 0 end) current_month_expired_points
,GETDATE() create_time
,GETDATE() process_time
FROM ODS_CRM.DimOperation o WITH(NOLOCK)
INNER JOIN ODS_CRM.knPoints_type p
ON p.points_type_id = o.points_type_id
INNER JOIN ODS_CRM.DimAccount da
ON da.account_id = o.account_id
WHERE o.creation_date < DATEADD(DAY,1,@period_date)
GROUP BY o.account_id,da.account_number

