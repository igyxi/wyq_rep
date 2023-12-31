/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Order_Package_Detail_Hourly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Order_Package_Detail_Hourly] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_SmartBA.T_Order_Package_Detail_Hourly ;
insert into STG_SmartBA.T_Order_Package_Detail_Hourly
select 
    id,
    case when trim(order_code) in ('null','') then null else trim(order_code) end as order_code,
    case when trim(po_code) in ('null','') then null else trim(po_code) end as po_code,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    case when trim(sku_name) in ('null','') then null else trim(sku_name) end as sku_name,
    number,
    amount,
    real_amount,
    tenant_id,
    create_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SmartBA.T_Order_Package_Detail_Hourly where dt = @dt
) t
where rownum = 1;
delete from ODS_SmartBA.T_Order_Package_Detail_Hourly where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
