/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_VB_Inventory_BAK20230428]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_VB_Inventory_BAK20230428] AS
BEGIN
truncate table DW_OMS.RPT_OMS_VB_Inventory;
insert into DW_OMS.RPT_OMS_VB_Inventory
SELECT
    sku as sku_code,
    soa_qty as soa_quantity,
    jd_qty as jd_quantity,
    tmall_qty as tmall_quantity,
    redbook_qty as redbook_quantity,
    tmall_wei_qty as tmall_wei_quantity,
    douyin_qty as douyin_quantity,
    current_timestamp as insert_timestamp
FROM 
    STG_OMS.OMS_SYNC_Store_INV_Data
;
END
GO
