/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sensor_PDP_Performance_Bak_20221109]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sensor_PDP_Performance_Bak_20221109] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-22       wubin          update 更改DWS_SKU_Profile表为DIM_SKU_Info
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
                when channel_cd in ('ANNYMINIPROGRAM','BENEFITMINIPROGRAM','MINIPROGRAM') then 'MiniProgram'
                when channel_cd = 'MOBILE' then 'Mobile'
                when channel_cd = 'PC' then 'Web'
                when channel_cd = 'WCS' then 'Web'
                when channel_cd = 'WECHAT' then 'Mobile'
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
    cast(a.dt as varchar(7)),
    a.dt,
    a.op_code,
    dsm.product_name_cn,
    dsm.brand_name_en,
    dsm.category,
    dsm.brand_type,
    a.platform_type,
    a.pv,
    a.uv,
    coalesce(so.orders,0),
    coalesce(so.apportion_amount,0),
    coalesce(so.item_quantity,0),
    coalesce(so.users_number,0),
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    --2021-12-31 之前逻辑
    -- select 
    --     count(1) as pv,
    --     count(distinct user_id) as uv,
    --     case 
    --         when platform_type in ('app','APP') then 'APP'
    --         when platform_type = 'mobile' then 'Mobile'
    --         when platform_type = 'web' then 'Web'
    --         when platform_type = 'wechat' then 'Mobile'
    --         when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
    --     end as platform_type,
    --     op_code,
    --     dt
    -- from
    -- (    
    --     select 
    --         user_id,
    --         platform_type,
    --         previous_page_type_new,
    --         referrer,
    --         op_code,
    --         dt
    --     from 
    --         STG_Sensor.Events with (nolock)
    --     where 
    --         dt= @dt
    --         and event='viewCommodityDetail'
    --         and op_code <> '0'
	--     	and PATINDEX('%[^0-9]%',op_code) = 0
    --         and platform_type in('mobile','web','wechat','MiniProgram','Mini Program','app','APP')
    -- )t
    -- group by 
    --     case 
    --         when platform_type in ('app','APP') then 'APP'
    --         when platform_type = 'mobile' then 'Mobile'
    --         when platform_type = 'web' then 'Web'
    --         when platform_type = 'wechat' then 'Mobile'
    --         when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
    --     end,
    --     op_code,
    --     dt
    --2021-12-31 修改
    select 
        count(1) as pv,
        count(distinct user_id) as uv,
        platform_type,
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
        coalesce(dsm.brand_type,'NO DETAIL') as brand_type
    from
    (
        select 
            * 
        from(   -- 2022-09-22 之前逻辑
                -- select 
                --     cast(product_id as varchar(8000)) as product_id,
                --     product_name_cn,
                --     brand_name,
                --     category,
                --     brand_type,
                --     row_number() over(partition by product_id order by category desc) as rn
                -- from 
                --     DW_Product.DWS_SKU_Profile
                select 
                    EB_product_id as product_id,
                    eb_product_name_cn as product_name_cn,
                    eb_brand_name as brand_name,
                    eb_category as category,
                    eb_brand_type as brand_type,
                    row_number() over(partition by EB_product_id order by eb_category desc) as rn
                from 
                    DWD.DIM_SKU_Info
             )a 
        where 
            a.rn=1 
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
;
end
GO
