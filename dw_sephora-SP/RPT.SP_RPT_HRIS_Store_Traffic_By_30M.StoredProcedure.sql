/****** Object:  StoredProcedure [RPT].[SP_RPT_HRIS_Store_Traffic_By_30M]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_HRIS_Store_Traffic_By_30M] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-17       weichen           Initial Version
-- ========================================================================================
DELETE FROM RPT.RPT_HRIS_Store_Traffic_By_30M WHERE FORMAT(start_time,'yyyy-MM-dd')>=FORMAT(DATEADD(Day,-11,cast(@dt AS DATE)), 'yyyy-MM-dd');

;WITH traffic AS(
SELECT 
	FORMAT(START_TIME,'yyyy-MM-dd') AS [date],
	left(right(format(START_TIME,'yyyy-MM-dd HH:mm:ss'),8),2) as [Hour],
	left(right(format(START_TIME,'yyyy-MM-dd HH:mm:ss'),5),2) as [minute],
	store_code,
	Traffic
FROM [DWD].[Fact_Store_Traffic_Detail]
WHERE FORMAT(START_TIME,'yyyy-MM-dd')>=FORMAT(DATEADD(Day,-11,cast(@dt AS DATE)), 'yyyy-MM-dd')
)

INSERT INTO RPT.RPT_HRIS_Store_Traffic_By_30M

SELECT  
	store_code,
	[date]+' '+[Hour]+':00:00' AS start_time,
	[date]+' '+[Hour]+':30:00' AS end_time,
	sum(CASE 
			WHEN minute in ('00','10','20') THEN Traffic ELSE 0 
		END
		) AS store_traffic,
	current_timestamp as insert_timestamp
from traffic
group by 
	store_code,
	[date],
	[Hour]

UNION ALL

select
	store_code,
	[date]+' '+[Hour]+':30:00' AS start_time,
	dateadd(hh,1,[date]+' '+[Hour]+':00:00') AS end_time,
	sum(CASE 
			WHEN minute in ('30','40','50') THEN Traffic ELSE 0 
		END
		) AS store_traffic,
	current_timestamp as insert_timestamp
from traffic
group by 
	store_code,
	[date],
	[Hour]
END
GO
