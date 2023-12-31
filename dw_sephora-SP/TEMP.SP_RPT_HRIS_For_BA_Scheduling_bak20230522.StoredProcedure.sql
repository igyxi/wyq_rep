/****** Object:  StoredProcedure [TEMP].[SP_RPT_HRIS_For_BA_Scheduling_bak20230522]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_HRIS_For_BA_Scheduling_bak20230522] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-17       weichen           Initial Version
-- ========================================================================================
DELETE FROM  RPT.RPT_HRIS_For_BA_Scheduling WHERE LEFT(time_period,10)>=FORMAT(DATEADD(Day,-13,cast(@dt AS DATE)), 'yyyy-MM-dd');

;WITH traffic AS(
	SELECT 
		store_code,
		start_time,
		end_time,
		store_traffic
	FROM RPT.RPT_HRIS_Store_Traffic_By_30M
	WHERE FORMAT(start_time,'yyyy-MM-dd')>= FORMAT(DATEADD(Day,-13,cast(@dt AS DATE)), 'yyyy-MM-dd')
),
sales_order AS (
	SELECT 
		a.store_code,
		t.start_time,
		t.end_time,
		COUNT(DISTINCT a.sales_order_number) AS trans_cnt
	FROM DWD.Fact_Sales_Order a 
	LEFT JOIN traffic t on a.store_code =t.store_code and a.place_time between  t.start_time and t.end_time
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
	LEFT JOIN traffic t on a.store_code =t.store_code and a.place_time between  t.start_time and t.end_time
	WHERE a.source = 'POS'
	and a.channel_code = 'OFF_LINE'
	AND a.refund_status = 'REFUNDED'
	group by 
		a.store_code,
		t.start_time,
		t.end_time
)

INSERT INTO RPT.RPT_HRIS_For_BA_Scheduling

SELECT 
	a.store_code,
	'POS' as trans_type,
	format(cast(b.start_time as datetime),'yyyy-MM-dd HH:mm:ss') +'-'+format(b.end_time,'HH:mm') AS time_period,
	isnull(c.trans_cnt,0) as trans_cnt,
	isnull(d.refund_cnt,0) as refund_cnt,
	isnull(b.store_traffic,0) as store_traffic,
	current_timestamp as insert_timestamp
FROM DWD.DIM_STORE a
left join traffic b on a.store_code=b.store_code 
left join sales_order  c on a.store_code=c.store_code and b.start_time=c.start_time and b.end_time=c.end_time
left join refund_order  d on a.store_code=d.store_code and b.start_time=d.start_time and b.end_time=d.end_time
WHERE a.sap_country_code='CN' AND a.source='SAP' and  b.start_time is not null
;
END


GO
