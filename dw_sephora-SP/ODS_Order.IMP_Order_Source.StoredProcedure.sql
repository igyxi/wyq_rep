/****** Object:  StoredProcedure [ODS_Order].[IMP_Order_Source]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Order].[IMP_Order_Source] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Order.Order_Source where dt = @dt;
insert into ODS_Order.Order_Source
select 
    a.order_id,
 utm_source,
 utm_medium,
 utm_campaign,
 utm_term,
 utm_content,
 create_time,
 update_time,
 create_user,
 update_user,
 is_delete,
    @dt as dt
from 
(
    select * from ODS_Order.Order_Source where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select order_id from ODS_Order.WRK_Order_Source
) b
on a.order_id = b.order_id
where b.order_id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_Order.WRK_Order_Source;
delete from ODS_Order.Order_Source where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
