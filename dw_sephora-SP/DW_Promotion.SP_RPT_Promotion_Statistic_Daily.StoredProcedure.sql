/****** Object:  StoredProcedure [DW_Promotion].[SP_RPT_Promotion_Statistic_Daily]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Promotion].[SP_RPT_Promotion_Statistic_Daily] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       mac                delete ''
-- 2023-02-24       tali               change to dwd
-- 2023-04-21       wangzhichun		   change STG_Promotion to ODS_Promotion
-- ========================================================================================
delete from [DW_Promotion].[RPT_Promotion_Statistic_Daily] where dt = @dt;
insert into [DW_Promotion].[RPT_Promotion_Statistic_Daily]
select
    a.promotion_id, 
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
    a.crm_flag as crm_coupon_flag,
    a.order_group,
    case 
        when order_group = '1' then N'普通'
        when order_group = '2' then N'定金预售'
        when order_group = '3' then N'全额预售'
    end  as order_group_name,
    a.use_type,
    case 
        when a.use_type = 0 then N'限定购买（不试用coupon）'
        when a.use_type = 1 then N'促销代码（公共Coupon）'
        when a.use_type = 2 then N'赠券促销（私有coupon）'
    end  as use_type_name,
    a.member_group,
    a.channel_group,
    a.[status],
    case when a.[status] = 0 then N'草稿'
         when a.[status] = 1 then N'待审核'
         when a.[status] = 2 then N'审核失败'
         when a.[status] = 3 then N'待处理'
         when a.[status] = 4 then N'已发布'
         when a.[status] = 5 then N'停止'
    end  as status_name,
    0 as publish_env,
    a.start_time, 
    a.end_time, 
    null as public_code_used_times,
    b.coupon_users, 
    c.place_date,--增加
    c.sales,
    c.orders,
    c.buyers,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
    [DWD].DIM_Promotion a
left join
(
    select cast(promotion_id as varchar) AS promotion_id, count(distinct user_id) coupon_users from [ODS_Promotion].PX_Coupon where cast(create_time as date) = @dt group by promotion_id 
) b
on a.promotion_id = b.promotion_id
left join
(
    select 
        promotion_id, 
        format(place_time , 'yyyy-MM-dd') as place_date, 
        count(member_card) buyers, 
        count(sales_order_number) orders, 
        sum(payment_amount) sales 
    from
    (
        select distinct promotion_id, place_time, sales_order_number, member_card, payment_amount
        from DWD.Fact_Promotion_Order
        where is_placed = 1 
        and channel_code = 'SOA' 
        and format(place_time , 'yyyy-MM-dd') = @dt
    ) t
    group by 
        format(place_time , 'yyyy-MM-dd'),
        promotion_id
) c
on a.promotion_id = c.promotion_id;
end; 
GO
