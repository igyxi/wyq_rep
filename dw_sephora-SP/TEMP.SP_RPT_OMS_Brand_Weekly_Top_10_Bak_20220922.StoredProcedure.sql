/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Brand_Weekly_Top_10_Bak_20220922]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Brand_Weekly_Top_10_Bak_20220922] @dt [VARCHAR](10) AS 
begin
delete from [DW_OMS].[RPT_OMS_Brand_Weekly_Top_10] where dt = @dt;
insert into [DW_OMS].[RPT_OMS_Brand_Weekly_Top_10]
select top 10
    'total' as brand_tab,
    brand_id,
    brand_name_cn,
    replace(brand_name,'''','') as brand_name,
    amount,
    quantity,
    -- case when brand_name = 'SEPHORA' then 50 else quantity end as quantity,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
(
    select 
        b.brand_id,
        b.brand_name,
        b.brand_name_cn,
        sum(item_amount) as amount,
        sum(item_quantity) as quantity
    from
    (
        select 
            item_sku_cd,
            sum(item_apportion_amount) as item_amount,
            sum(item_quantity) as item_quantity
        from 
            DW_OMS.RPT_Sales_Order_VB_Level
        where 
            is_placed_flag = 1 
        and place_date between dateadd(day,-6,@dt) and @dt
        and store_cd = 'S001'
        group by item_sku_cd
    )a
    left join
        DW_Product.DWS_SKU_Profile b
    on a.item_sku_cd = b.sku_cd
    where b.brand_id is not null
    group by 
        b.brand_id,
        b.brand_name,
        b.brand_name_cn
) t
-- order by case when brand_name = 'SEPHORA' then 999999999999 else amount end desc
order by amount desc;

insert into [DW_OMS].[RPT_OMS_Brand_Weekly_Top_10]
select top 10
    'ex' as brand_tab,
    brand_id,
    brand_name_cn,
    replace(brand_name_en,'''','') as brand_name_en,
    amount,
    quantity,
    -- case when brand_name = 'SEPHORA' then 50 else quantity end as quantity,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
(
    select 
        b.brand_id,
        c.brand_name_en,
        c.brand_name_cn,
        sum(item_amount) as amount,
        sum(item_quantity) as quantity
    from
    (
        select 
            item_sku_cd,
            sum(item_apportion_amount) as item_amount,
            sum(item_quantity) as item_quantity
        from 
            DW_OMS.RPT_Sales_Order_VB_Level
        where 
            is_placed_flag = 1 
        and place_date between dateadd(day,-6,@dt) and @dt
        and store_cd = 'S001'
        group by item_sku_cd
    )a
    left join
        DW_Product.DWS_SKU_Profile b
    on a.item_sku_cd = b.sku_cd
    left join 
        DW_Product.DIM_Brand c
    on b.brand_id = c.brand_id
    -- where c.is_exclusive = 1
    where c.type_cd = 'Exclusive'
    group by 
        b.brand_id,
        c.brand_name_en,
        c.brand_name_cn
) t
-- order by case when brand_name = 'SEPHORA' then 999999999999 else amount end desc
order by amount desc;


insert into [DW_OMS].[RPT_OMS_Brand_Weekly_Top_10]
select
    brand_tab,
    brand_id,
    brand_name_cn,
    replace(brand_name_en,'''','') as brand_name_en,
    amount,
    quantity,
    -- case when brand_name = 'SEPHORA' then 50 else quantity end as quantity,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select 
        *, 
        row_number() over(partition by brand_tab order by amount desc) rownum
    from 
    (
        select
            case 
                when b.level1_id = '60001' then 'sk'
                when b.level1_id = '60002' then 'mu'
                when b.level1_id = '60005' then 'me'
                when b.level1_id = '60007' then 'fr'
                else 'pc'
            end as brand_tab,
            b.brand_id,
            c.brand_name_en,
            c.brand_name_cn,
            sum(item_amount) as amount,
            sum(item_quantity) as quantity
        from
        (
            select 
                item_sku_cd,
                sum(item_apportion_amount) as item_amount,
                sum(item_quantity) as item_quantity
            from 
                DW_OMS.RPT_Sales_Order_VB_Level
            where 
                is_placed_flag = 1 
            and place_date between dateadd(day,-6,@dt) and @dt
            and store_cd = 'S001'
            group by item_sku_cd
        ) a
        left join
            DW_Product.DWS_SKU_Profile b
        on a.item_sku_cd = b.sku_cd
        left join 
            DW_Product.DIM_Brand c
        on b.brand_id = c.brand_id
        where b.level1_id in ('60001','60002','60003','60004','60005','60006','60007','60008')
        group by 
            b.brand_id,
            c.brand_name_en,
            c.brand_name_cn,
            case 
                when b.level1_id = '60001' then 'sk'
                when b.level1_id = '60002' then 'mu'
                when b.level1_id = '60005' then 'me'
                when b.level1_id = '60007' then 'fr'
                else 'pc'
            end
    ) t
-- order by case when brand_name = 'SEPHORA' then 999999999999 else amount end desc
) t1
where rownum <= 10
END
GO
