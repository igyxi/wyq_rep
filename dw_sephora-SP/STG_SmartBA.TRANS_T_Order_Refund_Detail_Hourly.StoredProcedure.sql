/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Order_Refund_Detail_Hourly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Order_Refund_Detail_Hourly] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_SmartBA.T_Order_Refund_Detail_Hourly ;
insert into STG_SmartBA.T_Order_Refund_Detail_Hourly
select 
    id,
    case when trim(po_code) in ('null','') then null else trim(po_code) end as po_code,
    case when trim(return_code) in ('null','') then null else trim(return_code) end as return_code,
    case when trim(vs_code) in ('null','') then null else trim(vs_code) end as vs_code,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    number,
    amount,
    real_amount,
    tenant_id,
    create_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by hour desc) rownum from ODS_SmartBA.T_Order_Refund_Detail_Hourly where dt = @dt
) t
where rownum = 1;
delete from ODS_SmartBA.T_Order_Refund_Detail_Hourly where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
