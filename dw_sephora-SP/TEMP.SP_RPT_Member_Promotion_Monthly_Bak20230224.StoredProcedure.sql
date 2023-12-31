/****** Object:  StoredProcedure [TEMP].[SP_RPT_Member_Promotion_Monthly_Bak20230224]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Member_Promotion_Monthly_Bak20230224] @dt [VARCHAR](10) AS
BEGIN
delete from [DW_Promotion].[RPT_Member_Promotion_Monthly] where dt = @dt;
insert into [DW_Promotion].[RPT_Member_Promotion_Monthly]
select 
    substring(cast(place_date as varchar(512)),1,7) as month_id,
    a1.promotion_name,
    a1.promotion_code,
    count(distinct b1.sales_order_number) as orders,
    sum(b1.product_amount) as sales,
    count(distinct b1.super_id) as buyers,
    current_timestamp as insert_timestamp,
    @dt as dt
from
    (select 
        sales_order_sys_id, 
        promotion_code, 
        promotion_name,
        promotion_amount
    from STG_OMS.Sales_Order_Promo
    where cast(create_time as date) between DATEADD(day,1,EOMONTH(@dt, -1)) and @dt
    and (promotion_code = '1060000817' or promotion_code = '1060000816')
    ) a1
inner join
    (select 
        place_date, sales_order_sys_id, sales_order_number,product_amount,super_id
    from DW_OMS.RPT_Sales_Order_basic_Level
    where is_placed_flag =1
    and cast(place_time as date) between DATEADD(day,1,EOMONTH(@dt, -1)) and @dt
    and store_cd = 'S001') b1
on a1.sales_order_sys_id = b1.sales_order_sys_id
group by
    substring(cast(place_date as varchar(512)),1,7), 
    a1.promotion_name,
    a1.promotion_code;
END 

GO
