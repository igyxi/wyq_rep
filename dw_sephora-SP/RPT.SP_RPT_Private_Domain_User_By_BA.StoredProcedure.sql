/****** Object:  StoredProcedure [RPT].[SP_RPT_Private_Domain_User_By_BA]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Private_Domain_User_By_BA] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       fenglu        Initial Version
-- 2022-12-08       litao         ADD store_code not in ('DV','EB','GE','GN','HR','IT','OMR','RO','RS','South','SU','SU - HQ','West')
-- ========================================================================================
	
DELETE FROM [RPT].[RPT_Private_Domain_User_By_BA]
WHERE stat_date = @dt;

      
      
INSERT INTO [RPT].[RPT_Private_Domain_User_By_BA]
SELECT a.date_str as stat_date
       ,ba_staff_no as ba_code
       ,store_code
       ,COUNT(DISTINCT case when bind_date < a.date_str and status = 0 then unionid else null end) as t_num
	   ,COUNT(DISTINCT case when bind_date = a.date_str and status = 0 then unionid else null end) as new_num
       ,COUNT(DISTINCT case when bind_date = a.date_str and status <> 0 then unionid else null end) as old_num
       ,CURRENT_TIMESTAMP as insert_timestamp
FROM (
	SELECT date_str
	FROM DWD.DIM_Calendar
	WHERE date_str = @dt
) a
LEFT JOIN (
	SELECT ba_staff_no 
	        ,bind_date
	        ,unionid
	        ,store_code
	        ,status
	FROM (
		SELECT format(bind_time, 'yyyy-MM-dd') as bind_date
		       ,unionid
		       ,store_code
		       ,ba_staff_no
		       ,status
		       ,row_number() over (partition by unionid, ba_staff_no order by bind_time desc) as ro     
		FROM DWD.Fact_Member_BA_Bind
		WHERE bind_time IS NOT NULL AND unionid IS NOT NULL 
		and store_code not in ('DV','EB','GE','GN','HR','IT','OMR','RO','RS','South','SU','SU - HQ','West')
	) a
	WHERE ro = 1 AND bind_date < DATEADD(DAY, 2, @dt) 
) b ON a.date_str >= b.bind_date
GROUP BY a.date_str ,ba_staff_no ,store_code

END 
GO
