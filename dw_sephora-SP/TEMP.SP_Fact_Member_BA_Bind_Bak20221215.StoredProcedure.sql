/****** Object:  StoredProcedure [TEMP].[SP_Fact_Member_BA_Bind_Bak20221215]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Member_BA_Bind_Bak20221215] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       wangzhichun        Initial Version
-- 2022-01-10       wangzhichun        delete column
-- 2022-01-12       tali               update delete logic 
-- 2022-01-12       tali               update to full refresh     
-- ========================================================================================
truncate table DWD.Fact_Member_BA_Bind;
insert into DWD.Fact_Member_BA_Bind
select 
    a.id,
    b.shop_info_code as store_code, 
    a.unionid as unionid, 
    a.staff_no as ba_staff_no, 
    a.bind_time as bind_time,
    a.status,
    a.created_at as create_time,
    'OMS' as source,
    current_timestamp as insert_timestamp
from
    STG_SmartBA.Customer_Staff_REL a
join 
    STG_SmartBA.Staff_Info as b 
on a.staff_no = b.userid
where 
    a.external_user_id like 'wm%' 
and b.shop_info_code is not null 
and a.staff_no is not null 
and a.unionid is not null
;
END
GO
