/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Brand_Weekly_Top_10_bk]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Brand_Weekly_Top_10_bk] @dt [VARCHAR](10) AS 
begin
delete from [DW_OMS].[RPT_OMS_Brand_Weekly_Top_10] where dt = @dt;
insert into [DW_OMS].[RPT_OMS_Brand_Weekly_Top_10]
select top 10
    brand_id,
    brand_name_cn,
    brand_name,
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
END

GO
