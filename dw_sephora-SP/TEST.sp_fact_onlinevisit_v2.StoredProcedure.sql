/****** Object:  StoredProcedure [TEST].[sp_fact_onlinevisit_v2]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_fact_onlinevisit_v2] @start_month [date],@end_month [date] AS
BEGIN

    declare @end date
    set @end=dateadd(m,1,@start_month)
    while @start_month<@end_month
begin
        delete from TEST.Fact_OnlineVisit_v2 where Month=convert(nvarchar(7),@start_month,120)
        insert INTO TEST.Fact_OnlineVisit_v2
        SELECT [user_id]
      , distinct_id
	  , [vip_card]
      , convert(nvarchar(7),[date],120) as Month
	  , [event]
      , [platform_type]
	  , [system_type]
	  , count(1) as frequency
        FROM [STG_Sensor].[Events]
        Where date>=@start_month and date<@end
        group by [user_id]
      ,distinct_id
	  ,[vip_card]
      ,convert(nvarchar(7),[date],120) 
	  ,[event]
      ,[platform_type]
	  ,[system_type]
        set @start_month=dateadd(m,1,@start_month)
        set @end=dateadd(m,1,@start_month)
    end
End
GO
