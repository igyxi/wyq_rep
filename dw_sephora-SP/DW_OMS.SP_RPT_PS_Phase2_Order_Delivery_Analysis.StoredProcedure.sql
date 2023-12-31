/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_PS_Phase2_Order_Delivery_Analysis]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_PS_Phase2_Order_Delivery_Analysis] AS
BEGIN

	TRUNCATE TABLE DW_OMS.RPT_PS_Phase2_Order_Delivery_Analysis;

	DECLARE @start_date DATE

    SELECT
        @start_date=MIN(DATEADD(D,-1,StartDate))
    FROM DATA_OPS.DIM_PrivateSales_Config_Phase2
    WHERE [Status]=1

	;WITH [basic] AS (
		SELECT
			a.store,
			a.sales_order_number,
			a.purchase_order_number,
			a.payment_time,
			CASE
				WHEN b.sales_order_number IS NOT NULL AND a.order_internal_status IN ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') THEN b.create_time
				ELSE a.payment_date
			END AS payment_date,
			a.payed_amount,
			a.order_internal_status,
			a.[status],
			a.shipping_time,
			a.shipping_date
		FROM [DW_OMS].[DWS_PS_Phase2_Order] a
		LEFT JOIN (
			SELECT
				sales_order_number,
				MIN(create_time) AS create_time
			FROM STG_OMS.OMS_Partial_Cancel_Apply_Order
			GROUP BY sales_order_number
		) b ON a.sales_order_number = b.sales_order_number

		UNION ALL
		SELECT
			s.store,
			s.sales_order_number,
			s.purchase_order_number,
			s.payment_time,
			s.payment_date,
			s.payed_amount,
			'RETURN' AS order_internal_status,
			'RETURN' AS [status],
			s.shipping_time,
			s.shipping_date
		FROM [DW_OMS].[DWS_PS_Phase2_Order] s
		INNER JOIN (
			SELECT
				sales_order_number,
				MIN(create_time) AS create_time
			FROM dw_oms.dws_online_return_apply_order
			GROUP BY sales_order_number
		)n ON s.sales_order_number = n.sales_order_number
	),ship_agg AS (
		SELECT
			store AS store,
			payment_date AS payment_date,
			DATEDIFF(D,@start_date,shipping_date)+1 AS id,
			SUM(CASE WHEN [status] = 'DELIVERY' THEN payed_amount ELSE 0 END) AS shipped_amount,
			COUNT(CASE WHEN [status] = 'DELIVERY' THEN 1 END) AS shipped_qty
		FROM [basic]
		GROUP BY store,payment_date,shipping_date
	),ship AS (
		SELECT
			store AS store,
			payment_date AS payment_date,
			SUM(CASE WHEN id=1 THEN shipped_amount END) AS fulfill1,
			SUM(CASE WHEN id=2 THEN shipped_amount END) AS fulfill2,
			SUM(CASE WHEN id=3 THEN shipped_amount END) AS fulfill3,
			SUM(CASE WHEN id=4 THEN shipped_amount END) AS fulfill4,
			SUM(CASE WHEN id=5 THEN shipped_amount END) AS fulfill5,
			SUM(CASE WHEN id=6 THEN shipped_amount END) AS fulfill6,
			SUM(CASE WHEN id=7 THEN shipped_amount END) AS fulfill7,
			SUM(CASE WHEN id=8 THEN shipped_amount END) AS fulfill8,
			SUM(CASE WHEN id=9 THEN shipped_amount END) AS fulfill9,
			SUM(CASE WHEN id=10 THEN shipped_amount END) AS fulfill10,
			SUM(CASE WHEN id=11 THEN shipped_amount END) AS fulfill11,
			SUM(CASE WHEN id=12 THEN shipped_amount END) AS fulfill12,
			SUM(CASE WHEN id=13 THEN shipped_amount END) AS fulfill13,
			SUM(CASE WHEN id=14 THEN shipped_amount END) AS fulfill14,
			SUM(CASE WHEN id=15 THEN shipped_amount END) AS fulfill15,
			SUM(CASE WHEN id=16 THEN shipped_amount END) AS fulfill16,
			SUM(CASE WHEN id=17 THEN shipped_amount END) AS fulfill17,
			SUM(CASE WHEN id=18 THEN shipped_amount END) AS fulfill18,
			SUM(CASE WHEN id=19 THEN shipped_amount END) AS fulfill19,
			SUM(CASE WHEN id=20 THEN shipped_amount END) AS fulfill20,
			SUM(CASE WHEN id=21 THEN shipped_amount END) AS fulfill21,
			SUM(CASE WHEN id=22 THEN shipped_amount END) AS fulfill22,
			SUM(CASE WHEN id=23 THEN shipped_amount END) AS fulfill23,
			SUM(CASE WHEN id=24 THEN shipped_amount END) AS fulfill24,
			SUM(CASE WHEN id=25 THEN shipped_amount END) AS fulfill25,
			SUM(CASE WHEN id=26 THEN shipped_amount END) AS fulfill26,
			SUM(CASE WHEN id=27 THEN shipped_amount END) AS fulfill27,
			SUM(CASE WHEN id=28 THEN shipped_amount END) AS fulfill28,
			SUM(CASE WHEN id=29 THEN shipped_amount END) AS fulfill29,
			SUM(CASE WHEN id=30 THEN shipped_amount END) AS fulfill30,
			SUM(CASE WHEN id=31 THEN shipped_amount END) AS fulfill31,
			SUM(CASE WHEN id=32 THEN shipped_amount END) AS fulfill32,
			SUM(CASE WHEN id=33 THEN shipped_amount END) AS fulfill33,
			SUM(CASE WHEN id=34 THEN shipped_amount END) AS fulfill34,
			SUM(CASE WHEN id=35 THEN shipped_amount END) AS fulfill35,
			SUM(CASE WHEN id=36 THEN shipped_amount END) AS fulfill36,
			'amount' AS [type]
		FROM ship_agg
		GROUP BY store,payment_date
		UNION ALL
		SELECT
			store AS store,
			payment_date AS payment_date,
			SUM(CASE WHEN id=1 THEN shipped_qty END) AS fulfill1,
			SUM(CASE WHEN id=2 THEN shipped_qty END) AS fulfill2,
			SUM(CASE WHEN id=3 THEN shipped_qty END) AS fulfill3,
			SUM(CASE WHEN id=4 THEN shipped_qty END) AS fulfill4,
			SUM(CASE WHEN id=5 THEN shipped_qty END) AS fulfill5,
			SUM(CASE WHEN id=6 THEN shipped_qty END) AS fulfill6,
			SUM(CASE WHEN id=7 THEN shipped_qty END) AS fulfill7,
			SUM(CASE WHEN id=8 THEN shipped_qty END) AS fulfill8,
			SUM(CASE WHEN id=9 THEN shipped_qty END) AS fulfill9,
			SUM(CASE WHEN id=10 THEN shipped_qty END) AS fulfill10,
			SUM(CASE WHEN id=11 THEN shipped_qty END) AS fulfill11,
			SUM(CASE WHEN id=12 THEN shipped_qty END) AS fulfill12,
			SUM(CASE WHEN id=13 THEN shipped_qty END) AS fulfill13,
			SUM(CASE WHEN id=14 THEN shipped_qty END) AS fulfill14,
			SUM(CASE WHEN id=15 THEN shipped_qty END) AS fulfill15,
			SUM(CASE WHEN id=16 THEN shipped_qty END) AS fulfill16,
			SUM(CASE WHEN id=17 THEN shipped_qty END) AS fulfill17,
			SUM(CASE WHEN id=18 THEN shipped_qty END) AS fulfill18,
			SUM(CASE WHEN id=19 THEN shipped_qty END) AS fulfill19,
			SUM(CASE WHEN id=20 THEN shipped_qty END) AS fulfill20,
			SUM(CASE WHEN id=21 THEN shipped_qty END) AS fulfill21,
			SUM(CASE WHEN id=22 THEN shipped_qty END) AS fulfill22,
			SUM(CASE WHEN id=23 THEN shipped_qty END) AS fulfill23,
			SUM(CASE WHEN id=24 THEN shipped_qty END) AS fulfill24,
			SUM(CASE WHEN id=25 THEN shipped_qty END) AS fulfill25,
			SUM(CASE WHEN id=26 THEN shipped_qty END) AS fulfill26,
			SUM(CASE WHEN id=27 THEN shipped_qty END) AS fulfill27,
			SUM(CASE WHEN id=28 THEN shipped_qty END) AS fulfill28,
			SUM(CASE WHEN id=29 THEN shipped_qty END) AS fulfill29,
			SUM(CASE WHEN id=30 THEN shipped_qty END) AS fulfill30,
			SUM(CASE WHEN id=31 THEN shipped_qty END) AS fulfill31,
			SUM(CASE WHEN id=32 THEN shipped_qty END) AS fulfill32,
			SUM(CASE WHEN id=33 THEN shipped_qty END) AS fulfill33,
			SUM(CASE WHEN id=34 THEN shipped_qty END) AS fulfill34,
			SUM(CASE WHEN id=35 THEN shipped_qty END) AS fulfill35,
			SUM(CASE WHEN id=36 THEN shipped_qty END) AS fulfill36,
			'qty' AS [type]
		FROM ship_agg
		GROUP BY store,payment_date

		--SELECT
		--	store,
		--	payment_date,
		--	[1] AS fulfill1,[2] AS fulfill2,[3] AS fulfill3,[4] AS fulfill4,[5] AS fulfill5,[6] AS fulfill6,[7] AS fulfill7,[8] AS fulfill8,[9] AS fulfill9,
		--	[10] AS fulfill10,[11] AS fulfill11,[12] AS fulfill12,[13] AS fulfill13,[14] AS fulfill14,[15] AS fulfill15,[16] AS fulfill16,[17] AS fulfill17,[18] AS fulfill18,
		--	[19] AS fulfill19,[20] AS fulfill20,[21] AS fulfill21,[22] AS fulfill22,[23] AS fulfill23,[24] AS fulfill24,[25] AS fulfill25,[26] AS fulfill26,[27] AS fulfill27,
		--	[28] AS fulfill28,[29] AS fulfill29,[30] AS fulfill30,[31] AS fulfill31,[32] AS fulfill32,[33] AS fulfill33,[34] AS fulfill34,[35] AS fulfill35,[36] AS fulfill36,
		--	'amount' AS [type]
		--FROM (
		--	SELECT
		--		a.store AS store,
		--		a.payment_date AS payment_date,
		--		b.id,
		--		SUM(CASE WHEN a.[status] = 'DELIVERY' AND shipping_date = b.dt THEN a.payed_amount ELSE 0 END) AS shipped
		--	FROM [basic] a
		--	JOIN (
		--		SELECT
		--			dt,
		--			ROW_NUMBER() OVER(ORDER BY dt) id
		--		FROM DW_Common.DIM_Date
		--		WHERE dt BETWEEN @start_date AND DATEADD(dd, 35, @start_date)
		--	) b ON a.payment_date <= b.dt
		--	GROUP BY a.payment_date, b.id, a.store
		--) t
		--PIVOT
		--(
		--	MAX(shipped) FOR id IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36])
		--) pvt

		--UNION ALL
		--SELECT
		--	store,
		--	payment_date,
		--	[1] AS fulfill1,[2] AS fulfill2,[3] AS fulfill3,[4] AS fulfill4,[5] AS fulfill5,[6] AS fulfill6,[7] AS fulfill7,[8] AS fulfill8,[9] AS fulfill9,
		--	[10] AS fulfill10,[11] AS fulfill11,[12] AS fulfill12,[13] AS fulfill13,[14] AS fulfill14,[15] AS fulfill15,[16] AS fulfill16,[17] AS fulfill17,[18] AS fulfill18,
		--	[19] AS fulfill19,[20] AS fulfill20,[21] AS fulfill21,[22] AS fulfill22,[23] AS fulfill23,[24] AS fulfill24,[25] AS fulfill25,[26] AS fulfill26,[27] AS fulfill27,
		--	[28] AS fulfill28,[29] AS fulfill29,[30] AS fulfill30,[31] AS fulfill31,[32] AS fulfill32,[33] AS fulfill33,[34] AS fulfill34,[35] AS fulfill35,[36] AS fulfill36,
		--	'qty' AS [type]
		--FROM (
		--	SELECT
		--		a.store AS store,
		--		a.payment_date AS payment_date,
		--		b.id,
		--		SUM(CASE WHEN a.[status] = 'DELIVERY' AND shipping_date = b.dt THEN 1 ELSE 0 END) AS shipped
		--	FROM [basic] a
		--	JOIN (
		--		SELECT
		--			dt,
		--			ROW_NUMBER() OVER(ORDER BY dt) AS id
		--		FROM DW_Common.DIM_Date
		--		WHERE dt BETWEEN @start_date AND DATEADD(dd, 35, @start_date)
		--	) b ON a.payment_date <= b.dt
		--	GROUP BY a.payment_date, b.id, a.store
		--) t
		--PIVOT
		--(
		--	MAX(shipped) FOR id IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36])
		--) pvt
	),
	original AS (
		SELECT
			a.payment_date AS payment_date,
			a.store AS store,
			SUM(CASE WHEN a.[status] IN ('DELIVERY','CANCEL','WAITING') THEN a.payed_amount ELSE 0 END) AS original,
			SUM(CASE WHEN a.[status] = 'DELIVERY' THEN a.payed_amount ELSE 0 END) AS shipped,
			SUM(CASE WHEN a.[status] = 'CANCEL' THEN a.payed_amount ELSE 0 END) AS cancelled,
			SUM(CASE WHEN a.[status] = 'WAITING' THEN a.payed_amount ELSE 0 END) AS pending,
			SUM(CASE WHEN a.[status] = 'RETURN' THEN a.payed_amount ELSE 0 END) AS returned,
			'amount' AS [type]
		FROM [basic] a
		GROUP BY a.store,a.payment_date
		UNION ALL
		SELECT
			a.payment_date AS payment_date,
			a.store AS store,
			SUM(CASE WHEN a.[status] IN ('DELIVERY','CANCEL','WAITING') THEN 1 ELSE 0 END) AS original,
			SUM(CASE WHEN a.[status] = 'DELIVERY' THEN 1 ELSE 0 END) AS shipped,
			SUM(CASE WHEN a.[status] = 'CANCEL' THEN 1 ELSE 0 END) AS cancelled,
			SUM(CASE WHEN a.[status] = 'WAITING' THEN 1 ELSE 0 END) AS pending,
			SUM(CASE WHEN a.[status] = 'RETURN' THEN 1 ELSE 0 END) AS returned,
			'qty' AS [type]
		FROM [basic] a
		GROUP BY a.store,a.payment_date
	),
	delivery_detail AS (
		SELECT
			CAST(a.payment_date AS VARCHAR(10)) AS payment_date,
			a.store,
			a.[type],
			a.original,
			a.shipped,
			a.cancelled,
			a.pending,
			a.returned,
			b.fulfill1,b.fulfill2,b.fulfill3,b.fulfill4,b.fulfill5,b.fulfill6,b.fulfill7,b.fulfill8,b.fulfill9,
			b.fulfill10,b.fulfill11,b.fulfill12,b.fulfill13,b.fulfill14,b.fulfill15,b.fulfill16,b.fulfill17,b.fulfill18,
			b.fulfill19,b.fulfill20,b.fulfill21,b.fulfill22,b.fulfill23,b.fulfill24,b.fulfill25,b.fulfill26,b.fulfill27,
			b.fulfill28,b.fulfill29,b.fulfill30,b.fulfill31,b.fulfill32,b.fulfill33,b.fulfill34,b.fulfill35,b.fulfill36
		FROM original a
		LEFT JOIN ship b ON a.payment_date=b.payment_date AND a.store=b.store AND a.[type]=b.[type]
	)
	INSERT INTO DW_OMS.RPT_PS_Phase2_Order_Delivery_Analysis
	SELECT
		payment_date,
		store,
		[type],
		original,
		shipped,
		cancelled,
		pending,
		returned,
		fulfill1,
		fulfill2,
		fulfill3,
		fulfill4,
		fulfill5,
		fulfill6,
		fulfill7,
		fulfill8,
		fulfill9,
		fulfill10,
		fulfill11,
		fulfill12,
		fulfill13,
		fulfill14,
		fulfill15,
		fulfill16,
		fulfill17,
		fulfill18,
		fulfill19,
		fulfill20,
		fulfill21,
		fulfill22,
		fulfill23,
		fulfill24,
		fulfill25,
		fulfill26,
		fulfill27,
		fulfill28,
		fulfill29,
		fulfill30,
		fulfill31,
		fulfill32,
		fulfill33,
		fulfill34,
		fulfill35,
		fulfill36,
		rate,
		insert_timestamp
	FROM (
		SELECT
			*,
			CONCAT(SUBSTRING(CAST(ROUND((ISNULL(shipped,0.0001)*100.0 + 0.0001 )/(ISNULL(original,0.0001) + 0.0001),2) AS VARCHAR(512)),1,5),'%') AS rate,
			CURRENT_TIMESTAMP AS insert_timestamp
		FROM delivery_detail
		UNION ALL
		SELECT
			N'total' AS payment_date,
			store,
			[type],
			SUM(ISNULL(original,0)) AS original,
			SUM(ISNULL(shipped,0)) AS shipped,
			SUM(ISNULL(cancelled,0)) AS cancelled,
			SUM(ISNULL(pending,0)) AS pending,
			SUM(ISNULL(returned,0)) AS returned,
			SUM(ISNULL(fulfill1,0)) AS fulfill1,
			SUM(ISNULL(fulfill2,0)) AS fulfill2,
			SUM(ISNULL(fulfill3,0)) AS fulfill3,
			SUM(ISNULL(fulfill4,0)) AS fulfill4,
			SUM(ISNULL(fulfill5,0)) AS fulfill5,
			SUM(ISNULL(fulfill6,0)) AS fulfill6,
			SUM(ISNULL(fulfill7,0)) AS fulfill7,
			SUM(ISNULL(fulfill8,0)) AS fulfill8,
			SUM(ISNULL(fulfill9,0)) AS fulfill9,
			SUM(ISNULL(fulfill10,0)) AS fulfill10,
			SUM(ISNULL(fulfill11,0)) AS fulfill11,
			SUM(ISNULL(fulfill12,0)) AS fulfill12,
			SUM(ISNULL(fulfill13,0)) AS fulfill13,
			SUM(ISNULL(fulfill14,0)) AS fulfill14,
			SUM(ISNULL(fulfill15,0)) AS fulfill15,
			SUM(ISNULL(fulfill16,0)) AS fulfill16,
			SUM(ISNULL(fulfill17,0)) AS fulfill17,
			SUM(ISNULL(fulfill18,0)) AS fulfill18,
			SUM(ISNULL(fulfill19,0)) AS fulfill19,
			SUM(ISNULL(fulfill20,0)) AS fulfill20,
			SUM(ISNULL(fulfill21,0)) AS fulfill21,
			SUM(ISNULL(fulfill22,0)) AS fulfill22,
			SUM(ISNULL(fulfill23,0)) AS fulfill23,
			SUM(ISNULL(fulfill24,0)) AS fulfill24,
			SUM(ISNULL(fulfill25,0)) AS fulfill25,
			SUM(ISNULL(fulfill26,0)) AS fulfill26,
			SUM(ISNULL(fulfill27,0)) AS fulfill27,
			SUM(ISNULL(fulfill28,0)) AS fulfill28,
			SUM(ISNULL(fulfill29,0)) AS fulfill29,
			SUM(ISNULL(fulfill30,0)) AS fulfill30,
			SUM(ISNULL(fulfill31,0)) AS fulfill31,
			SUM(ISNULL(fulfill32,0)) AS fulfill32,
			SUM(ISNULL(fulfill33,0)) AS fulfill33,
			SUM(ISNULL(fulfill34,0)) AS fulfill34,
			SUM(ISNULL(fulfill35,0)) AS fulfill35,
			SUM(ISNULL(fulfill36,0)) AS fulfill36,
			CONCAT(SUBSTRING(CAST(ROUND((SUM(ISNULL(shipped,0.0001))*100.0 + 0.0001)/SUM(ISNULL(original,0.0001) + 0.0001),2) AS VARCHAR(512)),1,5),'%') AS rate,
			CURRENT_TIMESTAMP AS insert_timestamp
		FROM delivery_detail
		GROUP BY store,[type]
	)t

END
GO
