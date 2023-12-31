/****** Object:  StoredProcedure [DWD].[SP_Fact_Logistics_Order_His]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Logistics_Order_His] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-01       houshuangqiang           Initial Version
-- 2023-03-09       houshuangqiang           add order_shipping_time & disitict
-- ========================================================================================
DECLARE @start_time datetime = null;
DECLARE @end_time datetime = null;
select
    -- get max timestamp of the day before
    @start_time = start_time,
    @end_time = end_time
from
(
   select top 1 start_time, end_time from [DW_OMS_Order].[DW_Datetime_Config] where is_delete = '0'  order by start_time desc
) t
;

truncate table DWD.Fact_Logistics_Order_His
insert into DWD.Fact_Logistics_Order_His
select 	po.logistics_number
        ,po.logistics_company
        ,po.sales_order_number
		,po.purchase_order_number
		,addr.province
		,addr.city
		,addr.district
		,po.member_card
		,po.logistics_shipping_time
        ,po.order_shipping_time
		,po.shipping_time
		,po.sign_time
		,po.shipping_amount
		,po.shipping_comment
		,po.def_warehouse
		,po.actual_warehouse
		,po.warehouse_code
		,po.parcel_number
		,addr.status
		,po.missing_flag
		,po.create_time
		,po.update_time
		,'OMS' as source
		,current_timestamp as insert_timestamp
from
(
    select 	distinct
            purchase_order_sys_id
            ,sales_order_number
            ,purchase_order_number
            ,member_card
            ,logistics_shipping_company as logistics_company
            ,logistics_number
            ,logistics_shipping_time
            ,order_shipping_time
            ,shipping_time
            ,sign_time
            ,shipping_total as shipping_amount
            ,order_def_ware_house as def_warehouse
            ,order_actual_ware_house as actual_warehouse
            ,ware_house_code as warehouse_code
            ,order_shipping_comment as shipping_comment
            ,parcel_number
            ,missing_flag
			,create_time
			,update_time
    from    STG_OMS.Purchase_Order
    where   sales_order_number is not null
    and     logistics_number is not null
) po
inner  	join  stg_oms.oms_to_oims_sync_fail_log fail
on     	po.sales_order_number = fail.sales_order_number
and   	fail.sync_status = 1
and 	fail.update_time >= @start_time
and 	fail.update_time <= @end_time
left    join
(
    select  distinct
        	addr.purchase_order_sys_id
            ,mapping.crm_province as province
            ,mapping.crm_city as city
            ,addr.district
--            ,addr.sign_time
--            ,addr.exp_tracking_number
--            ,addr.exp_vendor
--            ,addr.shipping_time
            ,addr.status
--            ,addr.warehouse_code
    from 	STG_OMS.Purchase_Order_Address addr
    left 	join STG_OMS.OMS_Province_City_Mapping mapping
    on 		replace(trim(addr.province), char(9), '') = replace(trim(mapping.oms_province), char(9), '') -- mapping 表中包含tab, 替换为空
    and 	isnull(replace(trim(addr.city), char(9), ''), '') = isnull(replace(trim(mapping.oms_city), char(9), ''), '')
    where   addr.basic_status <> 'DELETED'
--    where 	addr.is_delete = 0
) addr
on  po.purchase_order_sys_id = addr.purchase_order_sys_id
END
GO
