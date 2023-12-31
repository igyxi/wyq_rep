/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_Order_With_Promotion_Info_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_Order_With_Promotion_Info_Bak_20230413] @dt [VARCHAR](10) AS
BEGIN
delete from [DW_OMS].[RPT_Sales_Order_With_Promotion_Info] where dt = @dt;
insert into [DW_OMS].[RPT_Sales_Order_With_Promotion_Info]
select 
    a.sales_order_number,
    a.store_cd as store,
    a.channel_cd as channel,
    a.place_date,
    a.member_id,
    a.member_card_grade as card_type,
    b.promotion_id,
    b.promotion_name,
    a.sales_amount,
    b.promotion_amount,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        place_date,
        store_cd,
        channel_cd,
        sales_order_sys_id,
        sales_order_number,
        member_id,
        member_card_grade,
        sum(item_apportion_amount) as sales_amount
    from
        [DW_OMS].[RPT_Sales_Order_VB_Level]
    where 
        is_placed_flag = 1
        and store_cd = 'S001'
        and place_date = @dt
    group by 
        place_date,
        store_cd,
        channel_cd,
        sales_order_sys_id,
        sales_order_number,
        member_id,
        member_card_grade
) a 
left join
(
    select
        sales_order_sys_id,
        promotion_code as promotion_id,
        promotion_name,
        promotion_amount
    from 
        [STG_OMS].[Sales_Order_Promo]
) b
on a.sales_order_sys_id = b.sales_order_sys_id
;
END 

GO
