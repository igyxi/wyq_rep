/****** Object:  StoredProcedure [TEMP].[SP_DWS_POS_Order_With_SKU_Bak20220718]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_POS_Order_With_SKU_Bak20220718] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-10       tali           Initial Version
-- 2022-03-21       tali           change the logic
-- 2022-05-26       tali           filter KEY_CUSTOMER_szCustomerID
-- 2022-07-11       tali           fix duplicate rows in pos
-- ========================================================================================
truncate table DW_POS.DWS_POS_Order_With_SKU;
insert into DW_POS.DWS_POS_Order_With_SKU
select
    POS.szBarcodeComplete as barcode,
    POS.Hdr_lTaCreatedRetailStoreID as store_code,
    si.province,
    si.city,
    C.KEY_CUSTOMER_szCustomerID  as member_card,
    c.szSephoraCustomerGroupName as member_card_grade,
    try_cast(cast(convert(date, SUBSTRING(pos.Hdr_szTaCreatedDate,1,8) , 112) as nvarchar) + ' ' + SUBSTRING(pos.Hdr_szTaCreatedDate, 9, 2) + ':'+ SUBSTRING(pos.Hdr_szTaCreatedDate, 11, 2) + ':' + SUBSTRING(pos.Hdr_szTaCreatedDate, 13, 2) as datetime) as order_time,
    try_cast(cast(CONVERT(date, SUBSTRING(POS.szBarcodeComplete,17,8), 112) as nvarchar) + ' ' + SUBSTRING(POS.szBarcodeComplete,25,2) + ':'+ SUBSTRING(POS.szBarcodeComplete,27,2)+':' + SUBSTRING(POS.szBarcodeComplete,29,2) as datetime) AS payment_time,
    POS.ARTICLE_szPOSItemID as item_sku_code,
    POS.ARTICLE_szDesc1 as item_sku_name,
    try_cast(POS.dTaQty as int) as item_quantity,
    cast(POS.dTaTotal as decimal) as item_total_amount,
    cast(POS.dTaTotal as decimal) + isnull(try_cast(POS.dTaTotalDiscounted as float),0) as item_apportion_amount,
    abs(try_cast(POS.dTaTotalDiscounted as float)) AS item_discount_amount,
    CURRENT_TIMESTAMP as insert_timestamp
from 
(
    select distinct 
        szBarcodeComplete, Hdr_lTaCreatedRetailStoreID, Hdr_szTaCreatedDate,ARTICLE_szPOSItemID, ARTICLE_szDesc1,
        dTaQty,
        dTaTotal,
        dTaTotalDiscounted,
        Hdr_lTaCreatedWorkstationNmbr,
        Hdr_lTaCreatedTaNmbr
    from 
        [ODS_POS].[TLOG_ART_SALE]
) POS
join
    [ODS_SAP].[Dim_Store] s
on pos.Hdr_lTaCreatedRetailStoreID = s.store_code
join 
(
    select distinct szBarcodeComplete, szTaType from ODS_POS.TLOG_HEADER 
)H
on pos.szBarcodeComplete = H.szBarcodeComplete
left join 
    stg_nso.storeinfo si
on pos.Hdr_lTaCreatedRetailStoreID = si.storeno
left join 
(
    select distinct
        szBarcodeComplete, KEY_CUSTOMER_szCustomerID, szSephoraCustomerGroupName
        
    from 
        ODS_POS.TLOG_CUSTOMER 
    where
        PATINDEX('%[^0-9A-Za-z]%',KEY_CUSTOMER_szCustomerID) = 0
)C
on pos.szBarcodeComplete = c.szBarcodeComplete
where H.szTaType in ('SA', 'RT')
and s.country_code = 'CN'
;
END

GO
