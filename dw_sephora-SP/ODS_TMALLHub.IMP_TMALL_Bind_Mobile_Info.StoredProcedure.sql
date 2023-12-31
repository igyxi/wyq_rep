/****** Object:  StoredProcedure [ODS_TMALLHub].[IMP_TMALL_Bind_Mobile_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TMALLHub].[IMP_TMALL_Bind_Mobile_Info] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_TMALLHub.TMALL_Bind_Mobile_Info where dt = @dt;
insert into ODS_TMALLHub.TMALL_Bind_Mobile_Info
select 
    a.id,
	customer_id,
	channel,
	mobile,
	bind_time,
	user_id,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
	ouid,
	is_copy,
    @dt as dt
from 
(
    select * from ODS_TMALLHub.TMALL_Bind_Mobile_Info where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_TMALLHub.WRK_TMALL_Bind_Mobile_Info
) b
on a.id = b.id
where b.id is null
union all
select 
    id,
	customer_id,
	channel,
	convert(varchar, HASHBYTES('MD5',mobile),2) as mobile,
	bind_time,
	user_id,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
	ouid,
	is_copy,
    @dt as dt
from 
    ODS_TMALLHub.WRK_TMALL_Bind_Mobile_Info;
delete from ODS_TMALLHub.TMALL_Bind_Mobile_Info where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
truncate table ODS_TMALLHub.WRK_TMALL_Bind_Mobile_Info;
END



GO
