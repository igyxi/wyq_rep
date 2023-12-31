/****** Object:  StoredProcedure [DW_OMS].[SP_DWS_PS_Order_20221027]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DWS_PS_Order_20221027] @dragon_start_time [varchar](13),@dragon_end_time [varchar](13),@tm_start_time [varchar](13),@tm_end_time [varchar](13),@tm_wei_start_time [varchar](13),@tm_wei_end_time [varchar](13),@tm_ptr_start_time [varchar](13),@tm_ptr_end_time [varchar](13),@tm_chaling_start_time [varchar](13),@tm_chaling_end_time [varchar](13),@jd_start_time [varchar](13),@jd_end_time [varchar](13),@tm_second_start_time [varchar](13),@tm_second_end_time [varchar](13),@tm_wei_second_start_time [varchar](13),@tm_wei_second_end_time [varchar](13),@tm_ptr_second_start_time [varchar](13),@tm_ptr_second_end_time [varchar](13),@tm_chaling_second_start_time [varchar](13),@tm_chaling_second_end_time [varchar](13),@jd_second_start_time [varchar](13),@jd_second_end_time [varchar](13),@dy_start_time [varchar](13),@dy_end_time [varchar](13) AS
BEGIN
	TRUNCATE TABLE [DW_OMS].[DWS_PS_Order]

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
		SELECT
			*,
			CASE WHEN [type] = 8 OR ( [type] != 8 AND payment_status = 1) THEN 1 ELSE 0 END AS is_placed_flag,
			CASE WHEN [type] <> 8 THEN payment_time ELSE order_time END AS place_time
		FROM [STG_OMS].[v_Sales_Order_rt]
		WHERE 
            (store_id = 'S001' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @dragon_start_time and @dragon_end_time))
            OR (store_id in ('TMALL001','TMALL002') and shop_id is null and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_start_time and @tm_end_time))
            OR (store_id = 'TMALL004' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_chaling_start_time and @tm_chaling_end_time))
            OR (store_id = 'TMALL005' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_ptr_start_time and @tm_ptr_end_time))
            OR (store_id = 'TMALL006' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_wei_start_time and @tm_wei_end_time))
            OR (channel_id in ('JD','JD_FCS') and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @jd_start_time and @jd_end_time))
            OR (channel_id = 'DOUYIN' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @dy_start_time and @dy_end_time))
            OR (channel_id in ('JD','JD_FCS') and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @jd_second_start_time and @jd_second_end_time))
            OR (store_id in ('TMALL001','TMALL002') and shop_id is null and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_second_start_time and @tm_second_end_time))
            OR (store_id = 'TMALL004' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_chaling_second_start_time and @tm_chaling_second_end_time))
            OR (store_id = 'TMALL005' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_ptr_second_start_time and @tm_ptr_second_end_time))
            OR (store_id = 'TMALL006' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_wei_second_start_time and @tm_wei_second_end_time))
    ) S
    LEFT JOIN (
		SELECT *
		FROM [STG_OMS].[v_Purchase_Order_rt]
		WHERE
			(FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @dragon_start_time and store_id = 'S001')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_start_time and store_id in ('TMALL001','TMALL002') and shop_id is null )
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_chaling_start_time and store_id = 'TMALL004')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_ptr_start_time and store_id = 'TMALL005')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_wei_start_time and store_id = 'TMALL006')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @jd_start_time and channel_id in ('JD','JD_FCS'))
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @dy_start_time and channel_id = 'DOUYIN')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_second_start_time and store_id in ('TMALL001','TMALL002') and shop_id is null )
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_chaling_second_start_time and store_id = 'TMALL004')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_ptr_second_start_time and store_id = 'TMALL005')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_wei_second_start_time and store_id = 'TMALL006')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @jd_second_start_time and channel_id in ('JD','JD_FCS'))

    ) p ON p.sales_order_sys_id = s.sales_order_sys_id
    WHERE
        (p.basic_status != 'DELETED' or p.order_internal_status = 'PARTAIL_CANCEL')
        AND p.order_internal_status in ('SHIPPED', 'SIGNED','REJECTED','INTERCEPT','CANT_CONTACTED','CANCELLED','PARTAIL_CANCEL','WAIT_SAPPROCESS','EXCEPTION','PENDING','WAIT_SEND_SAP','WAIT_WAREHOUSE_PROCESS','WAIT_ROUTE_ORDER','SPLITED')
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
		SELECT
			*,
			CASE WHEN [type] = 8 OR ( [type] != 8 AND payment_status = 1) THEN 1 ELSE 0 END AS is_placed_flag,
			CASE WHEN [type] <> 8 THEN payment_time ELSE order_time END AS place_time
		FROM [STG_OMS].[v_Sales_Order_rt]
		WHERE
			(store_id = 'S001' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @dragon_start_time and @dragon_end_time))
			OR (store_id in ('TMALL001','TMALL002') and shop_id is null and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_start_time and @tm_end_time))
			OR (store_id = 'TMALL004' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_chaling_start_time and @tm_chaling_end_time))
			OR (store_id = 'TMALL005' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_ptr_start_time and @tm_ptr_end_time))
			OR (store_id = 'TMALL006' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_wei_start_time and @tm_wei_end_time))
			OR (channel_id in ('JD','JD_FCS') and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @jd_start_time and @jd_end_time))
			OR (channel_id = 'DOUYIN' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @dy_start_time and @dy_end_time))
			OR (store_id in ('TMALL001','TMALL002') and shop_id is null and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_second_start_time and @tm_second_end_time))
			OR (store_id = 'TMALL004' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_chaling_second_start_time and @tm_chaling_second_end_time))
			OR (store_id = 'TMALL005' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_ptr_second_start_time and @tm_ptr_second_end_time))
			OR (store_id = 'TMALL006' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_wei_second_start_time and @tm_wei_second_end_time))
			OR (channel_id in ('JD','JD_FCS') and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @jd_second_start_time and @jd_second_end_time))
    )s
    LEFT JOIN (
		SELECT *
		FROM [STG_OMS].[v_Purchase_Order_rt]
		WHERE
			(FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @dragon_start_time and store_id = 'S001')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_start_time and store_id in ('TMALL001','TMALL002') and shop_id is null )
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_chaling_start_time and store_id = 'TMALL004')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_ptr_start_time and store_id = 'TMALL005')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @tm_wei_start_time and store_id = 'TMALL006')
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @jd_start_time and channel_id in ('JD','JD_FCS'))
			OR (FORMAT(sys_create_time,'yyyy-MM-dd HH')>= @dy_start_time and channel_id = 'DOUYIN')
    ) p ON p.sales_order_sys_id = s.sales_order_sys_id
	WHERE 1 = 1
		AND p.store_id != 'GWP001'
		AND s.basic_status != 'DELETED'
		AND is_placed_flag = 1
		AND s.order_internal_status in ('EXCEPTION', 'WAIT_JD_CONFIRM', 'PENDING','WAIT_TMALLPROCESS')
		AND p.sales_order_sys_id is null;
		-- and cast(place_time as date) >= '2021-09-02'

END;
GO
