/****** Object:  StoredProcedure [RPT].[SP_RPT_Sales_Order_Basic_Level]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sales_Order_Basic_Level] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-15       wangzhichun        Initial Version
-- 2022-07-27       wangzhichun        update
-- 2022-08-01       houshuangqiang     update smartba_flag logic
-- 2022-08-11       houshuangqiang     update smartba_flag logic
-- 2023-01-10       wangzhichun        add split_flag
-- 2023-05-28       wangzhichun        update new oms
-- ========================================================================================
truncate table [RPT].[RPT_Sales_Order_Basic_Level];
with order_so as (
    select
        '' as sales_order_sys_id,
        a.tid as sales_order_number,
        t.channel_code,
        t.channel_name,
        t.sub_channel_code,
        t.sub_channel_name,
        t.province,
        t.city,
        t.district,
        a.front_order_type as type_code,
        t.is_placed,
        t.place_time,
        format(t.place_time, 'yyyy-MM-dd') as place_date,
        case 
            when t.channel_code = 'SOA' then  COALESCE(t.member_card, a.customer_id)
            when t.sub_channel_code='DOUYIN001' then concat(a.customer_id, t.province, t.city, t.district)
            else a.customer_id
        end as super_id,
        case 
            when t.channel_code='SOA' then try_cast(a.customer_id as bigint)
            else c.eb_user_id
        end as sephora_user_id,
        a.customer_id as member_id,
        null as open_id,                --对应字段没有同步，置空
        t.member_card,
        t.member_card_grade,
        case 
            when t.member_card_grade = 'PINK'  then 1
            when t.member_card_grade = 'NEW' then 2
            when t.member_card_grade = 'WHITE' then 3
            when t.member_card_grade = 'BLACK' then 4
            when t.member_card_grade = 'GOLD' then 5
            else 0
        end as member_card_level,
        gi.mobile_guid as mobile_guid,
        case when c.gender = 0 then 'F'
             when c.gender = 1 then 'M'
             else null
        end as member_gender,
        c.birth_date,
        t.order_time,
        format(t.order_time, 'yyyy-MM-dd') as order_date,
        a.status as order_internal_status,                 --对应字段没有同步，置空
        a.payment as order_amount,
        (a.total_fee-a.merchant_discount_fee) as product_total,     --数据存在差异
        a.discount_fee as adjustment_total,
        null as coupon_adjustment_total,
        null as promotion_adjustment_total,
        t.payment_status,
        a.payment as payed_amount,
        t.payment_time,
        format(t.payment_time, 'yyyy-MM-dd') as payment_date,
        null as shipping_type,
        a.post_fee as shipping_total,
        a.buyer_message as buyer_memo,
        a.is_plit as split_flag,
        t.is_smartba,
        null as [version],                           --version有null和1 ，已置空
        a.created_at as create_time,
        a.updated_at as update_time,
        null as end_time
    from 
    (
        select 
            sales_order_number,
            channel_code,
            channel_name,
            sub_channel_code,
            sub_channel_name,
            province,
            city,
            district,
            max(member_card) as member_card,
            max(member_card_grade) as member_card_grade,
            payment_status,
            order_time,
            payment_time,
            is_placed,
            place_time,
            is_smartba
        from
            [DWD].[Fact_Sales_Order]
        where source='OMS'
        group by
            sales_order_number,
            channel_code,
            channel_name,
            sub_channel_code,
            sub_channel_name,
            province,
            city,
            district,
            payment_status,
            order_time,
            payment_time,
            is_placed,
            place_time,
            is_smartba
    ) t 
    left join
        ODS_OMS_Order.OMS_STD_Trade a
    on t.sales_order_number = a.tid 
    left join 
    (
        select sales_order_number,cast(mobile_guid as varchar) as mobile_guid from DW_OMS_Order.DW_Order_Guid_Info    --STG_OMS.Order_Guid_Info 没有对应的关联条件
    ) gi
    on a.tid = gi.sales_order_number
    left join
        DWD.DIM_Member_Info c
    on t.member_card = c.member_card  
)

insert into [RPT].[RPT_Sales_Order_Basic_Level]
select
    sales_order_sys_id,
    sales_order_number,
    channel_code,
    channel_name,
    sub_channel_code,
    sub_channel_name,
    province,
    city,
    district,
    type_code,
    is_placed,
    place_time,
    place_date,
    super_id,
    sephora_user_id,
    member_id,
    open_id,
    member_card,
    member_card_grade,
    member_card_level,
    mobile_guid,
    member_gender,
    birth_date,
    year(place_date)-year(birth_date) as member_age,
    case when is_placed = 0 then 'NULL'
         when all_order_placed_seq = 1 and first_member_card_level >= 3 then 'CONVERT_NEW'
         when all_order_placed_seq = 1 and first_member_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_new_status,
    case when is_placed = 0 then 'NULL'
         when member_daily_seq = 1 and member_daily_card_level >= 3 then 'CONVERT_NEW'
         when member_daily_seq = 1 and member_daily_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_daily_new_status, 
    case when is_placed = 0 then 'NULL'
         when member_monthly_seq = 1 and member_monthly_card_level >= 3 then 'CONVERT_NEW'
         when member_monthly_seq = 1 and member_monthly_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_monthly_new_status, 

    case when is_placed = 0 then 'NULL'
         when member_yearly_seq = 1 and member_yearly_card_level >= 3 then 'CONVERT_NEW'
         when member_yearly_seq = 1 and member_yearly_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_yearly_new_status,
    case when is_placed = 0 then 'NULL'
         when member_monthly_seq = 1 then 'NEW'
         else 'RETURN'
    end as monthly_member_purchase_status, 
    case 
         when monthly_card_level = 1 then 'PINK'
         when monthly_card_level in (2,3) then 'WHITE'
         when monthly_card_level = 4 then 'BLACK'
         when monthly_card_level = 5 then 'GOLD'
         else 'NULL'
    end as monthly_member_card_grade,
    order_internal_status,
    order_time,
    order_date,
    order_amount,
    product_total,
    adjustment_total,
    coupon_adjustment_total,
    promotion_adjustment_total,
    payment_status,
    payed_amount,
    payment_time,
    payment_date,
    shipping_type,
    shipping_total,
    case when sub_channel_code = 'O2O' then substring(buyer_memo,1,4) else null end as o2o_shop_cd,
    split_flag,
    is_smartba,
    all_order_seq,
    all_order_placed_seq,
    chanel_order_seq,
    chanel_order_placed_seq,
    create_time,
    format(create_time,'yyyy-MM-dd') as create_date,
    update_time,
    format(update_time,'yyyy-MM-dd') as update_date,
    end_time,
    null as end_date,
    current_timestamp as insert_timestamp
from
(
    select
        *,
        rank() over (partition by super_id order by order_time) as all_order_seq,
        rank() over (partition by super_id, is_placed order by place_time) as all_order_placed_seq,
        rank() over (partition by super_id, sub_channel_code  order by order_time) as chanel_order_seq,
        rank() over (partition by super_id, is_placed, sub_channel_code order by place_time) as chanel_order_placed_seq,
        rank() over (partition by super_id, is_placed order by place_date) as member_daily_seq,
        rank() over (partition by super_id, is_placed order by year(place_time), month(place_time)) as member_monthly_seq,
        rank() over (partition by super_id, is_placed order by year(place_time)) as member_yearly_seq,
        FIRST_VALUE(case when is_placed = 1 then member_card_level else null end) over (partition by super_id, is_placed order by place_time asc, member_card_level desc ROWS UNBOUNDED PRECEDING) as first_member_card_level,
        FIRST_VALUE(case when is_placed = 1 then member_card_level else null end) over (partition by super_id, is_placed, place_date order by place_time asc, member_card_level desc ROWS UNBOUNDED PRECEDING) as member_daily_card_level,
        FIRST_VALUE(case when is_placed = 1 then member_card_level else null end) over (partition by super_id, is_placed, year(place_time), month(place_time) order by place_time asc ,member_card_level desc ROWS UNBOUNDED PRECEDING) as member_monthly_card_level,
        FIRST_VALUE(case when is_placed = 1 then member_card_level else null end) over (partition by super_id, is_placed, year(place_time) order by place_time asc ,member_card_level desc ROWS UNBOUNDED PRECEDING) as member_yearly_card_level,
        max(member_card_level) over (partition by super_id, year(place_time), month(place_time)) as monthly_card_level
    from 
        order_so
) t
END
GO
