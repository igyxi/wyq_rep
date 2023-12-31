/****** Object:  StoredProcedure [TEST].[sp_smartba_Nonsmartba_uv_0526]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_smartba_Nonsmartba_uv_0526] @dt [VARCHAR](10) AS
BeGIN
    declare @from_dt [VARCHAR](10)
    select @from_dt = max(dt) from TEST.smartba_nonsmartba_uv
END
BEGIN
    delete from TEST.smartba_nonsmartba_uv where dt > @from_dt and dt< @dt
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
    where dt > @from_dt and dt < @dt
        and event in('$AppViewScreen','$MPViewScreen')
        and platform_type in('Mini Program','MiniProgram','app','APP')
    --and vip_card is not null
    group by a.user_id,
        a.vip_card,
        a.distinct_id,
        dt
END


GO
