/****** Object:  StoredProcedure [DW_Sensor].[sp_dws_smartba_events]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[sp_dws_smartba_events] @dt [VARCHAR](10) AS
while @dt<'2022-09-15'
BEGIN
insert into DW_sensor.Smartba_Events_log_1
select distinct a.user_id,a.vip_card,dt,time
from  [STG_Sensor].[Events] a 
where  event = '$MPViewScreen'
and CHARINDEX('ba=',ss_url_query)>0 
and dt=@dt
and vip_card is not null
union all
select distinct a.user_id,a.vip_card,dt,time
from  [STG_Sensor].[Events] a 
where  event = '$MPViewScreen'
and CHARINDEX('t=2',ss_url)>0 
and dt=@dt
and vip_card is not null
set @dt=convert(nvarchar(10),dateadd(day,1,@dt),120)
END

GO
