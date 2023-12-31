/****** Object:  StoredProcedure [DW_POS].[SP_DW_POS_Order_With_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_POS].[SP_DW_POS_Order_With_SKU] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-10       tali           Initial Version
-- 2022-03-21       tali           change the logic
-- 2022-05-26       tali           filter KEY_CUSTOMER_szCustomerID
-- 2022-07-11       tali           fix duplicate rows in pos
-- 2022-07-15       tali           feat unique columns
-- 2022-07-25       tali           fix item_apportion_amount null
-- 2022-07-27       tali           feat add district
-- 2022-08-18       tali           fix add Hdr_lTaCreateNmbr for tlog distinct
-- 2023-02-23       wangzhichun    rename DWS_POS_Order_With_SKU to DW_POS_Order_With_SKU
-- 2023-04-19       houshuangqiang add payment_workstation
-- 2023-05-06       zhailonglong   add sys_create_time
-- 2023-05-08       wangzhichun    deleted stg_nso.storeinfo
-- ========================================================================================
truncate table DW_POS.DW_POS_Order_With_SKU;
insert into DW_POS.DW_POS_Order_With_SKU
select 
    barcode,
    barcode as invoice_no,
    left(barcode, 28) as invoice_id,
    store_code,
    member_card,
    member_card_grade,
    max(order_time),
    payment_time,
	payment_workstation,
    item_sku_code,
    max(item_sku_name) as item_sku_name,
    sum(item_quantity) as item_quantity,
    sum(item_total_amount) as item_total_amount,
    sum(item_apportion_amount) as item_apportion_amount,
    sum(item_discount_amount) as item_discount_amount,
    sys_create_time,
    CURRENT_TIMESTAMP as insert_timestamp
from
(
    select
        POS.szBarcodeComplete as barcode,
        POS.Hdr_lTaCreatedRetailStoreID as store_code,
        C.KEY_CUSTOMER_szCustomerID  as member_card,
        c.szSephoraCustomerGroupName as member_card_grade,
        try_cast(cast(convert(date, SUBSTRING(pos.Hdr_szTaCreatedDate,1,8) , 112) as nvarchar) + ' ' + SUBSTRING(pos.Hdr_szTaCreatedDate, 9, 2) + ':'+ SUBSTRING(pos.Hdr_szTaCreatedDate, 11, 2) + ':' + SUBSTRING(pos.Hdr_szTaCreatedDate, 13, 2) as datetime) as order_time,
        try_cast(cast(CONVERT(date, SUBSTRING(POS.szBarcodeComplete,17,8), 112) as nvarchar) + ' ' + SUBSTRING(POS.szBarcodeComplete,25,2) + ':'+ SUBSTRING(POS.szBarcodeComplete,27,2)+':' + SUBSTRING(POS.szBarcodeComplete,29,2) as datetime) AS payment_time,
		--max(pos.payment_workstation) over(partition by pos.szbarcodecomplete, pos.hdr_ltacreatedretailstoreid, c.key_customer_szcustomerid, pos.article_szpositemid order by pos.hdr_sztacreateddate desc ) payment_workstation,
		case when pos.[Hdr_szTaCreatedWorkstationGroupID] = 'MOBILE_CN' then 'Mobile POS' else 'POS' end payment_workstation,
        POS.ARTICLE_szPOSItemID as item_sku_code,
        POS.ARTICLE_szDesc1 as item_sku_name,
        isnull(try_cast(POS.dTaQty as int), 0) as item_quantity,
        isnull(try_cast(POS.dTaTotal as decimal), 0) as item_total_amount,
        isnull(try_cast(POS.dTaTotal as decimal), 0) + isnull(try_cast(POS.dTaTotalDiscounted as float),0) as item_apportion_amount,
        abs(isnull(try_cast(POS.dTaTotalDiscounted as float), 0)) AS item_discount_amount,
        CreateTime as sys_create_time
    from 
    (
        select distinct 
            szBarcodeComplete, 
            Hdr_lTaCreatedRetailStoreID, 
            Hdr_szTaCreatedDate,
			--case when [Hdr_szTaCreatedWorkstationGroupID] = 'MOBILE_CN' then 'Mobile POS' else 'POS' end payment_workstation,
			max(Hdr_szTaCreatedWorkstationGroupID) over(partition by szBarcodeComplete,Hdr_lTaCreatedRetailStoreID,ARTICLE_szPOSItemID) as Hdr_szTaCreatedWorkstationGroupID,
            ARTICLE_szPOSItemID, 
            ARTICLE_szDesc1,
            dTaQty,
            dTaTotal,
            dTaTotalDiscounted,
            Hdr_lTaCreatedWorkstationNmbr,
            Hdr_lTaCreateNmbr,
            Hdr_lTaCreatedTaNmbr,
            CreateTime
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
    (
        select distinct
            szBarcodeComplete, 
            KEY_CUSTOMER_szCustomerID, 
            szSephoraCustomerGroupName 
        from 
            ODS_POS.TLOG_CUSTOMER 
        where
            PATINDEX('%[^0-9A-Za-z]%',KEY_CUSTOMER_szCustomerID) = 0
    )C
    on pos.szBarcodeComplete = c.szBarcodeComplete
    where H.szTaType in ('SA', 'RT')
    and s.country_code = 'CN'
) t
group by 
    barcode,
    store_code,
    member_card,
    member_card_grade,
    payment_time,
	payment_workstation,
    item_sku_code,
    sys_create_time
;
END
GO
