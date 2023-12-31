/****** Object:  StoredProcedure [TEMP].[SP_DWS_Sales_Ticket_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Sales_Ticket_Bak_20230518] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-19       Tali           Initial Version
-- 2022-09-22       Tali           add cogs
-- 2022-11-28       houshuangqiang add item_ex_vat_amount
-- 2022-11-30       Aan            combine_number 加前置0补齐28位
-- ========================================================================================
truncate table DW_SAP.DWS_Sales_Ticket;
insert into DW_SAP.DWS_Sales_Ticket
select
    case when sap.Till_Number in ('0000000997','0000000999','0000000998') then Transaction_Number
        when m.store_code is not null then cast(try_cast(Transaction_Number as bigint) as nvarchar)
        else '66' + CAST(sap.Store_Code AS NVARCHAR)
                    + CAST(RIGHT('000'+till_number,3) AS NVARCHAR)
                    + CAST(RIGHT('000000'+Transaction_Number,7) AS NVARCHAR)
                    + Ticket_Date
                    + Ticket_Hour
    end as combine_number,
    sap.Transaction_Number,
    sap.till_number,
    sap.ticket_date,
    sap.ticket_hour,
    sap.store_code,
    sap.material_code as item_sku_code,
    sap.sap_qty as item_quantity,
    sap.sap_amount as item_amount,
    sap.sap_ex_vat_amount as item_ex_vat_amount,
    sap.cogs as item_cogs,
    case when sap.Till_Number in ('0000000997','0000000999','0000000998') then 'HUB'
        when m.store_code is not null then 'OMS'
        else 'POS'
    end as source,
    current_timestamp as insert_timestamp
from
(
    select
        CASE
            WHEN LEN(ticket_hour) = 3 THEN '0' + CAST(ticket_hour AS NVARCHAR)
            ELSE CAST(ticket_hour AS NVARCHAR)
        END as Ticket_Hour,
        CASE
            WHEN LEN(ticket_hour) = 3 and left(ticket_hour, 1) < '3' then format(dateadd(day,1, cast(Ticket_Date as varchar)), 'yyyyMMdd')
            WHEN len(ticket_hour) = 4 and left(ticket_hour, 2) < '03' then format(dateadd(day,1, cast(Ticket_Date as varchar)), 'yyyyMMdd')
            ELSE CAST(Ticket_Date AS NVARCHAR)
        END as Ticket_Date,
        Material_Code,
        store_code,
        Till_Number,
        Transaction_Number,
        SUM(ISNULL(cast(Quantity as int), 0)) AS SAP_QTY,
        SUM(ISNULL(cast(Sales_VAT as float),0.0)) AS SAP_AMOUNT,
        SUM(ISNULL(cast(Sales_Ex_VAT as float),0.0)) AS SAP_Ex_VAT_AMOUNT,
        SUM(ISNULL(cast(COGS as float), 0.0)) as cogs
    from
        [ODS_SAP].[Sales_Ticket]
    where
        ISNULL(Quantity,0.0)>=0
    group by
        CASE
            WHEN LEN(ticket_hour) = 3 THEN '0' + CAST(ticket_hour AS NVARCHAR)
            ELSE CAST(ticket_hour AS NVARCHAR)
        END,
        CASE
            WHEN LEN(ticket_hour) = 3 and left(ticket_hour, 1) < '3' then format(dateadd(day,1, cast(Ticket_Date as varchar)), 'yyyyMMdd')
            WHEN len(ticket_hour) = 4 and left(ticket_hour, 2) < '03' then format(dateadd(day,1, cast(Ticket_Date as varchar)), 'yyyyMMdd')
            ELSE CAST(Ticket_Date AS NVARCHAR)
        END,
        Material_Code,
        store_code,
        Till_Number,
        Transaction_Number
) sap
left join
    stg_oms.oms_store_mapping m
on sap.store_code = m.store_code
;
END
GO
