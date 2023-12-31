/****** Object:  StoredProcedure [TEST].[sp_smartba_Nonsmartba_uv]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_smartba_Nonsmartba_uv] @dt [NVARCHAR](10) AS
    while @dt<'2023-06-20'
    BEGIN
        insert into TEST.smartba_nonsmartba_uv
        select 
            a.user_id,
            a.vip_card,
            a.distinct_id as unionid,
            dt,
            max(case
                when dt<'2022-10-01' AND CHARINDEX('ba=',ss_url_query)>0 then 1
                when dt>='2022-10-01' AND baaccount IS NOT NULL AND storecode IS NOT NULL then 1
                else 0
            end) as samrtba_uv,
            max(case when event='$MPViewScreen' then 1 else 0 end) as mnp_nonsmartba_uv,
            max(case when event='$APPViewScreen' then 1 else 0 end) as app_uv
        from [STG_Sensor].[Events] a 
        where dt = @dt
            and event in('$AppViewScreen','$MPViewScreen')
            and platform_type in('Mini Program','MiniProgram','app','APP')
        --and vip_card is not null
        group by a.user_id,
            a.vip_card,
            a.distinct_id,
            dt

        SELECT @dt
    
        set @dt=convert(nvarchar(10),dateadd(day,1,@dt),120)
    END


GO
