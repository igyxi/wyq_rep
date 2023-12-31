/****** Object:  StoredProcedure [TEMP].[SP_Fact_Member_Points_Bak20230404]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Member_Points_Bak20230404] @dt [varchar](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-25       Tali           Initial Version
-- 2022-06-09       tali           change to Fact_Member_Points
-- ========================================================================================

DECLARE @ts bigint = null;
select 
    -- get max timestamp of the day before 
    @ts = max_timestamp 
from 
(
    select  *, row_number() over(order by last_update_time desc) rownum
    from [Management].[Table_Last_Update_Logging] 
    where CONCAT([schema],'.',[table]) = 'ODS_CRM.OPERATION' 
    and last_update_time between @dt and DATEADD(day, 1, @dt)
) t
where rownum = 1;


delete from DWD.Fact_Member_Points where operation_id in (select operation_id from  ODS_CRM.operation where [timestamp] > @ts);

insert into DWD.Fact_Member_Points
select
    o.operation_id,
    m.member_card,
    s.store_code,
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
    CASE 
        WHEN o.external_id2 IS NOT NULL THEN '-1' 
        WHEN o.external_id2 IS NULL AND o.animation_id IS NULL THEN '-2' 
        ELSE c.campaign_code 
    END as campaign_code,
    -- o.animation_id,
    
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
left join
    DW_CRM.DIM_Store s on s.store_id = o.place_id 
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
WHERE o.timestamp > @ts
and d.obj_id is null
end

GO
