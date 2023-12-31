/****** Object:  StoredProcedure [TEST].[sp_fact_onlinevisit_v2_0526]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_fact_onlinevisit_v2_0526] @dt [date] AS
BEGIN
    declare @from_week_dt date,@from_week_dt_month [VARCHAR](10),@from_Month_FirstDay date,@dt_Month_FirstDay date,@dt_month [VARCHAR](10),@Month_FirstDay [VARCHAR](10);
    set @from_week_dt = dateadd(d,-7,@dt)
    set @from_week_dt_month = substring(convert(varchar(100),@from_week_dt,23),1,7)
    set @from_Month_FirstDay = dateadd(day,-day(@from_week_dt)+1,@from_week_dt)
    set @dt_Month_FirstDay =  dateadd(day,-day(@dt)+1,@dt)
    set @dt_month =  substring(convert(varchar(100),@dt,23),1,7)   

	set @Month_FirstDay = case when @from_week_dt_month = @dt_month then   @dt_Month_FirstDay else  @from_Month_FirstDay  
end
    delete from TEST.Fact_OnlineVisit_v2 where Month=@dt_month or Month = @from_week_dt_month
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
    Where date >= @Month_FirstDay and date < @dt
    group by [user_id]
  ,distinct_id
  ,[vip_card]
  ,convert(nvarchar(7),[date],120) 
  ,[event]
  ,[platform_type]
  ,[system_type]
End
GO
