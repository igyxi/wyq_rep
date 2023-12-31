/****** Object:  StoredProcedure [DW_CRM].[SP_DIM_CRM_Account_SCD]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_CRM].[SP_DIM_CRM_Account_SCD] AS
BEGIN
delete from DW_CRM.DIM_CRM_Account_SCD 
where end_time = '9999-12-31' and account_id in (SELECT distinct account_id FROM DW_CRM.DIM_CRM_Account_SCD_DI);
insert into DW_CRM.DIM_CRM_Account_SCD
SELECT
    a.account_id,
    b.account_number,
    a.account_status,
    a.card_type,
    a.card_type_name,
    a.start_time,
    a.end_time,
    current_timestamp as insert_timestamp
from
    DW_CRM.DIM_CRM_Account_SCD_DI a
left join
    [ODS_CRM].[DimAccount] b
on a.account_id = b.account_id
;
END


GO
