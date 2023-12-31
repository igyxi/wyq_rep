/****** Object:  StoredProcedure [DW_SmartBA].[SP_DWS_BA_Customer_REL]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_DWS_BA_Customer_REL] @dt [varchar](10) AS
begin
delete from [DW_SmartBA].[DWS_BA_Customer_REL] where dt = @dt;
insert into [DW_SmartBA].[DWS_BA_Customer_REL]
select 
    a.id,
    b.shop_info_code as store_code, 
    a.staff_no as employee_code, 
    a.unionid as union_id, 
    a.status,
    null as region,
    null as district,
    null as city,
    a.bind_time as binding_time,
    @dt as dt,
    current_timestamp as insert_timestamp
from  
    STG_SmartBA.Customer_Staff_REL a
left join 
    STG_SmartBA.Staff_Info as b 
on a.staff_no = b.userid
where 
    cast(a.bind_time as date) = @dt
and a.external_user_id like 'wm%' 
and b.shop_info_code is not null 
and a.staff_no is not null 
and a.unionid is not null
;
end

GO
