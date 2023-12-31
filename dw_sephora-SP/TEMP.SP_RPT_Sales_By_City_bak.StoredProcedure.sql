/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_By_City_bak]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_By_City_bak] AS
BEGIN
truncate table DW_OMS.RPT_Sales_By_City;
insert into DW_OMS.RPT_Sales_By_City
select
    format(b.payment_time,'yyyy-MM') as month,
    case when d.province is null then d1.province
    else d.province end as province,
    d.city as city,
    case when d.region is null then d1.region
    else d.region end as region,
    count(distinct b.store_code) as store_count,
    --pos的门店为31
    sum(case when b.source = 'POS' then b.item_apportion_amount else 0 end
    -case when a.source = 'POS' then a.item_apportion_amount else 0 end) as retail_sales,
    sum(case when b.source = 'OMS' then b.sap_amount else 0 end
    -case when a.source = 'OMS' then a.item_apportion_amount else 0 end) as eb_sap_sales,
    sum(case when b.source = 'POS' and c.store_code is not null then b.item_apportion_amount else 0 end
    -case when a.source = 'POS' then a.item_apportion_amount else 0 end) as retail_comp_sales,
    sum(case when b.source = 'OMS' then b.item_apportion_amount else 0 end) as eb_oms_sale,
    current_timestamp as insert_tiemstamp
from 
(select 
        A.sales_order_number,
        case when (A.province is not null and A.province != N'其他') then A.province
        else B.province end as province,
        case when A.city is not null then A.city
        else B.city end as city,
        --B.province,
        --B.city,
        sum(A.item_apportion_amount) as item_apportion_amount,
        sum(A.sap_amount) as sap_amount,
        A.source,
        A.payment_time,
        A.store_code,
        A.item_sku_code
    from 
        DWD.Fact_Sales_Order A
    left join 
        (select 
            t.sales_order_number,
            t1.city,t1.province,
            t1.create_time,
            row_number() over (partition by t.sales_order_number,t1.city,t1.province order by t1.create_time desc) as rownum
        FROM 
            stg_oms.Sales_Order t
        left join 
            stg_oms.Sales_Order_Address t1
        on t.sales_order_sys_id = t1.sales_order_sys_id
        group by 
            t.sales_order_number,
            t1.city,t1.province,
            t1.create_time
        ) B
    on A.sales_order_number = B.sales_order_number
    and B.rownum = 1
    where 
        (A.source = 'POS' or A.source = 'OMS') 
    and A.is_placed = 1 
    and A.province is not null
    --and a.sales_order_number = '1334562225653776'
    --and payment_time between '2021-01-01' and '2021-07-01'
                --and sales_order_number = '666446004000013220211211200523'
    group by 
        A.sales_order_number,
        case when (A.province is not null and A.province != N'其他') then A.province
        else B.province end,
        case when A.city is not null then A.city
        else B.city end,
        --b.province,
        --b.city,
        A.source,
        A.payment_time,
        A.store_code,
        A.item_sku_code

) b
left join
(
    select
        sales_order_number,
        --district,
        sum(item_apportion_amount) as item_apportion_amount,
        source,
        store_code,
        item_sku_code
    from 
        DWD.Fact_Refund_Order 
    where 
        (source = 'POS' or source = 'OMS') 
        --and refund_time between '2021-01-01' and '2021-07-01'
        group by sales_order_number,
        source,
        store_code,
        item_sku_code
        
        -- and sales_order_number = '100000083535795350'
) a
on 
    a.sales_order_number = b.sales_order_number
    and a.item_sku_code = b.item_sku_code
left join
    STG_OMS.DIM_Store_Code_Mapping c
on c.store_code = b.store_code
left join 
    STG_OMS.DIM_Province_Region_Mapping d
on d.city_name = b.city
left join 
    (
    select 
        distinct province_name,
            Region,Province
    from 
        STG_OMS.DIM_Province_Region_Mapping
    ) d1
on d1.province_name = b.province
where d.city is not null
group by
    format(b.payment_time,'yyyy-MM'),
    case when d.province is null then d1.province
    else d.province end,
    d.city,
    case when d.region is null then d1.region
    else d.region end
;
END

GO
