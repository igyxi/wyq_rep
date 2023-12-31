/****** Object:  StoredProcedure [RPT].[SP_RPT_SAP_Transaction]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_SAP_Transaction] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-15       lizeyuan           Initial Version
-- ===================================================================================
truncate table  [RPT].[RPT_SAP_Transaction] ;
insert into [RPT].[RPT_SAP_Transaction]
select
    cast(a.payment_time as date) time_id
    ,DATEPART(HOUR, a.payment_time) hour_id
    ,'CN' country
    ,a.store_code
    ,a.sap_till_number
    ,a.sap_transaction_number
    ,a.member_card
    ,current_timestamp as insert_timestamp
from
    [DWD].[Fact_Sales_Order] a
end
GO
