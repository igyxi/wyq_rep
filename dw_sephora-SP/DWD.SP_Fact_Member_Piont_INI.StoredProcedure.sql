/****** Object:  StoredProcedure [DWD].[SP_Fact_Member_Piont_INI]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Member_Piont_INI] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-25       Tali           Initial Version
-- ========================================================================================

truncate table DWD.Fact_Member_Piont_New
insert into DWD.Fact_Member_Piont_New
select
    o.operation_id,
    o.operation_type,
    b.points_type_code,
    b.points_type_desc,
    b.points_type_name,
    b.points_sign,
    o.points,
    o.used_points,
    o.expired_points,
    o.remain_points,
    o.reserved_points,
    o.returned_points,
    o.account_balance,
    o.total_points,
    o.creation_date,
    o.expiration_date,
    o.credit_date,
    m.member_card,
    CASE WHEN o.external_id2 IS NOT NULL THEN '-1' WHEN o.external_id2 IS NULL AND o.animation_id IS NULL THEN '-2' ELSE c.campaign_code END as campaign_code,
    o.animation_id,
    o.place_id,
    o.external_transaction_id,
    o.external_transaction_detail_id,
    o.create_time,
    o.update_time,
    'CRM',
    CURRENT_TIMESTAMP
from
    ODS_CRM.operation o
left join
    ODS_CRM.points_type b
on o.points_type_id = b.points_type_id
LEFT JOIN 
    ODS_CRM.animation a ON a.animation_id = o.animation_id
LEFT JOIN 
    ODS_CRM.campaign c ON c.campaign_id = a.campaign_id
-- LEFT JOIN 
--     ODS_CRM.campaign_points_type_rel ptr ON ptr.campaign_id = a.campaign_id
-- LEFT JOIN 
--     ODS_CRM.campaign_points_type pt ON pt.campaign_points_type_id = ptr.campaign_points_type_id
left join 
    ODS_CRM.deleted_obj_record d
on o.operation_id = d.obj_id
and d.from_table_name = 'operation'
left join
    DWD.DIM_Member_Info m
on o.account_id = m.member_id
WHERE d.obj_id is null
end
GO
