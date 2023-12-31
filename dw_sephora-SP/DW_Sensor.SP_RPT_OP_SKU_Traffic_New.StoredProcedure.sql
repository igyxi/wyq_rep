/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_OP_SKU_Traffic_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_OP_SKU_Traffic_New] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       eddie.zhang    Initial Version
-- 2022-09-29       wangzhichun    update sku
-- 2023-03-02       houshuangqiang delete  STG_Product.PROD_SKU logic
-- ========================================================================================
delete from DW_Sensor.RPT_OP_SKU_Traffic_New where dt=@dt;
insert into DW_Sensor.RPT_OP_SKU_Traffic_New
select
    a.statistic_date,
    a.platform_type as channel_cd,
    a.product_id,
    a.sku_code,
    a.eb_sku_name,
    case when a.sku_code is null then null else 'Click_on_Sku' end as click_flag,
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
        sp.sku_code,
        sp.eb_sku_name,
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
            dt=@dt
    ) t
    left join
        [DWD].[DIM_SKU_Info] sp
    on
        t.sku_id = sp.eb_sku_id
    and
        t.product_id = sp.eb_product_id
    group by
        t.statistic_date,
        t.platform_type,
        t.product_id,
        sp.sku_code,
        sp.eb_sku_name
    union all
    select
        t.statistic_date,
        'total' as platform_type,
        t.product_id,
        sp.sku_code,
        sp.eb_sku_name,
        count(1) as pv,
        count(distinct t.user_id) as uv
    from
    (
        select
            p.dt as statistic_date,
            p.product_id,
            p.sku_id,
            p.user_id
        from
            [DW_Sensor].[DWS_Product_Detail_Page_View] p
        where
            dt = @dt
    ) t
    left join
        [DWD].[DIM_SKU_Info] sp
    on
        t.sku_id = sp.eb_sku_id
    and
        t.product_id = sp.eb_product_id
    group by
        t.statistic_date,
        t.product_id,
        sp.sku_code,
        sp.eb_sku_name
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
