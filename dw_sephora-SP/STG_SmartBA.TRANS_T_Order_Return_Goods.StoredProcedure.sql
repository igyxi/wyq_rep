/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Order_Return_Goods]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Order_Return_Goods] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-23       wubin          Initial Version
-- ========================================================================================
truncate table STG_SmartBA.T_Order_Return_Goods;
insert into STG_SmartBA.T_Order_Return_Goods
select 
		id,
		case when trim(order_code) in ('','null') then null else trim(order_code) end as order_code,
		case when trim(return_goods_code) in ('','null') then null else trim(return_goods_code) end as return_goods_code,
		return_goods_amount,
		shop_pay_delivery_i_fee_flag,
		bill_type,
		tenant_id,
		return_time,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SmartBA.T_Order_Return_Goods
) t
where t.rownum = 1
END
GO
