/****** Object:  StoredProcedure [STG_Order].[TRANS_Merge_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Order].[TRANS_Merge_Order] AS
BEGIN
TRUNCATE TABLE STG_Order.Merge_Order;
INSERT INTO STG_Order.Merge_Order
select 
    id,
    case when upper(trim(merge_oid)) in ('', 'NILL') then NUll else trim(merge_oid) end as merge_oid,
    case when upper(trim(m_info)) in ('', 'NILL') then NUll else trim(m_info) end as m_info,
    case when upper(trim(oid)) in ('', 'NILL') then NUll else trim(oid) end as oid,
    order_type,
    quantity,
    total_amount,
    case when upper(trim(images)) in ('', 'NILL') then NUll else trim(images) end as images,
    create_time,
    update_time,
    case when upper(trim(create_user)) in ('', 'NILL') then NUll else trim(create_user) end as create_user,
    case when upper(trim(update_user)) in ('', 'NILL') then NUll else trim(update_user) end as update_user,
    is_delete,
    [current],
    current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by id, oid order by dt desc) rownum from ODS_Order.Merge_Order
)t
where 
    rownum = 1
END

GO
