/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sensor_PDP_Performance_Bak_20221201]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sensor_PDP_Performance_Bak_20221201] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-22       wubin          update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2022-11-09       wangzhichun    update PLATFORM_TYPE & PAGE_ID
-- 2022-09-22       wubin          update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2022-11-09       wangzhichun    update PLATFORM_TYPE
-- 2022-11-17       houshuangqiang add field level1_id,level2_id,level3_id & level1_name,level2_name,level3_name
-- ========================================================================================
delete from DW_Sensor.RPT_Sensor_PDP_Performance where dt = @dt;
with sales_op as
(
    select
        vb.product_id as product_id,
        vb.channel_id as channel_id,
        vb.place_date as place_date,
        count(distinct sales_order_number) as orders,
        round(sum(vb.item_apportion_amount),2) as apportion_amount,
        sum(vb.item_quantity) as item_quantity,
        count(distinct vb.member_id) as users_number
    from
    (
        select
            sales_order_number,
            item_product_id as product_id,
            case
                when channel_cd in ('APP','APP(ANDROID)','APP(IOS)') then 'APP'
                when channel_cd in ('ANNYMINIPROGRAM','BENEFITMINIPROGRAM','MINIPROGRAM') then 'MNP'
                when channel_cd = 'WCS' then 'PC'
                when channel_cd = 'WECHAT' then 'MOBILE'
            else upper(channel_cd)
            end as channel_id,
            place_date,
            member_id,
            item_apportion_amount,
            item_quantity
        from
            DW_OMS.RPT_Sales_Order_VB_Level
        where
            is_placed_flag = 1
        and store_cd = 'S001'
        and place_date = @dt
        and channel_cd in ('APP','APP(ANDROID)','APP(IOS)','MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','MOBILE','PC','WCS','WECHAT')
    ) vb
    group by
        vb.product_id,
        vb.channel_id,
        vb.place_date
)

insert into DW_Sensor.RPT_Sensor_PDP_Performance
select
    cast(a.dt as varchar(7)) as statics_month,
    a.dt as DATE,
    a.op_code,
    dsm.product_name_cn,
    dsm.brand_name_en,
    dsm.category,
    dsm.brand_type,
	dsm.category1_level1_id,
    dsm.category1_level1_name,
    dsm.category1_level2_id,
    dsm.category1_level2_name,
    dsm.category1_level3_id,
    dsm.category1_level3_name,
    a.platform_type,
    a.pv,
    a.uv,
    coalesce(so.orders,0),
    coalesce(so.apportion_amount,0) as apportion_amount,
    coalesce(so.item_quantity,0) as item_quantity,
    coalesce(so.users_number,0) as users_number,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        count(1) as pv,
        count(distinct user_id) as uv,
        case
            when upper(platform_type)='MINIPROGRAM' then 'MNP'
            when upper(platform_type) = 'WEB' then 'PC'
            else upper(platform_type) end as platform_type,
        product_id as op_code,
        dt
    from
        DW_Sensor.DWS_Product_Detail_Page_View
    where
        dt=@dt
    group by
        platform_type,
        product_id,
        dt
) a
left join
(
    select
        dsm.product_id as product_id,
        coalesce(dsm.product_name_cn,'NO DETAIL') as product_name_cn,
        coalesce(br.brand_rename,dsm.brand_name,'NO DETAIL') as brand_name_en,
        coalesce(dsm.category,'NO DETAIL') as category,
        coalesce(dsm.brand_type,'NO DETAIL') as brand_type,
		dsm.category1_level1_id,
        dsm.category1_level1_name,
        dsm.category1_level2_id,
        dsm.category1_level2_name,
        dsm.category1_level3_id,
        dsm.category1_level3_name
    from
    (
        select
            a.product_id,
            a.product_name_cn,
            a.brand_name,
            a.category,
            a.brand_type,
            a.category1_level1_id,
            a.category1_level1_name,
            a.category1_level2_id,
            a.category1_level2_name,
            a.category1_level3_id,
            a.category1_level3_name
        from
        (
            select
                    eb_product_id as product_id,
                    eb_product_name_cn as product_name_cn,
                    eb_brand_name as brand_name,
                    eb_category as category,
                    eb_brand_type as brand_type,
                    eb_level1_id as category1_level1_id,
                    eb_level1_name as category1_level1_name,
                    eb_level2_id as category1_level2_id,
                    eb_level2_name as category1_level2_name,
                    eb_level3_id as category1_level3_id,
                    eb_level3_name as category1_level3_name,
                    row_number() over(partition by eb_product_id order by eb_category desc) as rn
            from    DWD.DIM_SKU_Info
        ) a
        where   a.rn=1
    ) dsm
    left join
        DW_Product.DIM_Brand_Rename br
    on
        dsm.brand_name = br.brand_name
 ) dsm
on
    dsm.product_id = a.op_code
left join
    sales_op so
on
    a.op_code = so.product_id
and
    a.platform_type = so.channel_id
END
GO
