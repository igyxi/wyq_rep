/****** Object:  StoredProcedure [TEMP].[SP_DWS_POS_Return_Order_Bak20220825]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_POS_Return_Order_Bak20220825] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-09       tali        Initial Version
-- ========================================================================================
truncate table DW_POS.DWS_POS_Return_Order
insert into DW_POS.DWS_POS_Return_Order
select
    a.szBarcodeComplete as refund_no,
    a.Hdr_lTaCreatedRetailStoreID as store_code,
    -- CreateTime as refund_time,
    b.szBarcodeComplete as sales_order_number,
    a.KEY_CUSTOMER_szCustomerID as member_card,
    a.ARTICLE_szDesc as item_sku_name,
    a.ARTICLE_szPOSItemID as item_sku_code,
    isnull(abs(try_cast(a.dTaQty as int)),0) as item_quantity,
    isnull(abs(try_cast(a.dTaTotal as decimal)),0) as item_total_amount,
    abs(try_cast(a.dTaTotal as decimal) + isnull(try_cast(a.dTaDiscount as float), 0)) as item_apportion_amount,
    ISNULL(try_cast(a.dTaDiscount as decimal),0) as item_discount_amount,
    -- CreateTime as create_time,
    current_timestamp as insert_timestamp
from 
(
    select
        RET.szBarcodeComplete,
        ret.Hdr_lTaCreatedRetailStoreID,
        max(ret.ARTICLE_szDesc) as ARTICLE_szDesc,
        parsename(replace(parsename(replace(parsename(replace(ret.szOrgFileName,'\2','.2'),2),'\','.'),1),'_','.'),3) as Hdr_lTaCreatedWorkstationNmbr,
        ret.ARTICLE_szPOSItemID,
        -- ret.ARTICLE_szDesc1,
        sum(cast(ret.dTaQty as int)) as dTaQty,
        sum(cast(ret.dTaTotal as decimal)) as dTaTotal,
        sum(cast(ret.dTaDiscount as decimal)) as dTaDiscount,
        -- ret.lTadiscountflag,
        ret.batchno,
        b.szTaType,
        ret.lOrgTaNmbr,
        ret.lOrgRetailStoreID,
        ret.lOrgWorkstationNmbr,
        ret.szOrgDate,
        -- ret.CreateTime,
        C.KEY_CUSTOMER_szCustomerID
    from  
    (
        select distinct 
            szBarcodeComplete,
            Hdr_lTaCreatedRetailStoreID, 
            ARTICLE_szDesc, 
            szOrgFileName, 
            ARTICLE_szPOSItemID, 
            -- ARTICLE_szDesc1,  
            dTaQty,
            dTaTotal,
            dTaDiscount,
            -- lTadiscountflag,
            batchno,
            lOrgTaNmbr,
            lOrgRetailStoreID,
            lOrgWorkstationNmbr,
            szOrgDate
            -- CreateTime
        from 
            [ODS_POS].[TLOG_ART_RETURN]
    ) RET
    join  
    (
        select distinct szBarcodeComplete, szTaType  from [ODS_POS].[TLOG_HEADER] 
    )b 
    on ret.szBarcodeComplete=b.szBarcodeComplete
    left join 
    (
        select distinct szBarcodeComplete, KEY_CUSTOMER_szCustomerID from [ODS_POS].TLOG_CUSTOMER 
    )C
    on ret.szBarcodeComplete = c.szBarcodeComplete
    where  
        b.szTaType in ('SA','RT')
    group by
        RET.szBarcodeComplete,
        ret.Hdr_lTaCreatedRetailStoreID,
        parsename(replace(parsename(replace(parsename(replace(ret.szOrgFileName,'\2','.2'),2),'\','.'),1),'_','.'),3),
        ret.ARTICLE_szPOSItemID,
        ret.batchno,
        b.szTaType,
        ret.lOrgTaNmbr,
        ret.lOrgRetailStoreID,
        ret.lOrgWorkstationNmbr,
        ret.szOrgDate,
        C.KEY_CUSTOMER_szCustomerID
    -- and ret.CreateTime>='2022-01-01'
) a
left join 
(
    select distinct
        h.szBarcodeComplete,
        h.Hdr_lTaCreatedTaNmbr,
        h.Hdr_lTaCreatedRetailStoreID,
        h.Hdr_lTaCreatedWorkstationNmbr,
        h.szDate
    from  
        [ODS_POS].[TLOG_HEADER] h
    -- join
    --     [ODS_POS].[TLOG_ART_SALE] s
    -- on h.szBarcodeComplete = s.szBarcodeComplete
    where 
        h.szTaType in ('SA','RT')
) b 
on 
    a.lOrgTaNmbr = b.Hdr_lTaCreatedTaNmbr
and a.lOrgWorkstationNmbr = b.Hdr_lTaCreatedWorkstationNmbr
and a.szOrgDate = b.szDate
and a.lOrgRetailStoreID = b.Hdr_lTaCreatedRetailStoreID
END
GO
