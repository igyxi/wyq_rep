/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Order_Package]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Order_Package] AS
BEGIN
truncate table STG_SmartBA.T_Order_Package ;
insert into STG_SmartBA.T_Order_Package
select 
    id,
    case when trim(order_code) in ('null','') then null else trim(order_code) end as order_code,
    case when trim(po_code) in ('null','') then null else trim(po_code) end as po_code,
    po_amount,
    type,
    case when trim(express_code) in ('null','') then null else trim(express_code) end as express_code,
    case when trim(express_name) in ('null','') then null else trim(express_name) end as express_name,
    shipping_time,
    finish_time,
    tenant_id,
    create_time,
    update_time,
    return_sum,
	bill_type,
	po_type,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SmartBA.T_Order_Package
) t
where rownum =  1
END

GO
