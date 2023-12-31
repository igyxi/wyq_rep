/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_SmartBA_Orders_VB_Level_Hourly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_SmartBA_Orders_VB_Level_Hourly] @dt [varchar](10) AS
begin
truncate table [DW_SmartBA].[RPT_SmartBA_Orders_VB_Level_Hourly];
with orders as 
(
    select
        os.order_code as sales_order_number,
        os.create_time as order_time,
        os.pay_time as payment_time,
        case when os.pay_time is null then 0
             else 1
        end as placed_cd,
        osd.spec_code as item_sku_cd,
        osd.number as item_quantity,
        osd.real_amount as item_apportion_amount,
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
            [STG_SmartBA].[T_Order_Hourly]
        where
            is_deleted = 0
        -- and (store_id <> 278 or store_id is null)
        and cast(create_time as date) >= '2020-12-29'
        and cast(coalesce(pay_time,create_time) as date) >= @dt
    ) os  
    left join 
    (
        select 
            * 
        from 
           [STG_SmartBA].[T_Order_Detail_Hourly]
        where 
            cast(create_time as date) >= '2020-12-29'
    ) osd
    on os.order_code = osd.order_code
)


insert into [DW_SmartBA].[RPT_SmartBA_Orders_VB_Level_Hourly]
    select 
        sales_order_number,
        order_time,
        payment_time,
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
        --place_date,
        null is_checked_unionid,
        'ONLINE_PAID',
        current_timestamp as insert_timestamp
    from 
        orders t
    left join
       DW_SmartBA.DIM_Employee_Store_SCD em
    on t.utm_term = em.employee_id
    and t.place_date is not null
    and t.place_date >= cast(em.start_process_time  as date)
    and t.place_date < cast(em.end_process_time as date)
;
end

GO
