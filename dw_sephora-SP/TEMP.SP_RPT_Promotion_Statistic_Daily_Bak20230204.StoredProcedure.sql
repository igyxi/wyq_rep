/****** Object:  StoredProcedure [TEMP].[SP_RPT_Promotion_Statistic_Daily_Bak20230204]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Promotion_Statistic_Daily_Bak20230204] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       mac                delete ''
-- ========================================================================================
delete from [DW_Promotion].[RPT_Promotion_Statistic_Daily] where dt = @dt;
insert into [DW_Promotion].[RPT_Promotion_Statistic_Daily]
select 
    a.promotion_sys_id, 
    a.promotion_name, 
    a.promotion_type, 
    case 
        when promotion_type = 1 then N'单品折扣'
        when promotion_type = 2 then N'单品买赠'
        when promotion_type = 3 then N'组合满减'
        when promotion_type = 4 then N'组合满赠'
        when promotion_type = 5 then N'固定运费'
        when promotion_type = 6 then N'订单满减' 
        when promotion_type = 7 then N'订单满赠'
    end  as promotion_type_name,
    t.crm_coupon_flag,
    a.order_type,
    case 
        when order_type = '1' then N'普通'
        when order_type = '2' then N'定金预售'
        when order_type = '3' then N'全额预售'
    end  as order_type_name,
    a.use_type,
    case 
        when a.use_type = 0 then N'限定购买（不试用coupon）'
        when a.use_type = 1 then N'促销代码（公共Coupon）'
        when a.use_type = 2 then N'赠券促销（私有coupon）'
    end  as use_type_name,
    a.customer_group,
    a.channel_id,
    a.[status],
    case when a.[status] = 0 then N'草稿'
         when a.[status] = 1 then N'待审核'
         when a.[status] = 2 then N'审核失败'
         when a.[status] = 3 then N'待处理'
         when a.[status] = 4 then N'已发布'
         when a.[status] = 5 then N'停止'
    end  as status_name,
    a.publish_env,
    a.start_time, 
    a.end_time, 
    a.public_code_used_times,
    b.coupon_users, 
    t.place_date,--增加
    t.sales,
    t.orders,
    t.buyers,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
    [STG_Promotion].Promotion a
left join
(
    select cast(promotion_id as varchar) AS promotion_id, count(distinct user_id) coupon_users from [STG_Promotion].PX_Coupon where cast(create_time as date) = @dt group by promotion_id 
) b
on a.promotion_sys_id = b.promotion_id
left join
(
    select 
        c.promotion_code, 
        c.crm_coupon_flag,
        d.place_date,--增加
        sum(d.payed_amount) as sales, 
        count(distinct d.sales_order_sys_id) as orders,
        count(distinct d.member_id)  as buyers
    from 
        STG_OMS.Sales_Order_Promo c
    join
    (
        select sales_order_sys_id, place_date, payed_amount, member_id, member_card_grade from DW_OMS.RPT_Sales_Order_Basic_Level where is_placed_flag = 1 and place_date = @dt and store_cd = 'S001'
    ) d
    on c.sales_order_sys_id = d.sales_order_sys_id
    group by 
        c.promotion_code,
        c.crm_coupon_flag,
        d.place_date
) t
on a.promotion_sys_id = t.promotion_code;
END 

GO
