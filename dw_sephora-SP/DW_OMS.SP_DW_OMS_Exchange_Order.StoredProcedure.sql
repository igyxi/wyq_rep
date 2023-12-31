/****** Object:  StoredProcedure [DW_OMS].[SP_DW_OMS_Exchange_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DW_OMS_Exchange_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-30       houshuangqiang           Initial Version
-- ========================================================================================
-- truncate table DW_OMS.DW_OMS_Exchange_Order;
-- insert into DW_OMS.DW_OMS_Exchange_Order
---select
---from    STG_OMS.Purchase_Order po
---where   (po.split_type <> 'SPLIT_ORIGIN' or apply.split_type is null)
---and     po.basic_status <> 'DELETED'
---and     po.type = 2
---and     po.rownum = 1
---;
---
---select 取字段
---from
---(
---        select *, row_number() over(partition by purchase_order_number order by sys_create_time desc) rownum from STG_OMS.Purchase_Order
---        where   (split_type <> 'SPLIT_ORIGIN' or split_type is null)
---        and     basic_status <> 'DELETED'
---        and     type = 2
---) po
--- where  po.rownum = 1;
 
truncate table DW_OMS.DW_OMS_Exchange_Order;
insert into DW_OMS.DW_OMS_Exchange_Order
select
		apply.oms_exchange_apply_order_sys_id as oms_exchange_apply_order_sys_id,
		item.oms_exchange_apply_order_item_sys_id as oms_exchange_apply_order_item_sys_id,
		item.oms_order_item_sys_id as oms_order_item_sys_id,
		apply.basic_status as basic_status,
		apply.process_comment as process_comment,
		apply.comment as exchange_apply_comment,
		apply.customer_id as customer_id,
		apply.exchange_no as exchange_number,
		apply.exchange_reason as exchange_reason,
		apply.oms_order_code as sales_order_number,
		apply.order_status as order_status,
		apply.process_status as process_status,
		apply.source_order_code as source_order_code,
		apply.channel_id as channel_code,
		'' as channel_name,
		apply.store_id as sub_channel_code,
		'' as sub_channel_name,
		apply.oms_warehouse_id as warehouse_cd,
		store.store_code,
		addr.province,
		addr.city,		
		addr.district,		
		item.item_adjustment as item_adjustment,
		item.item_type as item_type,
		item.list_price as item_list_price,
		item.qty as item_quantity,
		item.sales_price as item_sales_price,
		item.sku_code as item_sku_code,
		item.sku_name as item_sku_name,
		item.total_adjustment as item_total_adjustment,
		item.total_price as item_total_price,
		item.item_size as item_size,
		item.item_color as item_color,
		item.item_weight as item_weight,
		item.comment as item_comment,
		item.item_kind as item_kind,
		apply.version as version,
		apply.create_time as create_time,
		convert(date,apply.create_time) as create_date,
		apply.update_time as update_time,
		convert(date,apply.update_time) as update_date,
		current_timestamp as insert_tiemstamp
from	[STG_OMS].[OMS_Exchange_Apply_Order] apply 
left 	join [STG_OMS].[OMS_Exchange_Apply_Order_Item] item
on 		apply.oms_exchange_apply_order_sys_id = item.oms_exchange_apply_order_sys_id
left 	join 
(
    select 	oms_exchange_apply_order_sys_id,
			case when coalesce(mapping.crm_province, N'其他') = N'其他' then addr.province
				-- when coalesce(mapping.crm_province, N'其他') = '' then addr.province
				else mapping.crm_province
			end as province,
			case when coalesce(mapping.crm_city, N'其他') = N'其他' then addr.city
				else mapping.crm_city
			end as city,
			addr.district,
			row_number() over(partition by oms_exchange_apply_order_sys_id order by create_time desc) rn 
    from 	STG_OMS.OMS_Exchange_Address addr
    left 	join STG_OMS.OMS_Province_City_Mapping mapping
    on 		addr.province = mapping.oms_province
    and 	addr.city = mapping.oms_city
    -- where 	addr.is_delete = 0
) addr
on 		apply.oms_exchange_apply_order_sys_id = addr.oms_exchange_apply_order_sys_id
left 	join STG_OMS.OMS_Store_Mapping store
on 		apply.store_id = store.store_id
END
GO
