/****** Object:  StoredProcedure [ODS_User].[IMP_User_Device_Status]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_User].[IMP_User_Device_Status] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_User.User_Device_Status where dt = @dt;
insert into ODS_User.User_Device_Status
select 
    a.client_id,
	user_id,
	supplier,
	status,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_User.User_Device_Status where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select client_id from ODS_User.WRK_User_Device_Status
) b
on a.client_id = b.client_id
where b.client_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_User.WRK_User_Device_Status;
delete from ODS_User.User_Device_Status where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
