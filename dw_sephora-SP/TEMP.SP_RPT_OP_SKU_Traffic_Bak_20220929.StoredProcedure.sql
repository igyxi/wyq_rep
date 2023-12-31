/****** Object:  StoredProcedure [TEMP].[SP_RPT_OP_SKU_Traffic_Bak_20220929]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OP_SKU_Traffic_Bak_20220929] @dt [varchar](10) AS
BEGIN
delete from DW_Sensor.RPT_OP_SKU_Traffic where dt=@dt;
insert into DW_Sensor.RPT_OP_SKU_Traffic
select 
    a.statistic_date,
    a.platform_type as channel_cd,
    a.product_id,
    a.sku_cd,
    a.sku_name,
    case when a.sku_cd is null then null else 'Click_on_Sku' end as click_flag,
    a.pv,
    a.uv,
    ps.score_avg,
    ps.score_cnt,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select 
        t.statistic_date,
        t.platform_type,
        t.product_id,
        sp.sku_cd,
        sp.sku_name,
        count(1) as pv,
        count(distinct t.user_id) as uv
    from
    (
        select 
            dt as statistic_date,
            platform_type,
            product_id,
            sku_id,
            user_id
        from
            [DW_Sensor].[DWS_Product_Detail_Page_View]
        where 
            dt = @dt
    ) t
    left join 
        [DW_Product].[DWS_SKU_Profile] sp
    on 
        t.sku_id = sp.sku_id
    and 
        t.product_id = sp.product_id
    group by 
        t.statistic_date,
        t.platform_type,
        t.product_id,
        sp.sku_cd,
        sp.sku_name
    union all
    select 
        t.statistic_date,
        'total' as platform_type,
        t.product_id,
        sp.sku_cd,
        sp.sku_name,
        count(1) as pv,
        count(distinct t.user_id) as uv
    from
    (
        select 
            dt as statistic_date,
            product_id,
            sku_id,
            user_id
        from
            [DW_Sensor].[DWS_Product_Detail_Page_View]
        where 
            dt = @dt
    ) t
    left join 
        [DW_Product].[DWS_SKU_Profile] sp
    on
        t.sku_id = sp.sku_id
    and 
        t.product_id = sp.product_id
    group by 
        t.statistic_date,
        t.product_id,
        sp.sku_cd,
        sp.sku_name
) a
left join
(
    select 
        product_id,
        avg(score) as score_avg,
        count(score) as score_cnt
    from
        [STG_Product].[PROD_Product_Comment]
    where 
        cast(create_time as date) <= @dt
    and is_disable = 0 
    and score > 0 
    group by 
        product_id
) ps
on a.product_id = ps.product_id
;
end
GO
