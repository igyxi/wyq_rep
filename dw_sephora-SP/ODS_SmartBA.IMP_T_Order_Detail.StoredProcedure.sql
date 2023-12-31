/****** Object:  StoredProcedure [ODS_SmartBA].[IMP_T_Order_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SmartBA].[IMP_T_Order_Detail] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_SmartBA.T_Order_Detail where dt = @dt;
insert into ODS_SmartBA.T_Order_Detail
select 
    a.id,
    order_code,
    parent_id,
    product_id,
    product_code,
    product_name,
    brand_name,
    img_url,
    pre_price,
    sell_price,
    price,
    number,
    activity_id,
    is_gift,
    discount_amount,
    real_amount,
    take_amount,
    return_number,
    return_amount,
    spec_id,
    spec_code,
    spec_content,
    delivery_number,
    bar_codes,
    return_bar_codes,
    unique_code,
    status,
    comment_status,
    tenant_id,
    create_time,
    update_time,
    @dt as dt
from 
(    
select * from ODS_SmartBA.T_Order_Detail where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(select id from ODS_SmartBA.WRK_T_Order_Detail) b
on a.id = b.id
where b.id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_SmartBA.WRK_T_Order_Detail;
delete from ODS_SmartBA.T_Order_Detail where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
