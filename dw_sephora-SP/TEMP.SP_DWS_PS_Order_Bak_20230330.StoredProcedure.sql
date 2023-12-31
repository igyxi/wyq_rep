/****** Object:  StoredProcedure [TEMP].[SP_DWS_PS_Order_Bak_20230330]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_PS_Order_Bak_20230330] AS
BEGIN

	TRUNCATE TABLE [DW_OMS].[DWS_PS_Order]

	;WITH DIM_PS_Config AS (
		SELECT
			Channel,
			StartDate,
			StartHour,
			FORMAT(StartDate,'yyyy-MM-dd')+' '+LTRIM(StartHour) AS StartTime,
			EndDate,
			EndHour,
			FORMAT(EndDate,'yyyy-MM-dd')+' '+LTRIM(EndHour) AS EndTime
		FROM DATA_OPS.DIM_PrivateSales_Config
		WHERE [Status]=1
	)
	INSERT INTO [DW_OMS].[DWS_PS_Order]
	SELECT
		CASE
			WHEN p.store_id = 'S001' THEN 'Dragon'
			-- When p.channel_id = 'TMALL' and p.shop_id = 'TM2' then 'TMALL_WEI'
			WHEN p.channel_id = 'TMALL' AND p.store_id = 'TMALL004' THEN 'TMALL_CHALING' 
			WHEN p.channel_id = 'TMALL' AND p.store_id = 'TMALL005' THEN 'TMALL_PTR'
			WHEN p.channel_id = 'TMALL' AND p.store_id = 'TMALL006' THEN 'TMALL_WEI'
			WHEN p.store_id IN ('JD001','JD002') THEN 'JD_FSS'
			WHEN p.store_id = 'JD003' THEN 'JD_FCS'
			ELSE p.channel_id
		END AS store,
		p.sales_order_number,
		p.purchase_order_number,
		s.place_time AS payment_time,
		CAST(s.place_time AS DATE) AS payment_date,
		p.payed_amount,
		p.order_internal_status,
		CASE p.order_internal_status
			WHEN 'SHIPPED' THEN 'DELIVERY'
			WHEN 'SIGNED' THEN 'DELIVERY'
			WHEN 'REJECTED' THEN 'DELIVERY'
			WHEN 'INTERCEPT' THEN 'DELIVERY'
			WHEN 'CANT_CONTACTED' THEN 'DELIVERY'
			WHEN 'CANCELLED' THEN 'CANCEL'
			WHEN 'PARTAIL_CANCEL' THEN 'CANCEL'
			WHEN 'WAIT_SAPPROCESS' THEN 'WAITING'
			WHEN 'EXCEPTION' THEN 'WAITING'
			WHEN 'PENDING' THEN 'WAITING'
			WHEN 'WAIT_JD_CONFIRM' THEN 'WAITING'
			WHEN 'WAIT_JDPROCESS' THEN 'WAITING'
			WHEN 'WAIT_SEND_SAP' THEN 'WAITING'
			WHEN 'WAIT_TMALLPROCESS' THEN 'WAITING'
			WHEN 'WAIT_WAREHOUSE_PROCESS' THEN 'WAITING'
			WHEN 'SPLITED' THEN 'WAITING'
			WHEN 'WAIT_ROUTE_ORDER' THEN 'WAITING'
			ELSE 'OTHER'
		END AS [status],
		p.shipping_time AS shipping_time,
		CAST(p.shipping_time AS DATE) AS shipping_date,
		CURRENT_TIMESTAMP AS insert_timestamp
	FROM (
		SELECT s1.*
		FROM (
			SELECT
				*,
				CASE WHEN [type] = 8 OR ( [type] != 8 AND payment_status = 1) THEN 1 ELSE 0 END AS is_placed_flag,
				CASE WHEN [type] <> 8 THEN payment_time ELSE order_time END AS place_time,
				CASE
					WHEN store_id = 'S001' THEN 'Dragon'
					WHEN store_id IN ('TMALL001','TMALL002') AND shop_id IS NULL THEN 'TMALL_Sephora'
					WHEN store_id = 'TMALL004' THEN 'TMALL_CHALING'
					WHEN store_id = 'TMALL005' THEN 'TMALL_PTR'
					WHEN store_id = 'TMALL006' THEN 'TMALL_WEI'
					WHEN channel_id IN ('JD','JD_FCS') THEN 'JD'
					WHEN channel_id = 'DOUYIN' THEN 'DOUYIN'
				END AS PS_Channel
			FROM [STG_OMS].[v_Sales_Order_rt]
		) AS s1
		WHERE EXISTS (SELECT 1 FROM DIM_PS_Config AS dpc WHERE s1.PS_Channel=dpc.Channel AND FORMAT(place_time,'yyyy-MM-dd HH') BETWEEN dpc.StartTime AND dpc.EndTime)
    ) S
    LEFT JOIN (
		SELECT p1.*
		FROM (
			SELECT
				*,
				CASE
					WHEN store_id = 'S001' THEN 'Dragon'
					WHEN store_id IN ('TMALL001','TMALL002') AND shop_id IS NULL THEN 'TMALL_Sephora'
					WHEN store_id = 'TMALL004' THEN 'TMALL_CHALING'
					WHEN store_id = 'TMALL005' THEN 'TMALL_PTR'
					WHEN store_id = 'TMALL006' THEN 'TMALL_WEI'
					WHEN channel_id IN ('JD','JD_FCS') THEN 'JD'
					WHEN channel_id = 'DOUYIN' THEN 'DOUYIN'
				END AS PS_Channel
			FROM [STG_OMS].[v_Purchase_Order_rt]
		) AS p1
		WHERE EXISTS (
			SELECT 1 FROM DIM_PS_Config AS dpc WHERE p1.PS_Channel=dpc.Channel AND FORMAT(sys_create_time,'yyyy-MM-dd HH') >= dpc.StartTime
		)
    ) p ON p.sales_order_sys_id = s.sales_order_sys_id
    WHERE
        (p.basic_status != 'DELETED' OR p.order_internal_status = 'PARTAIL_CANCEL')
        AND p.order_internal_status IN ('SHIPPED', 'SIGNED','REJECTED','INTERCEPT','CANT_CONTACTED','CANCELLED','PARTAIL_CANCEL','WAIT_SAPPROCESS','EXCEPTION','PENDING','WAIT_SEND_SAP','WAIT_WAREHOUSE_PROCESS','WAIT_ROUTE_ORDER','SPLITED')
        AND p.store_id != 'GWP001'
        AND p.[type] != 2
        AND p.split_type != 'SPLIT_ORIGIN'
        AND s.is_placed_flag = 1
		-- adhoc added for 202110 PS
		-- and cast(case when s.type != 8 then s.payment_time else s.order_time end as date) >= '2021-09-02'

	UNION ALL
	SELECT
		CASE 
			WHEN s.store_id = 'S001' THEN 'Dragon'
			WHEN s.channel_id = 'TMALL' AND s.store_id = 'TMALL006' THEN 'TMALL_WEI'
			WHEN s.channel_id = 'TMALL' AND s.store_id = 'TMALL004' THEN 'TMALL_CHALING' 
			WHEN s.channel_id = 'TMALL' AND s.store_id = 'TMALL005' THEN 'TMALL_PTR'
			WHEN p.store_id in ('JD001','JD002') THEN 'JD_FSS'
			WHEN p.store_id = 'JD003' THEN 'JD_FCS'
			ELSE s.channel_id 
		END AS store,
		s.sales_order_number,
		NULL AS purchase_order_number,
		s.place_time AS payment_time,
		CAST(s.place_time AS DATE) AS payment_date,
		s.payed_amount,
		s.order_internal_status,
		CASE s.order_internal_status
			WHEN 'SHIPPED' THEN 'DELIVERY'
			WHEN 'SIGNED' THEN 'DELIVERY'
			WHEN 'REJECTED' THEN 'DELIVERY'
			WHEN 'INTERCEPT' THEN 'DELIVERY'
			WHEN 'CANT_CONTACTED' THEN 'DELIVERY'
			WHEN 'CANCELLED' THEN 'CANCEL'
			WHEN 'PARTAIL_CANCEL' THEN 'CANCEL'
			WHEN 'WAIT_SAPPROCESS' THEN 'WAITING'
			WHEN 'EXCEPTION' THEN 'WAITING'
			WHEN 'PENDING' THEN 'WAITING'
			WHEN 'WAIT_JD_CONFIRM' THEN 'WAITING'
			WHEN 'WAIT_JDPROCESS' THEN 'WAITING'
			WHEN 'WAIT_SEND_SAP' THEN 'WAITING'
			WHEN 'WAIT_TMALLPROCESS' THEN 'WAITING'
			WHEN 'WAIT_WAREHOUSE_PROCESS' THEN 'WAITING'
			WHEN 'SPLITED' THEN 'WAITING'
			WHEN 'WAIT_ROUTE_ORDER' THEN 'WAITING'
			ELSE 'OTHER' 
		END AS [status],
		NULL AS shipping_time,
		NULL AS shipping_date,
		CURRENT_TIMESTAMP AS insert_timestamp
	FROM (
		SELECT s1.*
		FROM (
			SELECT
				*,
				CASE WHEN [type] = 8 OR ( [type] != 8 AND payment_status = 1) THEN 1 ELSE 0 END AS is_placed_flag,
				CASE WHEN [type] <> 8 THEN payment_time ELSE order_time END AS place_time,
				CASE
					WHEN store_id = 'S001' THEN 'Dragon'
					WHEN store_id IN ('TMALL001','TMALL002') AND shop_id IS NULL THEN 'TMALL_Sephora'
					WHEN store_id = 'TMALL004' THEN 'TMALL_CHALING'
					WHEN store_id = 'TMALL005' THEN 'TMALL_PTR'
					WHEN store_id = 'TMALL006' THEN 'TMALL_WEI'
					WHEN channel_id IN ('JD','JD_FCS') THEN 'JD'
					WHEN channel_id = 'DOUYIN' THEN 'DOUYIN'
				END AS PS_Channel
			FROM [STG_OMS].[v_Sales_Order_rt]
		) AS s1
		WHERE EXISTS (SELECT 1 FROM DIM_PS_Config AS dpc WHERE s1.PS_Channel=dpc.Channel AND FORMAT(place_time,'yyyy-MM-dd HH') BETWEEN dpc.StartTime AND dpc.EndTime)
	)s
    LEFT JOIN (
		SELECT p1.*
		FROM (
			SELECT
				*,
				CASE
					WHEN store_id = 'S001' THEN 'Dragon'
					WHEN store_id IN ('TMALL001','TMALL002') AND shop_id IS NULL THEN 'TMALL_Sephora'
					WHEN store_id = 'TMALL004' THEN 'TMALL_CHALING'
					WHEN store_id = 'TMALL005' THEN 'TMALL_PTR'
					WHEN store_id = 'TMALL006' THEN 'TMALL_WEI'
					WHEN channel_id IN ('JD','JD_FCS') THEN 'JD'
					WHEN channel_id = 'DOUYIN' THEN 'DOUYIN'
				END AS PS_Channel
			FROM [STG_OMS].[v_Purchase_Order_rt]
		) AS p1
		WHERE EXISTS (
			SELECT 1 FROM DIM_PS_Config AS dpc WHERE p1.PS_Channel=dpc.Channel AND FORMAT(sys_create_time,'yyyy-MM-dd HH') >= dpc.StartTime
		)
    ) p ON p.sales_order_sys_id = s.sales_order_sys_id
	WHERE 1 = 1
		AND p.store_id != 'GWP001'
		AND s.basic_status != 'DELETED'
		AND is_placed_flag = 1
		AND s.order_internal_status IN ('EXCEPTION', 'WAIT_JD_CONFIRM', 'PENDING','WAIT_TMALLPROCESS')
		AND p.sales_order_sys_id IS NULL;

END
GO
