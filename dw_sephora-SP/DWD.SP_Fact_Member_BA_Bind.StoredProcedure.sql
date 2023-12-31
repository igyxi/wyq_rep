/****** Object:  StoredProcedure [DWD].[SP_Fact_Member_BA_Bind]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Member_BA_Bind] @dt [NVARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       wangzhichun        Initial Version
-- 2022-01-10       wangzhichun        delete column
-- 2022-01-12       tali           update delete logic  
-- 2022-12-15       tali           change the table DWD.DIM_SmartBA_Info_DF 
-- ========================================================================================
truncate table DWD.Fact_Member_BA_Bind;
insert into DWD.Fact_Member_BA_Bind
select 
    a.id,
    b.store_code as store_code, 
    a.unionid as unionid, 
    a.staff_no as ba_staff_no, 
    a.bind_time as bind_time,
    a.status,
    a.created_at as create_time,
    'OMS' as source,
    current_timestamp as insert_timestamp
from
    (
    select 
        id,
        unionid,
        staff_no,
        bind_time,
        status,
        created_at,
        external_user_id
    from
        ODS_SmartBA.Customer_Staff_REL
    union all 
    select 
        id,
        unionid,
        staff_no,
        bind_time,
        status,
        created_at,
        external_user_id
    from
        ods_smartba.Customer_Staff_REL2021
        where 
        created_at<'2021-12-09'
     ) a
left join 
    DWD.DIM_SmartBA_Info_DF b 
on a.staff_no = b.staff_no
and b.dt = @dt
where 
    a.external_user_id like 'wm%' 
and b.store_code is not null 
and a.staff_no is not null 
and a.unionid is not null
;
END
GO
