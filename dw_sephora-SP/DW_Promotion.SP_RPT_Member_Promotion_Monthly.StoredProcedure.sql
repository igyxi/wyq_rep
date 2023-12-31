/****** Object:  StoredProcedure [DW_Promotion].[SP_RPT_Member_Promotion_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Promotion].[SP_RPT_Member_Promotion_Monthly] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-02-24       Tali           change to dwd
-- ========================================================================================
delete from [DW_Promotion].[RPT_Member_Promotion_Monthly] where dt = @dt;
insert into [DW_Promotion].[RPT_Member_Promotion_Monthly]
select 
    format(place_time, 'yyyy-MM') as month_id,
    promotion_name,
    promotion_id,
    count(distinct sales_order_number) as orders,
    sum(product_amount) as sales,
    count(distinct member_card) as buyers,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        sales_order_number,
        promotion_id, 
        promotion_name,
        promotion_adjustment_amount,
        member_card,
        place_time,
        sum(item_total_amount) - promotion_adjustment_amount as product_amount
    from 
        DWD.Fact_Promotion_Order
    where 
        cast(create_time as date) between DATEADD(day,1,EOMONTH(@dt, -1)) and @dt
    and (promotion_id = '1060000817' or promotion_id = '1060000816')
    and channel_code = 'SOA'
    and is_placed = 1
    group by 
        sales_order_number,
        promotion_id, 
        promotion_name,
        promotion_adjustment_amount,
        member_card,
        place_time
) a1
group by
    format(place_time, 'yyyy-MM'), 
    promotion_name,
    promotion_id;
END 


GO
