/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_PDP_Page_Type_Traffic]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_PDP_Page_Type_Traffic] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-31       guanzewei      Initial 
-- 2021-12-31       guanzewei      update 
-- 2022-09-22       wubin          update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- ========================================================================================
delete from DW_Sensor.RPT_Sensor_PDP_Page_Type_Traffic where dt = @dt;
insert into DW_Sensor.RPT_Sensor_PDP_Page_Type_Traffic
select 
    cast(a.dt as varchar(7)),
    a.dt,
    a.op_code,
    dsm.product_name_cn,
    dsm.brand_name_en,
    dsm.category,
    dsm.brand_type,
    a.platform_type,
    a.previous_page_type,
    a.pv,
    a.uv,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select 
        count(1) as pv,
        count(distinct user_id) as uv,
        platform_type,
        case 
            when previous_page_type_new in('other','others') then 'others'
            when previous_page_type_new is not null and previous_page_type_new not in('other','others') then previous_page_type_new
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/product%',referrer) between 10 and 13 then 'Product-detail-page' 
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/[category|brand|hot|search]%',referrer) between 10 and 13 then 'List-page' 
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/',referrer) between 10 and 13 then 'home' 
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/[beautyCommunity|login]%',referrer) between 10 and 13 then 'Function-page'
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/[campaign|weeklyspecials]%',referrer) between 10 and 13 then 'Campaign-page' 
            when referrer is not null and previous_page_type_new is null then 'External'
        else null
        end as previous_page_type,
        op_code,
        dt
    from
    (    
        select 
            user_id,
            platform_type,
            previous_page_type_new,
            referrer,
            product_id as op_code,
            dt
        from 
            DW_Sensor.DWS_Product_Detail_Page_View
        where
            dt=@dt
    )t
    group by 
        platform_type,
        -- case 
        --     when platform_type in ('app','APP') then 'APP'
        --     when platform_type = 'mobile' then 'Mobile'
        --     when platform_type = 'web' then 'Web'
        --     when platform_type = 'wechat' then 'Mobile'
        --     when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
        -- end,
        case 
            when previous_page_type_new in('other','others') then 'others'
            when previous_page_type_new is not null and previous_page_type_new not in('other','others') then previous_page_type_new
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/product%',referrer) between 10 and 13 then 'Product-detail-page' 
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/[category|brand|hot|search]%',referrer) between 10 and 13 then 'List-page' 
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/',referrer) between 10 and 13 then 'home' 
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/[beautyCommunity|login]%',referrer) between 10 and 13 then 'Function-page'
            when previous_page_type_new is null and CHARINDEX('http',referrer) = 1 and PATINDEX('%sephora.cn/[campaign|weeklyspecials]%',referrer) between 10 and 13 then 'Campaign-page' 
            when referrer is not null and previous_page_type_new is null then 'External'
            else null
        end,
        op_code,
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
;
end

GO
