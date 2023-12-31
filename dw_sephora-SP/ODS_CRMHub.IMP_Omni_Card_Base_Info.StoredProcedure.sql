/****** Object:  StoredProcedure [ODS_CRMHub].[IMP_Omni_Card_Base_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_CRMHub].[IMP_Omni_Card_Base_Info] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_CRMHub.Omni_Card_Base_Info where dt = @dt;
insert into ODS_CRMHub.Omni_Card_Base_Info
select 
    a.id,
	card_no,
	card_level,
	card_status,
	available_points,
	total_points,
	register_source,
	register_store,
	register_time,
	last_update_time,
    @dt as dt
from 
(
    select * from ODS_CRMHub.Omni_Card_Base_Info where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_CRMHub.WRK_Omni_Card_Base_Info
) b
on a.id = b.id
where b.id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_CRMHub.WRK_Omni_Card_Base_Info;
delete from ODS_CRMHub.Omni_Card_Base_Info where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
