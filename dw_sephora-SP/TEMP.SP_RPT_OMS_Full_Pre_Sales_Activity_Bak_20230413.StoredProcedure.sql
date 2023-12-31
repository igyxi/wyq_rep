/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Full_Pre_Sales_Activity_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Full_Pre_Sales_Activity_Bak_20230413] AS
begin
truncate table DW_OMS.RPT_OMS_Full_Pre_Sales_Activity;
insert into DW_OMS.RPT_OMS_Full_Pre_Sales_Activity
select 
	b.purchase_order_number,
	a.payment_time,
	b.item_sku_cd,
	b.virtual_sku,
	b.item_name,
	b.item_quantity,
	b.item_apportion_amount,
	b.item_order_actual_ware_house,
	coalesce(c.activity_id,d.activity_id) as activity_id,
	e.sale_end_time,
	current_timestamp as insert_timestamp
from 
		(select * from [STG_OMS].[Sales_Order] where merge_flag = 1 and basic_status <> 'DELETED' and order_internal_status like '%PENDING%') a
	left join
		(select * from [DW_OMS].[DWS_Purchase_Order] where split_type <> 'SPLIT_SUB' and basic_status <> 'DELETED') b
	on a.sales_order_number = b.sales_order_number
	left join 
		(select * from [STG_Order].[Trial_Activity] where type = 3) c
	on a.sales_order_number = c.order_id and b.virtual_sku = c.sku_code
	left join 
		(select * from [STG_Order].[Trial_Activity] where type = 3) d
	on a.sales_order_number = d.order_id and b.item_sku_cd = d.sku_code
	left join
	    [STG_Promotion].[Promo_Activity] e
	on coalesce(c.activity_id, d.activity_id) = cast(e.activity_id as varchar(512))
where 
    b.purchase_order_number is not null;
END 
GO
