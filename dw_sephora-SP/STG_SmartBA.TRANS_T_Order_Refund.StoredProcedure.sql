/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Order_Refund]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Order_Refund] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_SmartBA.T_Order_Refund ;
insert into STG_SmartBA.T_Order_Refund
select 
    id,
    case when trim(order_code) in ('null','') then null else trim(order_code) end as order_code,
    case when trim(po_code) in ('null','') then null else trim(po_code) end as po_code,
    case when trim(return_code) in ('null','') then null else trim(return_code) end as return_code,
    amount,
    tenant_id,
    create_time,
    current_timestamp as insert_timestamp
from 
    ODS_SmartBA.T_Order_Refund
-- where dt =  @dt
END
GO
