/****** Object:  StoredProcedure [RPT].[SP_RPT_HRIS_For_BA_Scheduling_INI]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_HRIS_For_BA_Scheduling_INI] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-17       weichen           Initial Version
-- ========================================================================================
TRUNCATE TABLE  RPT.RPT_HRIS_For_BA_Scheduling_NEW 

;with temp as(
select 1 as t
union select 2
union select 3
union select 4
union select 5
union select 6
),
num as(
select 
	row_number() over(order by c.t) as r 
from temp a ,temp b, temp c,temp D
),
hourly as(
select 
	dateadd(hour,r-1,dateadd(minute,0,format(getdate(),'yyyy-MM-dd'))) as starttime,
	dateadd(hour,r-1,dateadd(minute,30,format(getdate(),'yyyy-MM-dd'))) as endtime
from num
where r<=24
union 
select 
	dateadd(hour,r-1,dateadd(minute,30,format(getdate(),'yyyy-MM-dd'))) as starttime,
	dateadd(hour,r-1,dateadd(minute,60,format(getdate(),'yyyy-MM-dd'))) as endtime
from num
where r<=24
),
dim_store AS(
select  
	a.store_code,
	d.start_time,
	d.end_time
from DWD.DIM_STORE a
cross join(
	select 
		h.starttime-d.r as start_time,
		h.endtime-d.r as end_time
	from num as d ,hourly as h
)d
where 
	a.sap_country_code='CN' 
	AND a.source='SAP'
	and d.start_time>='2021-01-01'
),
sales_order AS (
	SELECT 
		a.store_code,
		t.start_time,
		t.end_time,
		COUNT(DISTINCT a.sales_order_number) AS trans_cnt
	FROM DWD.Fact_Sales_Order a 
	LEFT JOIN dim_store t on a.store_code =t.store_code and a.place_time between t.start_time and t.end_time
	WHERE a.source = 'POS'
	and a.channel_code = 'OFF_LINE'
	group by 
		a.store_code,
		t.start_time,
		t.end_time
),
refund_order AS(
	SELECT
		a.store_code,
		t.start_time,
		t.end_time,
		COUNT(DISTINCT a.refund_number) AS refund_cnt
	FROM DWD.Fact_Refund_Order a
	LEFT JOIN dim_store t on a.store_code =t.store_code and a.place_time between t.start_time and t.end_time
	WHERE a.source = 'POS'
	and a.channel_code = 'OFF_LINE'
	AND a.refund_status = 'REFUNDED'
	group by 
		a.store_code,
		t.start_time,
		t.end_time
)

INSERT INTO RPT.RPT_HRIS_For_BA_Scheduling_NEW

SELECT 
	a.store_code,
	'POS' as trans_type,
	format(cast(a.start_time as datetime),'yyyy-MM-dd HH:mm:ss') +'-'+format(a.end_time,'HH:mm') AS time_period,
	isnull(c.trans_cnt,0) as trans_cnt,
	isnull(d.refund_cnt,0) as refund_cnt,
	isnull(b.store_traffic,0) as store_traffic,
	current_timestamp as insert_timestamp
FROM dim_store a
left join RPT.RPT_HRIS_Store_Traffic_By_30M b on a.store_code=b.store_code and a.start_time=b.start_time and a.end_time=b.end_time
left join sales_order  c on a.store_code=c.store_code and a.start_time=c.start_time and a.end_time=c.end_time
left join refund_order  d on a.store_code=d.store_code and a.start_time=d.start_time and a.end_time=d.end_time
;
END
GO
