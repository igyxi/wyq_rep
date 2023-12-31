/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_Sales_Order_With_Promotion_Info]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_Sales_Order_With_Promotion_Info] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-03-01       houshuangqiang     change  DW_OMS.RPT_Sales_Order_VB_Level/STG_OMS.Sales_Order_Promo to DWD.Fact_Sales_Order
-- 2023-04-12       wangzhichun        change table source
-- ========================================================================================
delete from [DW_OMS].[RPT_Sales_Order_With_Promotion_Info] where dt = @dt;
insert into [DW_OMS].[RPT_Sales_Order_With_Promotion_Info]
select
    a.sales_order_number,
    a.store_cd,
    a.channel_cd,
    a.place_date,
    a.member_id as member_id,
    a.member_card_grade as card_type,
    b.promotion_id,
    b.promotion_name,
    a.sales_amount,
    -1 * b.promotion_amount,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        place_date,
        'S001' as store_cd,
        sub_channel_code as channel_cd,
        sales_order_sys_id,
        sales_order_number,
        member_id,
        member_card_grade,
        sum(item_apportion_amount) as sales_amount
    from
        [RPT].[RPT_Sales_Order_VB_Level]
    where 
        is_placed = 1
        and channel_code = 'SOA'
        and place_date = @dt
    group by 
        place_date,
        sub_channel_code,
        sales_order_sys_id,
        sales_order_number,
        member_id,
        member_card_grade
) a
left join
(
    select
            sales_order_number,
            promotion_id,
            promotion_name,
            promotion_adjustment_amount as promotion_amount
    from    [DWD].[Fact_Promotion_Order]
    where   source = 'OMS'
    and     channel_code = 'SOA'
    and     is_placed = 1
    group   by sales_order_number,promotion_id,promotion_name,promotion_adjustment_amount
) b
--on a.sales_order_sys_id = b.sales_order_sys_id
on  a.sales_order_number = b.sales_order_number
;

END


GO
