/****** Object:  StoredProcedure [TEMP].[SP_RPT_PS_Order_Status_Analysis_Bak_20230323]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_PS_Order_Status_Analysis_Bak_20230323] AS
BEGIN
    TRUNCATE TABLE [DW_OMS].[RPT_PS_Order_Status_Analysis]

    ;WITH [basic] AS (
        SELECT
            a.store,
            a.sales_order_number,
            a.purchase_order_number,
            a.payment_time,
            CASE
                WHEN b.sales_order_number IS NOT NULL AND a.order_internal_status IN ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') THEN b.create_time
                ELSE a.payment_date
            END AS Payment_date,
            a.payed_amount,
            a.order_internal_status,
            a.[status],
            a.shipping_time,
            a.shipping_date
        FROM [DW_OMS].[DWS_PS_Order] a
        LEFT JOIN (
            SELECT
                sales_order_number,
                MIN(create_time) AS create_time
            FROM STG_OMS.OMS_Partial_Cancel_Apply_Order
            GROUP BY sales_order_number
        ) b ON a.sales_order_number = b.sales_order_number
        --WHERE a.store IN ('Dragon','DOUYIN') 
        UNION ALL
        SELECT
            s.store,
            s.sales_order_number,
            s.purchase_order_number,
            n.create_time AS payment_time,
            CAST(n.create_time AS DATE) AS payment_date,
            s.payed_amount,
            'RETURN' AS order_internal_status,
            'RETURN' AS [status],
            s.shipping_time,
            s.shipping_date
        FROM [DW_OMS].[DWS_PS_Order] s
        INNER JOIN (
            -- 于2021-12-13修改逻辑
            -- (
            --     select distinct
            --         sales_order_number
            --     from DW_OMS.DWS_Negative_Order
            --     where negative_type in (N'线上退货退款',N'退货退款',N'拒收',N'联系不到客户')
            -- ) n
            SELECT
                sales_order_number,
                MIN(create_time) AS create_time
            FROM dw_oms.dws_online_return_apply_order 
            GROUP BY sales_order_number
        )n ON s.sales_order_number = n.sales_order_number
        --WHERE s.store IN ('Dragon','DOUYIN')
    )
    INSERT INTO [DW_OMS].[RPT_PS_Order_Status_Analysis]
    SELECT
        d.status_comment,
        t.dragon_qty,
        t.dargon_amount, 
        (CASE WHEN t0.dargon_amount IS NULL OR t0.dargon_amount=0 THEN NULL ELSE t.dargon_amount/t0.dargon_amount END) AS dragon_rate,
        t.jd_fcs_qty,
        t.jd_fcs_amount,
        (CASE WHEN t0.jd_fcs_amount IS NULL OR t0.jd_fcs_amount=0 THEN NULL ELSE t.jd_fcs_amount/t0.jd_fcs_amount END) AS jd_fcs_rate, 
        t.jd_fss_qty,
        t.jd_fss_amount,
        (CASE WHEN t0.jd_fss_amount IS NULL OR t0.jd_fss_amount=0 THEN NULL ELSE t.jd_fss_amount/t0.jd_fss_amount END) AS jd_fss_rate, 
        t.tmall_qty,
        t.tmall_amount,
        (CASE WHEN t0.tmall_amount IS NULL OR t0.tmall_amount=0 THEN NULL ELSE t.tmall_amount/t0.tmall_amount END) AS tmall_rate,
        t.tmall_wei_qty,
        t.tmall_wei_amount,
        (CASE WHEN t0.tmall_wei_amount IS NULL OR t0.tmall_wei_amount=0 THEN NULL ELSE t.tmall_wei_amount/t0.tmall_wei_amount END) AS tmall_wei_rate, 
        t.tmall_chaling_qty,
        t.tmall_chaling_amount,
        (CASE WHEN t0.tmall_chaling_amount IS NULL OR t0.tmall_chaling_amount=0 THEN NULL ELSE t.tmall_chaling_amount/t0.tmall_chaling_amount END) AS tmall_chaling_rate, 
        t.tmall_ptr_qty,
        t.tmall_ptr_amount,
        (CASE WHEN t0.tmall_ptr_amount IS NULL OR t0.tmall_ptr_amount=0 THEN NULL ELSE t.tmall_ptr_amount/t0.tmall_ptr_amount END) AS tmall_ptr_rate, 
        t.redbook_qty,
        t.redbook_amount,
        (CASE WHEN t0.redbook_amount IS NULL OR t0.redbook_amount=0 THEN NULL ELSE t.redbook_amount/t0.redbook_amount END) AS redbook_rate, 
        t.douyin_qty,
        t.douyin_amount,
        (CASE WHEN t0.douyin_amount IS NULL OR t0.douyin_amount=0 THEN NULL ELSE t.douyin_amount/t0.douyin_amount END) AS douyin_rate, 
        t.qty,
        t.amount,
        (CASE WHEN t0.amount IS NULL OR t0.amount=0 THEN NULL ELSE t.amount/t0.amount END) AS rate,
        status_type,
        status_level,
        status_order
    FROM (
        SELECT
            order_internal_status,
            status_comment,
            status_type,
            status_level,
            status_order
        FROM DW_OMS.DIM_Order_Internal_Status
        WHERE order_internal_status <> 'RETURN'
    ) d
    LEFT JOIN (
        SELECT
            order_internal_status,
            COUNT(CASE WHEN store='Dragon' THEN 1 ELSE NULL END) AS dragon_qty,
            SUM(CASE WHEN store='Dragon' THEN payed_amount ELSE NULL END) AS dargon_amount,
            COUNT(CASE WHEN store='JD_FSS' THEN 1 ELSE NULL END) AS jd_fss_qty,
            SUM(CASE WHEN store='JD_FSS' THEN payed_amount ELSE NULL END) AS jd_fss_amount,
            COUNT(CASE WHEN store='JD_FCS' THEN 1 ELSE NULL END) AS jd_fcs_qty,
            SUM(CASE WHEN store='JD_FCS' THEN payed_amount ELSE NULL END) AS jd_fcs_amount,
            COUNT(CASE WHEN store='TMALL' THEN 1 ELSE NULL END) AS tmall_qty,
            SUM(CASE WHEN store='TMALL' THEN payed_amount ELSE NULL END) AS tmall_amount,
            COUNT(CASE WHEN store='TMALL_WEI' THEN 1 ELSE NULL END) AS tmall_wei_qty,
            SUM(CASE WHEN store='TMALL_WEI' THEN payed_amount ELSE NULL END) AS tmall_wei_amount,
            COUNT(CASE WHEN store='TMALL_CHALING' THEN 1 ELSE NULL END) AS tmall_chaling_qty,
            SUM(CASE WHEN store='TMALL_CHALING' THEN payed_amount ELSE NULL END) AS tmall_chaling_amount,
            COUNT(CASE WHEN store='TMALL_PTR' THEN 1 ELSE NULL END) AS tmall_ptr_qty,
            SUM(CASE WHEN store='TMALL_PTR' THEN payed_amount ELSE NULL END) AS tmall_ptr_amount,
            COUNT(CASE WHEN store='REDBOOK' THEN 1 ELSE NULL END) AS redbook_qty,
            SUM(CASE WHEN store='REDBOOK' THEN payed_amount ELSE NULL END) AS redbook_amount,
            COUNT(CASE WHEN store='DOUYIN' THEN 1 ELSE NULL END) AS douyin_qty,
            SUM(CASE WHEN store='DOUYIN' THEN payed_amount ELSE NULL END) AS douyin_amount,
            COUNT(1) AS qty,
            2 AS [level],
            SUM(payed_amount) AS amount
        FROM [basic]
        WHERE order_internal_status <> 'RETURN'
        GROUP BY order_internal_status

        UNION ALL
        SELECT
            CASE
                WHEN order_internal_status IN ('DELIVERY', 'SHIPPED', 'SIGNED', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') THEN 'SHIPPED'
                WHEN order_internal_status IN ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') THEN 'CANCELLED'
                WHEN order_internal_status IN ('WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') THEN 'PENDING'
                WHEN order_internal_status IN ('RETURN') THEN 'RETURN'
                ELSE 'OTHER'
            END AS Order_internal_status,
            COUNT(CASE WHEN store='Dragon' THEN 1 ELSE NULL END) AS dragon_qty,
            SUM(CASE WHEN store='Dragon' THEN payed_amount ELSE NULL END) AS dargon_amount,
            COUNT(CASE WHEN store='JD_FSS' THEN 1 ELSE NULL END) AS jd_fss_qty,
            SUM(CASE WHEN store='JD_FSS' THEN payed_amount ELSE NULL END) AS jd_fss_amount,
            COUNT(CASE WHEN store='JD_FCS' THEN 1 ELSE NULL END) AS jd_fcs_qty,
            SUM(CASE WHEN store='JD_FCS' THEN payed_amount ELSE NULL END) AS jd_fcs_amount,
            COUNT(CASE WHEN store='TMALL' THEN 1 ELSE NULL END) AS tmall_qty,
            SUM(CASE WHEN store='TMALL' THEN payed_amount ELSE NULL END) AS tmall_amount,
            COUNT(CASE WHEN store='TMALL_WEI' THEN 1 ELSE NULL END) AS tmall_wei_qty,
            SUM(CASE WHEN store='TMALL_WEI' THEN payed_amount ELSE NULL END) AS tmall_wei_amount,
            COUNT(CASE WHEN store='TMALL_CHALING' THEN 1 ELSE NULL END) AS tmall_chaling_qty,
            SUM(CASE WHEN store='TMALL_CHALING' THEN payed_amount ELSE NULL END) AS tmall_chaling_amount,
            COUNT(CASE WHEN store='TMALL_PTR' THEN 1 ELSE NULL END) AS tmall_ptr_qty,
            SUM(CASE WHEN store='TMALL_PTR' THEN payed_amount ELSE NULL END) AS tmall_ptr_amount,
            COUNT(CASE WHEN store='REDBOOK' THEN 1 ELSE NULL END) AS redbook_qty,
            SUM(CASE WHEN store='REDBOOK' THEN payed_amount ELSE NULL END) AS redbook_amount,
            COUNT(CASE WHEN store='DOUYIN' THEN 1 ELSE NULL END) AS douyin_qty,
            SUM(CASE WHEN store='DOUYIN' THEN payed_amount ELSE NULL END) AS douyin_amount,
            COUNT(1) AS qty,
            1 AS [level],
            SUM(payed_amount) AS amount
        FROM [basic]
        WHERE order_internal_status <> 'RETURN'
        GROUP BY
            CASE
                WHEN order_internal_status IN ('DELIVERY', 'SHIPPED', 'SIGNED', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') THEN 'SHIPPED'
                WHEN order_internal_status IN ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') THEN 'CANCELLED'
                WHEN order_internal_status IN ('WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') THEN 'PENDING'
                WHEN order_internal_status IN ('RETURN') THEN 'RETURN'
                ELSE 'OTHER'
            END
    ) t ON d.order_internal_status = t.order_internal_status AND t.level = d.status_level
    LEFT JOIN (
        SELECT
            SUM(CASE WHEN store='Dragon' THEN payed_amount ELSE NULL END) AS dargon_amount,
            SUM(CASE WHEN store='JD_FSS' THEN payed_amount ELSE NULL END) AS jd_fss_amount,
            SUM(CASE WHEN store='JD_FCS' THEN payed_amount ELSE NULL END) AS jd_fcs_amount,
            SUM(CASE WHEN store='TMALL' THEN payed_amount ELSE NULL END) AS tmall_amount,
            SUM(CASE WHEN store='TMALL_WEI' THEN payed_amount ELSE NULL END) AS tmall_wei_amount,
            SUM(CASE WHEN store='TMALL_CHALING' THEN payed_amount ELSE NULL END) AS tmall_chaling_amount,
            SUM(CASE WHEN store='TMALL_PTR' THEN payed_amount ELSE NULL END) AS tmall_ptr_amount,
            SUM(CASE WHEN store='REDBOOK' THEN payed_amount ELSE NULL END) AS redbook_amount,
            SUM(CASE WHEN store='DOUYIN' THEN payed_amount ELSE NULL END) AS douyin_amount,
            SUM(payed_amount ) AS amount
            -- SUM(CASE WHEN order_internal_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL','WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') then  0 else payed_amount END) as real_amount
        FROM [DW_OMS].[DWS_PS_Order]
        --WHERE store IN ('Dragon','DOUYIN')
    ) t0 ON 1 = 1

    UNION ALL

    -- RETRUN
    SELECT
        d.status_comment,
        t.dragon_qty,
        t.dargon_amount,
        (CASE WHEN t0.dargon_amount IS NULL OR t0.dargon_amount=0 THEN NULL ELSE t.dargon_amount/t0.dargon_amount END)  AS dragon_rate,
        t.jd_fcs_qty,
        t.jd_fcs_amount,
        (CASE WHEN t0.jd_fcs_amount IS NULL OR t0.jd_fcs_amount=0 THEN NULL ELSE t.jd_fcs_amount/t0.jd_fcs_amount END) AS jd_fcs_rate,
        t.jd_fss_qty,
        t.jd_fss_amount,
        (CASE WHEN t0.jd_fss_amount IS NULL OR t0.jd_fss_amount=0 THEN NULL ELSE t.jd_fss_amount/t0.jd_fss_amount END) AS jd_fss_rate,
        t.tmall_qty,
        t.tmall_amount,
        (CASE WHEN t0.tmall_amount IS NULL OR t0.tmall_amount=0 THEN NULL ELSE t.tmall_amount/t0.tmall_amount END) AS tmall_rate,
        t.tmall_wei_qty,
        t.tmall_wei_amount,
        (CASE WHEN t0.tmall_wei_amount IS NULL OR t0.tmall_wei_amount=0 THEN NULL ELSE t.tmall_wei_amount/t0.tmall_wei_amount END) AS tmall_wei_rate,
        t.tmall_chaling_qty,
        t.tmall_chaling_amount,
        (CASE WHEN t0.tmall_chaling_amount IS NULL OR t0.tmall_chaling_amount=0 THEN NULL ELSE t.tmall_chaling_amount/t0.tmall_chaling_amount END) AS tmall_chaling_rate, 
        t.tmall_ptr_qty,
        t.tmall_ptr_amount,
        (CASE WHEN t0.tmall_ptr_amount IS NULL OR t0.tmall_ptr_amount=0 THEN NULL ELSE t.tmall_ptr_amount/t0.tmall_ptr_amount END) AS tmall_ptr_rate,
        t.redbook_qty,
        t.redbook_amount,
        (CASE WHEN t0.redbook_amount IS NULL OR t0.redbook_amount=0 THEN NULL ELSE t.redbook_amount/t0.redbook_amount END) AS redbook_rate,
        t.douyin_qty,
        t.douyin_amount,
        (CASE WHEN t0.douyin_amount IS NULL OR t0.douyin_amount=0 THEN NULL ELSE t.douyin_amount/t0.douyin_amount END) AS douyin_rate,
        t.qty,
        t.amount,
        (CASE WHEN t0.amount IS NULL OR t0.amount=0 THEN NULL ELSE t.amount/t0.amount END) AS rate,
        status_type,
        status_level,
        status_order
    FROM (
        SELECT
            order_internal_status,
            status_comment,
            status_type,
            status_level,
            status_order
        FROM DW_OMS.DIM_Order_Internal_Status
        WHERE order_internal_status = 'RETURN'
    ) d
    LEFT JOIN (
        SELECT
            order_internal_status,
            COUNT(CASE WHEN store='Dragon' THEN 1 ELSE NULL END) AS dragon_qty,
            SUM(CASE WHEN store='Dragon' THEN payed_amount ELSE NULL END) AS dargon_amount,
            COUNT(CASE WHEN store='JD_FSS' THEN 1 ELSE NULL END) AS jd_fss_qty,
            SUM(CASE WHEN store='JD_FSS' THEN payed_amount ELSE NULL END) AS jd_fss_amount,
            COUNT(CASE WHEN store='JD_FCS' THEN 1 ELSE NULL END) AS jd_fcs_qty,
            SUM(CASE WHEN store='JD_FCS' THEN payed_amount ELSE NULL END) AS jd_fcs_amount,
            COUNT(CASE WHEN store='TMALL' THEN 1 ELSE NULL END) AS tmall_qty,
            SUM(CASE WHEN store='TMALL' THEN payed_amount ELSE NULL END) AS tmall_amount,
            COUNT(CASE WHEN store='TMALL_WEI' THEN 1 ELSE NULL END) AS tmall_wei_qty,
            SUM(CASE WHEN store='TMALL_WEI' THEN payed_amount ELSE NULL END) AS tmall_wei_amount,
            COUNT(CASE WHEN store='TMALL_CHALING' THEN 1 ELSE NULL END) AS tmall_chaling_qty,
            SUM(CASE WHEN store='TMALL_CHALING' THEN payed_amount ELSE NULL END) AS tmall_chaling_amount,
            COUNT(CASE WHEN store='TMALL_PTR' THEN 1 ELSE NULL END) AS tmall_ptr_qty,
            SUM(CASE WHEN store='TMALL_PTR' THEN payed_amount ELSE NULL END) AS tmall_ptr_amount,
            COUNT(CASE WHEN store='REDBOOK' THEN 1 ELSE NULL END) AS redbook_qty,
            SUM(CASE WHEN store='REDBOOK' THEN payed_amount ELSE NULL END) AS redbook_amount,
            COUNT(CASE WHEN store='DOUYIN' THEN 1 ELSE NULL END) AS douyin_qty,
            SUM(CASE WHEN store='DOUYIN' THEN payed_amount ELSE NULL END) AS douyin_amount,
            COUNT(1) AS qty,
            2 AS [level],
            SUM(payed_amount ) AS amount
        FROM [basic]
        WHERE order_internal_status = 'RETURN'
        GROUP BY order_internal_status

        UNION ALL
        SELECT
            CASE
                WHEN order_internal_status IN ('DELIVERY', 'SHIPPED', 'SIGNED', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') THEN 'SHIPPED'
                WHEN order_internal_status IN ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') THEN 'CANCELLED'
                WHEN order_internal_status IN ('WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') THEN 'PENDING'
                WHEN order_internal_status IN ('RETURN') THEN 'RETURN'
                ELSE 'OTHER'
            END AS Order_internal_status,
            COUNT(CASE WHEN store='Dragon' THEN 1 ELSE NULL END) AS dragon_qty,
            SUM(CASE WHEN store='Dragon' THEN payed_amount ELSE NULL END) AS dargon_amount,
            COUNT(CASE WHEN store='JD_FSS' THEN 1 ELSE NULL END) AS jd_fss_qty,
            SUM(CASE WHEN store='JD_FSS' THEN payed_amount ELSE NULL END) AS jd_fss_amount,
            COUNT(CASE WHEN store='JD_FCS' THEN 1 ELSE NULL END) AS jd_fcs_qty,
            SUM(CASE WHEN store='JD_FCS' THEN payed_amount ELSE NULL END) AS jd_fcs_amount,
            COUNT(CASE WHEN store='TMALL' THEN 1 ELSE NULL END) AS tmall_qty,
            SUM(CASE WHEN store='TMALL' THEN payed_amount ELSE NULL END) AS tmall_amount,
            COUNT(CASE WHEN store='TMALL_WEI' THEN 1 ELSE NULL END) AS tmall_wei_qty,
            SUM(CASE WHEN store='TMALL_WEI' THEN payed_amount ELSE NULL END) AS tmall_wei_amount,
            COUNT(CASE WHEN store='TMALL_CHALING' THEN 1 ELSE NULL END) AS tmall_chaling_qty,
            SUM(CASE WHEN store='TMALL_CHALING' THEN payed_amount ELSE NULL END) AS tmall_chaling_amount,
            COUNT(CASE WHEN store='TMALL_PTR' THEN 1 ELSE NULL END) AS tmall_ptr_qty,
            SUM(CASE WHEN store='TMALL_PTR' THEN payed_amount ELSE NULL END) AS tmall_ptr_amount,
            COUNT(CASE WHEN store='REDBOOK' THEN 1 ELSE NULL END) AS redbook_qty,
            SUM(CASE WHEN store='REDBOOK' THEN payed_amount ELSE NULL END) AS redbook_amount,
            COUNT(CASE WHEN store='DOUYIN' THEN 1 ELSE NULL END) AS douyin_qty,
            SUM(CASE WHEN store='DOUYIN' THEN payed_amount ELSE NULL END) AS douyin_amount,
            COUNT(1) AS qty,
            1 AS [level],
            SUM(payed_amount) AS amount
        FROM [basic]
        WHERE order_internal_status = 'RETURN'
        GROUP BY
            CASE
                WHEN order_internal_status IN ('DELIVERY', 'SHIPPED', 'SIGNED', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') THEN 'SHIPPED'
                WHEN order_internal_status IN ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL') THEN 'CANCELLED'
                WHEN order_internal_status IN ('WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') THEN 'PENDING'
                WHEN order_internal_status IN ('RETURN') THEN 'RETURN'
                ELSE 'OTHER'
            END
    ) t ON d.order_internal_status = t.order_internal_status AND t.level = d.status_level
    LEFT JOIN (
        SELECT
            SUM(CASE WHEN store='Dragon' THEN payed_amount ELSE NULL END) AS dargon_amount,
            SUM(CASE WHEN store='JD_FSS' THEN payed_amount ELSE NULL END) AS jd_fss_amount,
            SUM(CASE WHEN store='JD_FCS' THEN payed_amount ELSE NULL END) AS jd_fcs_amount,
            SUM(CASE WHEN store='TMALL' THEN payed_amount ELSE NULL END) AS tmall_amount,
            SUM(CASE WHEN store='TMALL_WEI' THEN payed_amount ELSE NULL END) AS tmall_wei_amount,
            SUM(CASE WHEN store='TMALL_CHALING' THEN payed_amount ELSE NULL END) AS tmall_chaling_amount,
            SUM(CASE WHEN store='TMALL_PTR' THEN payed_amount ELSE NULL END) AS tmall_ptr_amount,
            SUM(CASE WHEN store='REDBOOK' THEN payed_amount ELSE NULL END) AS redbook_amount,
            SUM(CASE WHEN store='DOUYIN' THEN payed_amount ELSE NULL END) AS douyin_amount,
            SUM(payed_amount) AS amount
            -- SUM(CASE WHEN order_internal_status in ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL','WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') then  0 else payed_amount END) as real_amount
        FROM [DW_OMS].[DWS_PS_Order]
        WHERE order_internal_status NOT IN ('CANCEL', 'CANCELLED', 'PARTAIL_CANCEL','WAITING', 'EXCEPTION', 'PENDING','WAIT_JD_CONFIRM', 'WAIT_SAPPROCESS','WAIT_JDPROCESS','WAIT_SEND_SAP','WAIT_TMALLPROCESS','WAIT_WAREHOUSE_PROCESS','SPLITED','WAIT_ROUTE_ORDER') 
    ) t0 ON 1 = 1

END
GO
