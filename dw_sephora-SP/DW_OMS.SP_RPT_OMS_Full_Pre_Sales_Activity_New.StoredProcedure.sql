/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_OMS_Full_Pre_Sales_Activity_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_OMS_Full_Pre_Sales_Activity_New] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-02-20       houshuangqiang     replace STG_OMS.Sales_Order/DW_OMS.DWS_Purchase_Order
-- 2023-04-17       wangzhichun        change promotion source table
-- 2023-06-01       wangzhichun        change o.order_status like '%PENDING%' to o.order_status like '%WAIT_BUYER_PAY%'
-- ========================================================================================
truncate table DW_OMS.RPT_OMS_Full_Pre_Sales_Activity_New;
insert into DW_OMS.RPT_OMS_Full_Pre_Sales_Activity_New
select 	o.purchase_order_number,
		o.payment_time,
		o.item_sku_code as item_sku_cd,
		o.virtual_sku_code as virtual_sku,
		o.item_sku_name as item_name,
		o.item_quantity,
		o.item_apportion_amount,
		o.actual_warehouse as item_order_actual_ware_house,
		activity.activity_id,
		promo.sale_end_time,
		current_timestamp as insert_timestamp
from 	DWD.Fact_OMS_Sales_Order_New o
left 	join
(
	select 	order_id
			,sku_code
			,activity_id
	from 	STG_Order.Trial_Activity
	where 	type = 3
) activity
on 		o.sales_order_number = activity.order_id
and 	o.item_sku_code = activity.sku_code
left 	join ODS_Promotion.Activity promo -- 切换时上游数据源会用ODS_Promotion.Activity
on 		activity.activity_id = cast(promo.activity_id as varchar(512))
where 	o.sub_type_code=3
and     o.source = 'NEW OMS'
and     o.po_order_status=12                --NEW OMS状态初始默认为1,待数据进入核验
and     o.purchase_order_number is not null    
;
END

GO
