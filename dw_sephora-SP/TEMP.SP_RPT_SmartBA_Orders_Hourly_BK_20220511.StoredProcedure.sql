/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_Orders_Hourly_BK_20220511]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_Orders_Hourly_BK_20220511] @dt [varchar](10) AS
begin
truncate table [DW_SmartBA].[RPT_SmartBA_Orders_Hourly];
with orders as
(
    select
        t.*,
        case when em.store_cd is null then store_code
            when cast(em.start_process_time as date) = '1970-01-01' then store_code
            else em.store_cd
        end as utm_content
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
            [STG_SmartBA].[T_Order_Hourly]
        where
            is_deleted = 0
        union all
        select 
            a.order_code,
            a.create_time,
            a.pay_time,
            a.user_id,
            a.member_card,
            a.card_level,
            a.emp_code,
            a.store_code
        from 
            [STG_SmartBA].[T_Order] a
        left join
            [STG_SmartBA].[T_Order_Hourly] b
        on a.id = b.id
        where
            a.is_deleted = 0
        and b.id is null
        -- and (store_id <> 278 or store_id is null)
        and cast(a.create_time as date) >= '2020-12-29'
    ) t
    left join
        DW_SmartBA.DIM_Employee_Store_SCD em
    on t.emp_code = em.employee_id
    and t.pay_time is not null
    and cast(t.pay_time as date) >= cast(em.start_process_time as date)  
    and cast(t.pay_time as date) < cast(em.end_process_time as date)
    -- where 
    --     (cast(t.pay_time as date) >= em.start_process_time and cast(t.pay_time as date) < em.end_process_time) 
    -- or t.pay_time is null
    -- or em.employee_id is null 
),

shipping_orders as 
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
        os.utm_content,
        os.user_id as member_id,
        os.member_card, 
        os.card_level as member_card_grade
    from
    (
        select 
            a.order_code as sales_order_number,
            a.po_code as purchase_order_number,
            a.create_time as shipping_time,
            b.sku_code as item_sku_cd,
            b.number as item_quantity,
            b.real_amount as item_apportion_amount
        from 
            [STG_SmartBA].[T_Order_Package_Hourly] a
        left join
            [STG_SmartBA].[T_Order_Package_Detail_Hourly] b
        on a.po_code = b.po_code
        where 
            cast(a.shipping_time as date) >= @dt
    ) bt_sku
    join
        orders os  
    on os.order_code = bt_sku.sales_order_number
),
return_orders as 
(
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
        -1 * b.item_quantity as item_quantity,
        -1 * b.item_refund_amount as item_refund_amount,
        a.utm_term,
        a.utm_content,
        a.member_id,
        a.member_card, 
        a.member_card_grade
    from
    (
        select 
            c.order_code as sales_order_number,
            c.po_code as purchase_order_number,
            c.create_time,
            d.sku_code as item_sku_cd,
            d.number as item_quantity,
            d.amount as item_refund_amount
        from
            [STG_SmartBA].[T_Order_Refund_Hourly] c
        left join
            [STG_SmartBA].[T_Order_Refund_Detail_Hourly] d
        on c.po_code = d.po_code
        and c.return_code = d.return_code
    ) b
    join
    (
        select distinct 
            sales_order_number, 
            purchase_order_number,
            order_time,
            payment_time,
            shipping_time,
            placed_cd,
            utm_term,
            utm_content,
            member_id,
            member_card,
            member_card_grade
        from
        (
            select * from shipping_orders
            union all
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
                member_card_grade
            from 
                [DW_SmartBA].[RPT_SmartBA_Orders]
        ) t
        where t.fin_cd = 1
    ) a
    on a.sales_order_number = b.sales_order_number
    and a.purchase_order_number = b.purchase_order_number
)

insert into [DW_SmartBA].[RPT_SmartBA_Orders_Hourly]
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
    select * from shipping_orders
    union all
    select * from return_orders
) t
;
end

GO
