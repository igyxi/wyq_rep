/****** Object:  StoredProcedure [TEST].[sp_visit_kiehls_page_20220808]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_kiehls_page_20220808] @days [int] AS
begin
delete from test.visit_kiehls_page_20220808 where query_days = @days ;
delete from test.search_browse_kiehls where query_days = @days ;
insert into test.search_browse_kiehls
select  p1.user_id
        ,p2.sap_brand_code
        ,p2.sap_brand_name
        ,p2.eb_sku_name_cn
        ,p2.eb_product_name_cn
        ,@days as query_days
from
(
    select p.user_id
            ,p.product_id
    from
    (
        select  user_id
                ,try_cast(trim(op_code) as int) product_id
        from    STG_Sensor.Events
        where   banner_belong_area = 'searchview'
        and     event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')
        and     [date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近@days天
        and     try_cast(trim(op_code) as int) <> '0'
        group   by user_id,try_cast(trim(op_code) as int)
        union   all
        select  user_id
                ,try_cast(trim(op_code) as int) product_id
        from    STG_Sensor.Events
        where   event = 'viewCommodityDetail'
        and     [date] between convert(date, dateadd(hour,8,getdate()) -  @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近@days天
        and     try_cast(trim(op_code) as int) <> '0'
        group   by user_id,try_cast(trim(op_code) as int)
    ) p
    group   by p.user_id,p.product_id
) p1
inner   join
(
    select  eb_product_id as product_id
            ,sap_brand_code
            ,sap_brand_name
            ,eb_sku_name_cn
            ,eb_product_name_cn
    from    dwd.dim_sku_info
    where   lower(eb_segment) in ('cream','toner')
    or      lower(sap_brand_name) = 'kiehls'
) p2
on  p1.product_id = p2.product_id
group   by p1.user_id,p2.sap_brand_code,p2.sap_brand_name,p2.eb_sku_name_cn,p2.eb_product_name_cn
;
-- 结果
insert  into  test.visit_kiehls_page_20220808
select  p1.user_id
        ,p2.sephora_user_id
		,p3.card_no as member_card
        ,p1.sap_brand_code
        ,p1.sap_brand_name
        ,p1.eb_sku_name_cn
        ,p1.eb_product_name_cn
        ,@days as query_days
        ,current_timestamp insert_time
from    test.search_browse_kiehls p1
left    join
(
    select * from DA_Tagging.id_mapping where invalid_date='9999-12-31'
) p2
on      cast(p1.user_id as nvarchar) = p2.sensor_id -- 为了取丝芙兰user_id
left    join DW_User.DWS_User_Info p3
on      p2.sephora_user_id = p3.user_id
where   p1.query_days = @days
and     p3.card_level <> 'PINK'
group 	by p1.user_id,p2.sephora_user_id,p3.card_no,p1.sap_brand_code,p1.sap_brand_name,p1.eb_sku_name_cn,p1.eb_product_name_cn
-- in ('BLACK','GOLD','WHITE')
;
end
GO
