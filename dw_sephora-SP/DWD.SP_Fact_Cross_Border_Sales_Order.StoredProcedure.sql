/****** Object:  StoredProcedure [DWD].[SP_Fact_Cross_Border_Sales_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Cross_Border_Sales_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-16       yaozhipeng        Initial Version
-- ========================================================================================
TRUNCATE TABLE DWD.Fact_Cross_Border_Sales_Order;

INSERT INTO  DWD.Fact_Cross_Border_Sales_Order
SELECT 
    trans_id,
    invc_no,
    invc_id,
    channel_code,
    channel_name,
    store_code,
    province,
    city,
    trans_type,
    member_id,
    member_card,
    order_time,
    trans_time,
    sap_time,
    item_sku_code,
    item_sku_name,
    item_quantity,
    item_total_amount,
    item_apportion_amount,
    item_discount_amount,
    coupon_offer_id,
    is_valid,
    create_time,
    update_time,
    insert_timestamp
FROM 
    DW_CRM.DW_Trans_Order_With_SKU
WHERE 
    member_id is null and member_card is not null and member_card <>'0';

END
GO
