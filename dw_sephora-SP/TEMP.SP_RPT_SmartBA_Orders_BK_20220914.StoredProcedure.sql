/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_Orders_BK_20220914]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_Orders_BK_20220914] AS
begin
truncate table [DW_SmartBA].[RPT_SmartBA_Orders];
with orders as 
(
    select
        os.order_code as sales_order_number,
        bt_sku.purchase_order_number,
        os.create_time as order_time,
        os.pay_time as payment_time,
        bt_sku.shipping_time as shipping_time,
        bt_sku.shipping_time as fin_time,
        case when bt_sku.sales_order_number is not null then 1 else 0 end as fin_cd,
        case when os.pay_time is null then 0
             else 1
        end as placed_cd,
        bt_sku.item_sku_cd,
        bt_sku.item_quantity,
        bt_sku.item_apportion_amount,
        os.emp_code as utm_term,
        os.store_code as utm_content,
        os.user_id as member_id,
        os.member_card, 
        os.card_level as member_card_grade,
        cast(os.pay_time as date) as place_date
    from
    (
        select 
            order_code,
            create_time,
            pay_time,
            user_id,
            member_card,
            card_level,
            emp_code,
            store_code
        from 
            [STG_SmartBA].[T_Order]
        where
            is_deleted = 0
        -- and (store_id <> 278 or store_id is null)
        and cast(create_time as date) >= '2020-12-29'
    ) os  
    left join 
    (
        select 
            * 
        from 
           [DW_SmartBA].[DWS_SmartBA_Order_Package]
        where 
            cast(shipping_time as date) >= '2020-12-29'
    ) bt_sku
    on os.order_code = bt_sku.sales_order_number
),
orders_utm_content as
(
    select
        sales_order_number,
        purchase_order_number,
        order_time,
        payment_time,
        shipping_time,
        fin_time,
        fin_cd,
        placed_cd,
        item_sku_cd,
        item_quantity,
        item_apportion_amount,
        utm_term,
        case when em.store_cd is null then utm_content
            when cast(em.start_process_time as date) = '1970-01-01' then utm_content
            else em.store_cd
        end as utm_content,
        member_id,
        member_card, 
        member_card_grade,
        place_date
    from 
        orders t
    left join
       DW_SmartBA.DIM_Employee_Store_SCD em
    on t.utm_term = em.employee_id
    and t.place_date is not null
    and t.place_date >= cast(em.start_process_time  as date)
    and t.place_date < cast(em.end_process_time as date)
    -- where 
    --     () 
    -- or t.place_date is null
    -- or em.employee_id is null
)

insert into [DW_SmartBA].[RPT_SmartBA_Orders]
select
    sales_order_number,
    purchase_order_number,
    order_time,
    payment_time,
    shipping_time,
    fin_time,
    fin_cd,
    placed_cd,
    item_sku_cd,
    item_quantity,
    item_apportion_amount,
    utm_term,
    utm_content,
    member_id,
    member_card, 
    member_card_grade,
    null is_checked_unionid, -- case when u.userid is not null and order_time > u.bindingtime then 1 else 0 end as is_checked_unionid,
    'ONLINE_PAID',
    current_timestamp as insert_timestamp
from 
(
    select 
        sales_order_number,
        purchase_order_number,
        order_time,
        payment_time,
        shipping_time,
        fin_time,
        fin_cd,
        placed_cd,
        item_sku_cd,
        item_quantity,
        item_apportion_amount,
        utm_term,
        utm_content,
        member_id,
        member_card, 
        member_card_grade,
        place_date
    from 
        orders_utm_content
    union all 
    select 
        a.sales_order_number,
        a.purchase_order_number,
        a.order_time,
        a.payment_time,
        a.shipping_time,
        b.create_time as fin_time,
        2 as fin_cd,
        a.placed_cd,
        b.item_sku_cd,
        -1 * b.item_quantity,
        -1 * b.item_refund_amount,
        a.utm_term,
        a.utm_content,
        a.member_id,
        a.member_card, 
        a.member_card_grade,
        a.place_date
    from 
    (
        select distinct 
            sales_order_number, 
            purchase_order_number,
            order_time,
            payment_time,
            shipping_time,
            placed_cd,
            place_date,
            utm_term,
            utm_content,
            member_id,
            member_card,
            member_card_grade
        from 
            orders_utm_content 
        where 
            fin_cd = 1 
    ) a
    join 
        [DW_SmartBA].[DWS_SmartBA_Order_Refund] b
    on a.sales_order_number = b.sales_order_number
    and a.purchase_order_number = b.purchase_order_number
) t
;
end

GO
