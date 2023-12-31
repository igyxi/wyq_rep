/****** Object:  StoredProcedure [DWD].[INI_Fact_Member_Piont]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[INI_Fact_Member_Piont] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-25       Tali           Initial Version
-- ========================================================================================
truncate table DWD.Fact_Member_Piont;
insert into DWD.Fact_Member_Piont
select 
    a.operation_id,
    a.operation_type,
    b.points_type_code,
    b.points_type_desc,
    b.points_type_name,
    b.points_sign,
    a.points,
    a.used_points,
    a.expired_points,
    a.remain_points,
    a.reserved_points,
    a.returned_points,
    a.account_balance,
    a.total_points,
    a.creation_date,
    a.expiration_date,
    a.credit_date,
    c.account_number as member_card,
    a.campaign_code,
    a.animation_id,
    a.place_id,
    a.external_transaction_id,
    a.external_transaction_detail_id,
    a.create_time,
    'CRM',
    CURRENT_TIMESTAMP
from
    ODS_CRM.DimOperation a
left join
    ODS_CRM.Points_type b
on a.points_type_id = b.points_type_id
left join
    ODS_CRM.DimAccount c
on a.account_id = c.account_id
end

GO
