/****** Object:  StoredProcedure [TEMP].[SP_DWS_OMS_Integration_KPI_BAK20230428]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_OMS_Integration_KPI_BAK20230428] AS
BEGIN
truncate table DW_OMS.DWS_OMS_Integration_KPI ;
insert into DW_OMS.DWS_OMS_Integration_KPI
--创建整合落地表
SELECT
    B1.place_date
    ,B1.Dragon_Sales
    ,B1.TMALL_Sales
    ,B1.JD_Sales
    ,B1.TIKTOK_Sales
    ,B1.APP_IOS_Sales
    ,B1.APP_ANDROID_Sales
    ,B1.WECHAT_Sales
    ,B1.Mini_Program_Sales
    ,B1.H5_Sales
    ,B1.PC_Sales
    ,B1.O2O_Sales
    ,B1.TMALL_Sephora_Sales
    ,B1.TMALL_WEI_Sales
    ,B1.TMALL_CHALING_Sales
    ,B1.TMALL_PTR_Sales
    ,B1.JD_FSS_Sales
    ,B1.JD_FCS_Sales

    ,B1.Dragon_Order
    ,B1.TMALL_Order
    ,B1.JD_Order
    ,B1.TIKTOK_Order
    ,B1.APP_IOS_Order
    ,B1.APP_ANDROID_Order
    ,B1.WECHAT_Order
    ,B1.Mini_Program_Order
    ,B1.H5_Order
    ,B1.PC_Order
    ,B1.O2O_Order
    ,B1.TMALL_Sephora_Order
    ,B1.TMALL_WEI_Order
    ,B1.TMALL_CHALING_Order
    ,B1.TMALL_PTR_Order
    ,B1.JD_FSS_Order
    ,B1.JD_FCS_Order

    ,B1.Dragon_Sold_Qty
    ,B1.TMALL_Sold_Qty
    ,B1.JD_Sold_Qty
    ,B1.TIKTOK_Sold_Qty
    ,B1.APP_IOS_Sold_Qty
    ,B1.APP_ANDROID_Sold_Qty
    ,B1.WECHAT_Sold_Qty
    ,B1.Mini_Program_Sold_Qty
    ,B1.H5_Sold_Qty
    ,B1.PC_Sold_Qty
    ,B1.O2O_Sold_Qty
    ,B1.TMALL_Sephora_Sold_Qty
    ,B1.TMALL_WEI_Sold_Qty
    ,B1.TMALL_CHALING_Sold_Qty
    ,B1.TMALL_PTR_Sold_Qty
    ,B1.JD_FSS_Sold_Qty
    ,B1.JD_FCS_Sold_Qty

    ,B2.Dragon_New_Buyer
    ,B2.TMALL_New_Buyer
    ,B2.JD_New_Buyer
    ,B2.TIKTOK_New_Buyer
    ,B2.TMALL_Sephora_New_Buyer
    ,B2.TMALL_WEI_New_Buyer
    ,B2.TMALL_CHALING_New_Buyer
    ,B2.TMALL_PTR_New_Buyer
    ,B2.JD_FSS_New_Buyer
    ,B2.JD_FCS_New_Buyer

    ,B2.Dragon_Return_Buyer
    ,B2.TMALL_Return_Buyer
    ,B2.JD_Return_Buyer
    ,B2.TIKTOK_Return_Buyer
    ,B2.TMALL_Sephora_Return_Buyer
    ,B2.TMALL_WEI_Return_Buyer
    ,B2.TMALL_CHALING_Return_Buyer
    ,B2.TMALL_PTR_Return_Buyer
    ,B2.JD_FSS_Return_Buyer
    ,B2.JD_FCS_Return_Buyer

    ,B2.Dragon_Sales_from_New_Buyer
    ,B2.TMALL_Sales_from_New_Buyer
    ,B2.JD_Sales_from_New_Buyer
    ,B2.TIKTOK_Sales_from_New_Buyer
    ,B2.TMALL_Sephora_Sales_from_New_Buyer
    ,B2.TMALL_WEI_Sales_from_New_Buyer
    ,B2.TMALL_CHALING_Sales_from_New_Buyer
    ,B2.TMALL_PTR_Sales_from_New_Buyer
    ,B2.JD_FSS_Sales_from_New_Buyer
    ,B2.JD_FCS_Sales_from_New_Buyer

    ,B2.Dragon_Sales_from_Return_Buyer
    ,B2.TMALL_Sales_from_Return_Buyer
    ,B2.JD_Sales_from_Return_Buyer
    ,B2.TIKTOK_Sales_from_Return_Buyer
    ,B2.TMALL_Sephora_Sales_from_Return_Buyer
    ,B2.TMALL_WEI_Sales_from_Return_Buyer
    ,B2.TMALL_CHALING_Sales_from_Return_Buyer
    ,B2.TMALL_PTR_Sales_from_Return_Buyer
    ,B2.JD_FSS_Sales_from_Return_Buyer
    ,B2.JD_FCS_Sales_from_Return_Buyer

    ,B3.APP_UV
    ,B3.MiniProgram_UV
    ,B3.PC_UV
    ,B3.Mobile_UV
    ,current_timestamp as insert_timestamp
FROM
(
    SELECT 
        A1.place_date
        ,SUM(A1.Dragon_Sales) as Dragon_Sales
        ,sum(A1.TMALL_Sales) as TMALL_Sales
        ,sum(A1.JD_Sales) as JD_Sales
        ,sum(A1.TIKTOK_Sales) as TIKTOK_Sales
        ,sum(A1.APP_IOS_Sales) as APP_IOS_Sales
        ,sum(A1.APP_ANDROID_Sales) as APP_ANDROID_Sales
        ,sum(A1.WECHAT_Sales) as WECHAT_Sales
        ,sum(A1.Mini_Program_Sales) as Mini_Program_Sales
        ,sum(A1.H5_Sales) as H5_Sales
        ,sum(A1.PC_Sales) as PC_Sales
        ,sum(A1.O2O_Sales) as O2O_Sales
        ,sum(A1.TMALL_Sephora_Sales) as TMALL_Sephora_Sales
        ,sum(A1.TMALL_WEI_Sales) as TMALL_WEI_Sales
        ,sum(A1.TMALL_CHALING_Sales) as TMALL_CHALING_Sales
        ,sum(A1.TMALL_PTR_Sales) as TMALL_PTR_Sales
        ,sum(A1.JD_FSS_Sales) as JD_FSS_Sales
        ,sum(A1.JD_FCS_Sales) as JD_FCS_Sales

        ,SUM(A1.Dragon_Order) as Dragon_Order
        ,sum(A1.TMALL_Order) as TMALL_Order
        ,sum(A1.JD_Order) as JD_Order
        ,sum(A1.TIKTOK_Order) as TIKTOK_Order
        ,sum(A1.APP_IOS_Order) as APP_IOS_Order
        ,sum(A1.APP_ANDROID_Order) as APP_ANDROID_Order
        ,sum(A1.WECHAT_Order) as WECHAT_Order
        ,sum(A1.Mini_Program_Order) as Mini_Program_Order
        ,sum(A1.H5_Order) as H5_Order
        ,sum(A1.PC_Order) as PC_Order
        ,sum(A1.O2O_Order) as O2O_Order
        ,sum(A1.TMALL_Sephora_Order) as TMALL_Sephora_Order
        ,sum(A1.TMALL_WEI_Order) as TMALL_WEI_Order
        ,sum(A1.TMALL_CHALING_Order) as TMALL_CHALING_Order
        ,sum(A1.TMALL_PTR_Order) as TMALL_PTR_Order
        ,sum(A1.JD_FSS_Order) as JD_FSS_Order
        ,sum(A1.JD_FCS_Order) as JD_FCS_Order

        ,SUM(A1.Dragon_Sold_Qty) as Dragon_Sold_Qty
        ,sum(A1.TMALL_Sold_Qty) as TMALL_Sold_Qty
        ,sum(A1.JD_Sold_Qty) as JD_Sold_Qty
        ,sum(A1.TIKTOK_Sold_Qty) as TIKTOK_Sold_Qty
        ,sum(A1.APP_IOS_Sold_Qty) as APP_IOS_Sold_Qty
        ,sum(A1.APP_ANDROID_Sold_Qty) as APP_ANDROID_Sold_Qty
        ,sum(A1.WECHAT_Sold_Qty) as WECHAT_Sold_Qty
        ,sum(A1.Mini_Program_Sold_Qty) as Mini_Program_Sold_Qty
        ,sum(A1.H5_Sold_Qty) as H5_Sold_Qty
        ,sum(A1.PC_Sold_Qty) as PC_Sold_Qty
        ,sum(A1.O2O_Sold_Qty) as O2O_Sold_Qty
        ,sum(A1.TMALL_Sephora_Sold_Qty) as TMALL_Sephora_Sold_Qty
        ,sum(A1.TMALL_WEI_Sold_Qty) as TMALL_WEI_Sold_Qty
        ,sum(A1.TMALL_CHALING_Sold_Qty) as TMALL_CHALING_Sold_Qty
        ,sum(A1.TMALL_PTR_Sold_Qty) as TMALL_PTR_Sold_Qty
        ,sum(A1.JD_FSS_Sold_Qty) as JD_FSS_Sold_Qty
        ,sum(A1.JD_FCS_Sold_Qty) as JD_FCS_Sold_Qty
    FROM
    (
        SELECT
             rsobl.place_date
            ,CASE WHEN rsobl.store_cd in ('S001') THEN SUM(rsobl.product_amount) END AS Dragon_Sales
            ,CASE WHEN rsobl.channel_cd IN ('TMALL','TMALL_WEI','TMALL_CHALING','TMALL_PTR') THEN SUM(rsobl.product_amount) END AS TMALL_Sales
            ,CASE WHEN rsobl.store_cd in ('JD001', 'JD002','JD003') THEN SUM(rsobl.product_amount) END AS JD_Sales
            ,CASE WHEN rsobl.channel_cd IN ('DOUYIN') THEN SUM(rsobl.product_amount) END AS TIKTOK_Sales
            ,CASE WHEN rsobl.channel_cd IN ('APP(IOS)') THEN SUM(rsobl.product_amount) END AS APP_IOS_Sales
            ,CASE WHEN rsobl.channel_cd IN ('APP(ANDROID)') THEN SUM(rsobl.product_amount) END AS APP_ANDROID_Sales
            ,CASE WHEN rsobl.channel_cd IN ('WECHAT') THEN SUM(rsobl.product_amount) END AS WECHAT_Sales
            ,CASE WHEN rsobl.channel_cd IN ('MINIPROGRAM', 'ANNYMINIPROGRAM', 'BENEFITMINIPROGRAM') THEN SUM(rsobl.product_amount) END AS Mini_Program_Sales
            ,CASE WHEN rsobl.channel_cd IN ('MOBILE') THEN SUM(rsobl.product_amount) END AS H5_Sales
            ,CASE WHEN rsobl.channel_cd IN ('PC') THEN SUM(rsobl.product_amount) END AS PC_Sales
            ,CASE WHEN rsobl.channel_cd IN ('O2O') THEN SUM(rsobl.product_amount) END AS O2O_Sales
            ,CASE WHEN rsobl.channel_cd IN ('TMALL') THEN SUM(rsobl.product_amount) END AS TMALL_Sephora_Sales
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_WEI') THEN SUM(rsobl.product_amount) END AS TMALL_WEI_Sales
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_CHALING') THEN SUM(rsobl.product_amount) END AS TMALL_CHALING_Sales
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_PTR') THEN SUM(rsobl.product_amount) END AS TMALL_PTR_Sales
            ,CASE WHEN rsobl.store_cd in ('JD001', 'JD002') THEN SUM(rsobl.product_amount) END AS JD_FSS_Sales
            ,CASE WHEN rsobl.store_cd in ('JD003') THEN SUM(rsobl.product_amount) END AS JD_FCS_Sales

            ,CASE WHEN rsobl.store_cd in ('S001') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS Dragon_Order
            ,CASE WHEN rsobl.channel_cd IN ('TMALL','TMALL_WEI','TMALL_CHALING','TMALL_PTR') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS TMALL_Order
            ,CASE WHEN rsobl.store_cd in ('JD001', 'JD002','JD003') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS JD_Order
            ,CASE WHEN rsobl.channel_cd IN ('DOUYIN') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS TIKTOK_Order
            ,CASE WHEN rsobl.channel_cd IN ('APP(IOS)') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS APP_IOS_Order
            ,CASE WHEN rsobl.channel_cd IN ('APP(ANDROID)') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS APP_ANDROID_Order
            ,CASE WHEN rsobl.channel_cd IN ('WECHAT') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS WECHAT_Order
            ,CASE WHEN rsobl.channel_cd IN ('MINIPROGRAM', 'ANNYMINIPROGRAM', 'BENEFITMINIPROGRAM') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS Mini_Program_Order
            ,CASE WHEN rsobl.channel_cd IN ('MOBILE') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS H5_Order
            ,CASE WHEN rsobl.channel_cd IN ('PC') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS PC_Order
            ,CASE WHEN rsobl.channel_cd IN ('O2O') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS O2O_Order
            ,CASE WHEN rsobl.channel_cd IN ('TMALL') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS TMALL_Sephora_Order
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_WEI') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS TMALL_WEI_Order
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_CHALING') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS TMALL_CHALING_Order
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_PTR') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS TMALL_PTR_Order
            ,CASE WHEN rsobl.store_cd in ('JD001', 'JD002') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS JD_FSS_Order
            ,CASE WHEN rsobl.store_cd in ('JD003') THEN COUNT(DISTINCT rsobl.sales_order_number) END AS JD_FCS_Order

            ,CASE WHEN rsobl.store_cd in ('S001') THEN SUM(rsobl.item_vb_valid_quantity) END AS Dragon_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('TMALL','TMALL_WEI','TMALL_CHALING','TMALL_PTR') THEN SUM(rsobl.item_vb_valid_quantity) END AS TMALL_Sold_Qty
            ,CASE WHEN rsobl.store_cd in ('JD001', 'JD002','JD003') THEN SUM(rsobl.item_vb_valid_quantity) END AS JD_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('DOUYIN') THEN SUM(rsobl.item_vb_valid_quantity) END AS TIKTOK_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('APP(IOS)') THEN SUM(rsobl.item_vb_valid_quantity) END AS APP_IOS_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('APP(ANDROID)') THEN SUM(rsobl.item_vb_valid_quantity) END AS APP_ANDROID_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('WECHAT') THEN SUM(rsobl.item_vb_valid_quantity) END AS WECHAT_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('MINIPROGRAM', 'ANNYMINIPROGRAM', 'BENEFITMINIPROGRAM') THEN SUM(rsobl.item_vb_valid_quantity) END AS Mini_Program_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('MOBILE') THEN SUM(rsobl.item_vb_valid_quantity) END AS H5_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('PC') THEN SUM(rsobl.item_vb_valid_quantity) END AS PC_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('O2O') THEN SUM(rsobl.item_vb_valid_quantity) END AS O2O_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('TMALL') THEN SUM(rsobl.item_vb_valid_quantity) END AS TMALL_Sephora_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_WEI') THEN SUM(rsobl.item_vb_valid_quantity) END AS TMALL_WEI_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_CHALING') THEN SUM(rsobl.item_vb_valid_quantity) END AS TMALL_CHALING_Sold_Qty
            ,CASE WHEN rsobl.channel_cd IN ('TMALL_PTR') THEN SUM(rsobl.item_vb_valid_quantity) END AS TMALL_PTR_Sold_Qty
            ,CASE WHEN rsobl.store_cd in ('JD001', 'JD002') THEN SUM(rsobl.item_vb_valid_quantity) END AS JD_FSS_Sold_Qty
            ,CASE WHEN rsobl.store_cd in ('JD003') THEN SUM(rsobl.item_vb_valid_quantity) END AS JD_FCS_Sold_Qty
        FROM 
           DW_OMS.RPT_Sales_Order_Basic_Level rsobl
        JOIN 
           DW_Common.Dim_EB_StoreGroup desg
        ON 
           desg.store_cd = rsobl.store_cd COLLATE Chinese_PRC_CS_AI_WS
        WHERE 
           rsobl.is_placed_flag = 1
           AND desg.store_group IS NOT NULL
           --AND rsobl.place_date >= '2022-04-01'
           AND rsobl.channel_cd <> 'OFF_LINE'
        GROUP BY 
           rsobl.place_date,rsobl.store_cd,rsobl.channel_cd
    ) A1
    GROUP BY A1.place_date
) B1
LEFT JOIN
(
    SELECT 
        A2.place_date
        ,SUM(A2.Dragon_New_Buyer) AS Dragon_New_Buyer
        ,SUM(A2.TMALL_New_Buyer) AS TMALL_New_Buyer
        ,SUM(A2.JD_New_Buyer) AS JD_New_Buyer
        ,SUM(A2.TIKTOK_New_Buyer) AS TIKTOK_New_Buyer
        ,SUM(A2.TMALL_Sephora_New_Buyer) AS TMALL_Sephora_New_Buyer
        ,SUM(A2.TMALL_WEI_New_Buyer) AS TMALL_WEI_New_Buyer
        ,SUM(A2.TMALL_CHALING_New_Buyer) AS TMALL_CHALING_New_Buyer
        ,SUM(A2.TMALL_PTR_New_Buyer) AS TMALL_PTR_New_Buyer
        ,SUM(A2.JD_FSS_New_Buyer) AS JD_FSS_New_Buyer
        ,SUM(A2.JD_FCS_New_Buyer) AS JD_FCS_New_Buyer

        ,SUM(A2.Dragon_Return_Buyer) AS Dragon_Return_Buyer
        ,SUM(A2.TMALL_Return_Buyer) AS TMALL_Return_Buyer
        ,SUM(A2.JD_Return_Buyer) AS JD_Return_Buyer
        ,SUM(A2.TIKTOK_Return_Buyer) AS TIKTOK_Return_Buyer
        ,SUM(A2.TMALL_Sephora_Return_Buyer) AS TMALL_Sephora_Return_Buyer
        ,SUM(A2.TMALL_WEI_Return_Buyer) AS TMALL_WEI_Return_Buyer
        ,SUM(A2.TMALL_CHALING_Return_Buyer) AS TMALL_CHALING_Return_Buyer
        ,SUM(A2.TMALL_PTR_Return_Buyer) AS TMALL_PTR_Return_Buyer
        ,SUM(A2.JD_FSS_Return_Buyer) AS JD_FSS_Return_Buyer
        ,SUM(A2.JD_FCS_Return_Buyer) AS JD_FCS_Return_Buyer

        ,SUM(A2.Dragon_Sales_from_New_Buyer) AS Dragon_Sales_from_New_Buyer
        ,SUM(A2.TMALL_Sales_from_New_Buyer) AS TMALL_Sales_from_New_Buyer
        ,SUM(A2.JD_Sales_from_New_Buyer) AS JD_Sales_from_New_Buyer
        ,SUM(A2.TIKTOK_Sales_from_New_Buyer) AS TIKTOK_Sales_from_New_Buyer
        ,SUM(A2.TMALL_Sephora_Sales_from_New_Buyer) AS TMALL_Sephora_Sales_from_New_Buyer
        ,SUM(A2.TMALL_WEI_Sales_from_New_Buyer) AS TMALL_WEI_Sales_from_New_Buyer
        ,SUM(A2.TMALL_CHALING_Sales_from_New_Buyer) AS TMALL_CHALING_Sales_from_New_Buyer
        ,SUM(A2.TMALL_PTR_Sales_from_New_Buyer) AS TMALL_PTR_Sales_from_New_Buyer
        ,SUM(A2.JD_FSS_Sales_from_New_Buyer) AS JD_FSS_Sales_from_New_Buyer
        ,SUM(A2.JD_FCS_Sales_from_New_Buyer) AS JD_FCS_Sales_from_New_Buyer

        ,SUM(A2.Dragon_Sales_from_Return_Buyer) AS Dragon_Sales_from_Return_Buyer
        ,SUM(A2.TMALL_Sales_from_Return_Buyer) AS TMALL_Sales_from_Return_Buyer
        ,SUM(A2.JD_Sales_from_Return_Buyer) AS JD_Sales_from_Return_Buyer
        ,SUM(A2.TIKTOK_Sales_from_Return_Buyer) AS TIKTOK_Sales_from_Return_Buyer
        ,SUM(A2.TMALL_Sephora_Sales_from_Return_Buyer) AS TMALL_Sephora_Sales_from_Return_Buyer
        ,SUM(A2.TMALL_WEI_Sales_from_Return_Buyer) AS TMALL_WEI_Sales_from_Return_Buyer
        ,SUM(A2.TMALL_CHALING_Sales_from_Return_Buyer) AS TMALL_CHALING_Sales_from_Return_Buyer
        ,SUM(A2.TMALL_PTR_Sales_from_Return_Buyer) AS TMALL_PTR_Sales_from_Return_Buyer
        ,SUM(A2.JD_FSS_Sales_from_Return_Buyer) AS JD_FSS_Sales_from_Return_Buyer
        ,SUM(A2.JD_FCS_Sales_from_Return_Buyer) AS JD_FCS_Sales_from_Return_Buyer
    FROM 
    (
        SELECT
            rsobl.place_date
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.store_cd in ('S001') THEN COUNT(DISTINCT rsobl.super_id) END AS Dragon_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL','TMALL_WEI','TMALL_CHALING','TMALL_PTR') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.store_cd in ('JD001', 'JD002','JD003') THEN COUNT(DISTINCT rsobl.super_id) END AS JD_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('DOUYIN') THEN COUNT(DISTINCT rsobl.super_id) END AS TIKTOK_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_Sephora_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL_WEI') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_WEI_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL_CHALING') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_CHALING_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL_PTR') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_PTR_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.store_cd in ('JD001', 'JD002') THEN COUNT(DISTINCT rsobl.super_id) END AS JD_FSS_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.store_cd in ('JD003') THEN COUNT(DISTINCT rsobl.super_id) END AS JD_FCS_New_Buyer

            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.store_cd in ('S001') THEN COUNT(DISTINCT rsobl.super_id) END AS Dragon_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL','TMALL_WEI','TMALL_CHALING','TMALL_PTR') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.store_cd in ('JD001', 'JD002','JD003') THEN COUNT(DISTINCT rsobl.super_id) END AS JD_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('DOUYIN') THEN COUNT(DISTINCT rsobl.super_id) END AS TIKTOK_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_Sephora_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL_WEI') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_WEI_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL_CHALING') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_CHALING_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL_PTR') THEN COUNT(DISTINCT rsobl.super_id) END AS TMALL_PTR_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.store_cd in ('JD001', 'JD002') THEN COUNT(DISTINCT rsobl.super_id) END AS JD_FSS_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.store_cd in ('JD003') THEN COUNT(DISTINCT rsobl.super_id) END AS JD_FCS_Return_Buyer

            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.store_cd in ('S001') THEN SUM(rsobl.product_amount) END AS Dragon_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL','TMALL_WEI','TMALL_CHALING','TMALL_PTR') THEN SUM(rsobl.product_amount) END AS TMALL_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.store_cd in ('JD001', 'JD002','JD003') THEN SUM(rsobl.product_amount) END AS JD_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('DOUYIN') THEN SUM(rsobl.product_amount) END AS TIKTOK_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL') THEN SUM(rsobl.product_amount) END AS TMALL_Sephora_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL_WEI') THEN SUM(rsobl.product_amount) END AS TMALL_WEI_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL_CHALING') THEN SUM(rsobl.product_amount) END AS TMALL_CHALING_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.channel_cd IN ('TMALL_PTR') THEN SUM(rsobl.product_amount) END AS TMALL_PTR_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.store_cd in ('JD001', 'JD002') THEN SUM(rsobl.product_amount) END AS JD_FSS_Sales_from_New_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'BRAND_NEW' AND rsobl.store_cd in ('JD003') THEN SUM(rsobl.product_amount) END AS JD_FCS_Sales_from_New_Buyer

            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.store_cd in ('S001') THEN SUM(rsobl.product_amount) END AS Dragon_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL','TMALL_WEI','TMALL_CHALING','TMALL_PTR') THEN SUM(rsobl.product_amount) END AS TMALL_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.store_cd in ('JD001', 'JD002','JD003') THEN SUM(rsobl.product_amount) END AS JD_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('DOUYIN') THEN SUM(rsobl.product_amount) END AS TIKTOK_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL') THEN SUM(rsobl.product_amount) END AS TMALL_Sephora_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL_WEI') THEN SUM(rsobl.product_amount) END AS TMALL_WEI_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL_CHALING') THEN SUM(rsobl.product_amount) END AS TMALL_CHALING_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.channel_cd IN ('TMALL_PTR') THEN SUM(rsobl.product_amount) END AS TMALL_PTR_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.store_cd in ('JD001', 'JD002') THEN SUM(rsobl.product_amount) END AS JD_FSS_Sales_from_Return_Buyer
            ,CASE WHEN rsobl.member_daily_new_status = 'RETURN' AND rsobl.store_cd in ('JD003') THEN SUM(rsobl.product_amount) END AS JD_FCS_Sales_from_Return_Buyer
        FROM
           DW_OMS.RPT_Sales_Order_Basic_Level rsobl
        JOIN
           DW_Common.Dim_EB_StoreGroup desg
        ON
           desg.store_cd = rsobl.store_cd COLLATE Chinese_PRC_CS_AI_WS
        WHERE
            rsobl.is_placed_flag = 1
            --AND rsobl.place_date >= '2022'
            --AND rsobl.place_date >= '2022-04-01'
            --AND desg.store_group in('JD','TMALL','Dragon','TikTok')
            --AND channel_cd not in ('MOBILE','O2O','PC','WECHAT','APP(ANDROID)','APP(IOS)')
            --AND rsobl.member_daily_new_status IN ('BRAND_NEW','CONVERT_NEW', 'RETURN')
        GROUP BY
           rsobl.place_date,rsobl.member_daily_new_status,rsobl.store_cd,rsobl.channel_cd
    ) A2
    GROUP BY A2.place_date
) B2
ON B1.place_date = B2.place_date
LEFT JOIN 
(
    SELECT 
        [DATE] as place_date,
        count(DISTINCT CASE WHEN event IN ('$MPViewScreen','$AppViewScreen') 
	    							AND platform_type IN ('Mini Program','MiniProgram') THEN user_id END) AS  MiniProgram_UV,
        count(DISTINCT CASE WHEN event IN ('$MPViewScreen','$AppViewScreen') 
	    							AND platform_type IN ('app','APP') THEN user_id END) AS  APP_UV,
	    count(DISTINCT CASE WHEN event IN ('$pageview') AND platform_type IN ('mobile') THEN user_id END) AS Mobile_UV,
   	    count(DISTINCT CASE WHEN event IN ('$pageview') AND platform_type IN ('PC') THEN user_id END) AS PC_UV                             
    FROM 
        [DW_Sensor].[DWS_Events_Session_Cutby30m]
    GROUP BY 
	[DATE]
) B3
ON B1.place_date=B3.place_date 
;
end
GO
