/****** Object:  StoredProcedure [ODS_SmartBA].[IMP_T_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SmartBA].[IMP_T_Order] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_SmartBA.T_Order where dt = @dt;
insert into ODS_SmartBA.T_Order
select 
    a.id,
    order_code,
    order_type,
    sale_type,
    open_id,
    union_id,
    should_amount,
    member_card,
    card_level,
    product_amount,
    order_amount,
    user_id,
    user_phone,
    receiver_id,
    receiver_name,
    receiver_phone,
    receiver_address,
    receiver_postcode,
    express_amount,
    reduce_amount,
    coupon_id,
    coupon_amount,
    discount_amount,
    integral,
    integral_amount,
    order_status,
    pay_status,
    pay_type,
    pay_time,
    express_time,
    pay_code,
    trade_id,
    express_status,
    express_id,
    express_code,
    invoice_id,
    invoice_status,
    form_id,
    emp_id,
    emp_type,
    emp_code,
    emp_name,
    emp_phone,
    seller_id,
    remark,
    oper_remark,
    return_status,
    return_amount,
    return_integral,
    member_phone,
    finish_time,
    channel,
    sync_status,
    company_id,
    company_name,
    store_id,
    store_code,
    store_name,
    is_take,
    app_type,
    take_code,
    group_status,
    is_deleted,
    tenant_id,
    create_time,
    update_at,
    update_time,
    @dt as dt
from 
(    
select * from ODS_SmartBA.T_Order where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(select id from ODS_SmartBA.WRK_T_Order) b
on a.id = b.id
where b.id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_SmartBA.WRK_T_Order;
delete from ODS_SmartBA.T_Order where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
