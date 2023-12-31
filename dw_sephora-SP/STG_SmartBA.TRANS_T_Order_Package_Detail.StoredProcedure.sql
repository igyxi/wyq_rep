/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Order_Package_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Order_Package_Detail] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-31       wangzhichun    Initial Version
-- 2022-04-25       Tali           change update logic
-- 2022-06-28       wangzhichun    change partition by
-- ========================================================================================
truncate table STG_SmartBA.T_Order_Package_Detail ;
insert into STG_SmartBA.T_Order_Package_Detail
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
    select *, row_number() over(partition by order_code,sku_code,po_code order by dt,id desc) rownum from ODS_SmartBA.T_Order_Package_Detail
) t
where rownum = 1
END

GO
