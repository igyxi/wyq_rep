/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_Order_Attribution]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_Order_Attribution] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.RPT_Sensor_Order_Attribution where dt = @dt;
with lastest_utm_attr_sum as
(
    SELECT
        statics_date,
        case when member_new_status = 'NO DETAIL' then null else member_new_status end as member_new_status,
        case when platform_type = 'NO DETAIL' then null else platform_type end as platform_type,
        attribution_type,
        case when ss_utm_source = 'NO DETAIL' then null else ss_utm_source end as ss_utm_source,
        case when ss_utm_medium = 'NO DETAIL' then null else ss_utm_medium end as ss_utm_medium,
        payed_amount,
        payed_order
    from
    (
        select
            place_date as statics_date,
            member_new_status as member_new_status,
            channel_cd as platform_type,
            attribution_type,
            ss_utm_source,
            ss_utm_medium,
            sum(apportion_amount) as payed_amount,
            count(distinct sales_order_number) as payed_order
        from
            DW_Sensor.DWS_Sensor_Order_Latest_UTM_Attribution
        where 
            dt = @dt
        group by
            place_date,
            member_new_status,
            channel_cd,
            attribution_type,
            ss_utm_source,
            ss_utm_medium
    )a
),
utm_attr AS
(
    SELECT
        place_date as statics_date,
        member_new_status as member_new_status,
        channel_cd as platform_type,
        attribution_type as attribution_type,
        ss_utm_source,
        ss_utm_medium,
        sum(apportion_amount) as payed_amount,
        count(distinct sales_order_number) as payed_order
    FROM
        DW_Sensor.DWS_Sensor_Order_UTM_Attribution
    where 
        dt = @dt
    group by 
        place_date,
        member_new_status,
        channel_cd,
        attribution_type,
        ss_utm_source,
        ss_utm_medium
),
utm_attr_sum as
(
    SELECT
        statics_date,
        case when member_new_status = 'NO DETAIL' then null else member_new_status end as member_new_status,
        case when platform_type = 'NO DETAIL' then null else platform_type end as platform_type,
        attribution_type,
        case when ss_utm_source = 'NO DETAIL' then null else ss_utm_source end as ss_utm_source,
        case when ss_utm_medium = 'NO DETAIL' then null else ss_utm_medium end as ss_utm_medium,
        payed_amount,
        payed_order
    from
    (
        select
            statics_date,
            member_new_status,
            platform_type,
            '1D' as attribution_type,
            case when attribution_type = '1D' then ss_utm_source else 'NO DETAIL' end as ss_utm_source,
            case when attribution_type = '1D' then ss_utm_medium else 'NO DETAIL' end as ss_utm_medium,
            sum(payed_amount) as payed_amount,
            sum(payed_order) as payed_order
        from
            utm_attr
        group by 
            statics_date,
            member_new_status,
            platform_type,
            case when attribution_type = '1D' then ss_utm_source else 'NO DETAIL' end,
            case when attribution_type = '1D' then ss_utm_medium else 'NO DETAIL' end
        union all
        select
            statics_date,
            member_new_status,
            platform_type,
            '7D' as attribution_type,
            case when attribution_type in ('1D','7D') then ss_utm_source else 'NO DETAIL' end as ss_utm_source,
            case when attribution_type in ('1D','7D') then ss_utm_medium else 'NO DETAIL' end as ss_utm_medium,
            sum(payed_amount) as payed_amount,
            sum(payed_order) as payed_order
        from
            utm_attr
        group by 
            statics_date,
            member_new_status,
            platform_type,
            case when attribution_type in ('1D','7D') then ss_utm_source else 'NO DETAIL' end,
            case when attribution_type in ('1D','7D') then ss_utm_medium else 'NO DETAIL' end
        union all
        select
            statics_date,
            member_new_status,
            platform_type,
            '14D' as attribution_type,
            case when attribution_type in ('1D','7D','14D') then ss_utm_source else 'NO DETAIL' end as ss_utm_source,
            case when attribution_type in ('1D','7D','14D') then ss_utm_medium else 'NO DETAIL' end as ss_utm_medium,
            sum(payed_amount) as payed_amount,
            sum(payed_order) as payed_order
        from
            utm_attr
        group by 
            statics_date,
            member_new_status,
            platform_type,
            case when attribution_type in ('1D','7D','14D') then ss_utm_source else 'NO DETAIL' end,
            case when attribution_type in ('1D','7D','14D') then ss_utm_medium else 'NO DETAIL' end
        union all
        select
            statics_date,
            member_new_status,
            platform_type,
            '30D' as attribution_type,
            case when attribution_type in ('1D','7D','14D','30D') then ss_utm_source else 'NO DETAIL' end as ss_utm_source,
            case when attribution_type in ('1D','7D','14D','30D') then ss_utm_medium else 'NO DETAIL' end as ss_utm_medium,
            sum(payed_amount) as payed_amount,
            sum(payed_order) as payed_order
        from
            utm_attr
        group by 
            statics_date,
            member_new_status,
            platform_type,
            case when attribution_type in ('1D','7D','14D','30D') then ss_utm_source else 'NO DETAIL' end,
            case when attribution_type in ('1D','7D','14D','30D') then ss_utm_medium else 'NO DETAIL' end
    )b
)


insert into DW_Sensor.RPT_Sensor_Order_Attribution

select utm.statics_date ,
utm.member_new_status,
utm.platform_type,
utm.attribution_type,
utm.ss_utm_source,
case when  utm.ss_utm_medium like '%-recall' or  utm.ss_utm_medium like  '%-recruit' then  REVERSE(SUBSTRING(REVERSE(ss_utm_medium),CHARINDEX('-',REVERSE(ss_utm_medium))+1,100))  else ss_utm_medium end as ss_utm_medium,
utm.payed_amount,
utm.payed_order,
utm.uv,
utm.insert_timestamp,
utm.dt,
case when  utm.ss_utm_medium like '%-recall' or  utm.ss_utm_medium like '%-recruit' then  REVERSE(SUBSTRING(REVERSE(ss_utm_medium),0,CHARINDEX('-',REVERSE(ss_utm_medium))))   else null end as ss_utm_term
from(
select
    coalesce(a.statics_date,b.statics_date) as statics_date,
    coalesce(a.member_new_status,b.member_new_status) as member_new_status,
    coalesce(a.platform_type,b.platform_type) as platform_type,
    coalesce(a.attribution_type,b.attribution_type) as attribution_type,
    coalesce(case when a.ss_utm_source = 'isnull' then null else a.ss_utm_source end,case when b.ss_utm_source = 'isnull' then null else b.ss_utm_source end,null) as ss_utm_source,
    coalesce(case when a.ss_utm_medium = 'isnull' then null else a.ss_utm_medium end,case when b.ss_utm_medium = 'isnull' then null else b.ss_utm_medium end,null) as ss_utm_medium,
    b.payed_amount as payed_amount,
    b.payed_order as payed_order, 
    a.uv as uv,
    current_timestamp as insert_timestamp,
    @dt as dt
from
    (
	    select 
		    a.statics_date,
			b.member_new_status,
			a.platform_type,
			b.attribution_type,
			a.ss_utm_source,
			a.ss_utm_medium,
			a.uv
		from
		    (select * from DW_Sensor.DWS_Sensor_UTM_Traffic where dt = @dt and uv>0)a 
		cross join
		    DW_Sensor.DIM_Sensor_Attribution_Type b
	)a
full join
    (
        select * from lastest_utm_attr_sum where payed_order>0
        union all
        select * from utm_attr_sum where payed_order>0
    )b
on 
    a.platform_type = b.platform_type
and 
    a.ss_utm_source = b.ss_utm_source
and 
    a.ss_utm_medium = b.ss_utm_medium
and 
    a.statics_date = b.statics_date
and
    a.attribution_type = b.attribution_type
and 
    a.member_new_status = b.member_new_status
	) utm
;
END

GO
