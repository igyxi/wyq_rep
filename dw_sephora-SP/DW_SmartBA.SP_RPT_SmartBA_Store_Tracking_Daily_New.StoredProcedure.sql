/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_SmartBA_Store_Tracking_Daily_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_SmartBA_Store_Tracking_Daily_New] @dt [varchar](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       mac             delete 'COLLATE Chinese_PRC_CS_AI_WS'
-- 2023-04-23       wangzhichun        change STG_SmartBA to ODS_SmartBA
-- ========================================================================================
delete from [DW_SmartBA].[RPT_SmartBA_Store_Tracking_Daily_New] where dt = @dt;
insert into [DW_SmartBA].[RPT_SmartBA_Store_Tracking_Daily_New]
select
    substring(@dt,1,7) as statistics_month,
    a.store_code,
    a.vaild_customers,
    (a.vaild_customers - isnull(c.vaild_customers,0)) as increased_vaild_customers,
    d.mp_bundle_target,
    cast(((b.traffic*1.0) * d.mp_bundle_target * 0.25) as int) as target_customers,
    b.traffic,
    case when b.traffic*d.mp_bundle_target =  0 then null
    else (a.vaild_customers - isnull(c.vaild_customers,0))*1.0/(b.traffic*d.mp_bundle_target) end as increased_vaild_customers_ratio,
    case when b.traffic*d.mp_bundle_target =  0 then 0
    when (a.vaild_customers - c.vaild_customers) >=0.25 then 1 else 0 end as meet_target,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select 
        count(distinct a.unionid) as vaild_customers,
        a.store_code
    from
    (
        select distinct
            unionid,
            store_code,
            format(join_time,'yyyy-MM') as join_month
        from
            test.T_WXChat_Sale
        where 
            dt = @dt
        and 
            chat_type = 2
        and 
            store_code is not null  
    ) a
    inner join 
    (
        select distinct unionid,format(bindingtime,'yyyy-MM') as binding_month
        from 
            DW_SmartBA.DWS_BA_Customer_REL
        where
            status = 0
    )b
    on 
        a.unionid = b.unionid
    and 
        a.join_month = b.binding_month
    group by 
        a.store_code
)a
left join 
(
    select 
        sum(Visitors) as traffic,
        Store_Code  as store_code
    from 
        DW_Traffic.Fact_Traffic_ByHour 
    where 
        cast(cast(Date_Key as varchar(10)) as date) between DATEADD(mm, DATEDIFF(mm,0,@dt), 0) and dateadd(mm,datediff(mm,0,@dt)+1,0)-1
    and
        currency_name = 'CNY'
    group by Store_Code
)b
on a.store_code = b.store_code
left join
(
    select 
        statistics_month,
        store_code,
        vaild_customers
    from
        DW_SmartBA.RPT_SmartBA_Store_Tracking_Daily
    where 
        dt = EOMONTH(@dt, -1)
)c
on a.store_code = c.store_code
left join
(
    select
        store_code  as store_code,
        --[MP_Bundle_Target%] as mp_bundle_target
        cast([smart_ba_target] as decimal(10,3)) as mp_bundle_target

    from
        [MANUAL_Retail].[CN_MP_Bundle_Target_By_Store]
    where
        cast(month as date) = cast(DATEADD(mm, DATEDIFF(mm,0,@dt), 0) as date)
)d
on a.store_code = d.store_code
;
end
GO
