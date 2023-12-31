/****** Object:  StoredProcedure [TEMP].[SP_RPT_Purchase_Order_Status_Bak_20230601]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Purchase_Order_Status_Bak_20230601] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-02-21       houshuangqiang     replace DW_OMS.DWS_Purchase_Order/dw_oms.RPT_Sales_Order_SKU_Level
-- 2023-03-31       houshuangqiang     change source table
-- ========================================================================================
truncate table [DW_OMS].[RPT_Purchase_Order_Status];
insert into [DW_OMS].[RPT_Purchase_Order_Status]
select distinct
    o.purchase_order_number,
    o.store_cd,
    o.order_time,
    o.place_time,
    o.order_def_ware_house,
    o.order_actual_ware_house,
    o.internal_status,
    o.logistics_shipping_company,
    o.logistics_number,
    o.logistics_shipping_time,
    case cancel.apply_type
        when 'CANCEL_APPLY' then N'取消申请'
        when 'MODIFY_ADDRESS_APPLY' then N'信息修改申请'
        when 'PARTIAL_CANCEL_APPLY' then N'部分取消申请'
    else cancel.apply_type end as apply_type,
    case cancel.task_status
         when 'REJECTED' then N'取消失败'
         when 'FINISHED' then N'已处理'
         when 'TACK_CANCELLED' then N'已撤销任务'
         when 'APPLYING_WAIT' then N'申请等待中'
         when 'INTERCEPT_DONE' then N'仓库拦截成功'
         when 'INTERCEPT_FAILTURE' then N'仓库拦截失败'
         when 'MODIFY_DONE' then N'仓库修改信息成功'
         when 'CANCEL_DONE' then N'仓库取消成功'
         when 'TASK_INITIALIZED' then N'申请初始化'
         when 'MODIFY_FAILTURE' then N'仓库修改信息失败'
         when 'RECEIVED' then N'仓库已接收'
         when 'WAITTING' then N'等待处理'
         when 'CANCELED' then N'取消成功'
         when 'CANCELLED' then N'取消成功'
         else cancel.task_status
	end as task_status,
    current_timestamp as insert_timestamp
from
(
    select
			so.purchase_order_number,
			order_time,
			place_time,
            case when channel_code='SOA' THEN 'S001' ELSE sub_channel_code end store_cd,
			so.def_warehouse as order_def_ware_house,
			so.actual_warehouse as order_actual_ware_house,
			order_status as internal_status,
			so.logistics_company as logistics_shipping_company,
			logi.logistics_number,
			logi.logistics_shipping_time
    from	DWD.Fact_Sales_Order so
    left join 
            DWD.Fact_Logistics_Order logi
    on      so.purchase_order_number=logi.purchase_order_number
    where 	so.source = 'OMS'
    and     sub_channel_code <> 'GWP001'
    and		type_code <> 2
    and		item_sku_code is not null
    group   by so.purchase_order_number,order_time,place_time,case when channel_code='SOA' THEN 'S001' ELSE sub_channel_code end,
            so.def_warehouse,so.actual_warehouse,order_status,so.logistics_company,logi.logistics_number,logi.logistics_shipping_time
) o
left join
(
    select 	source_order_no,
			apply_type,
			task_status
    from	STG_OMS.Sap_Order_Cancel_Task
    where	basic_status <> 'DELETED'
) cancel
on	o.purchase_order_number = cancel.source_order_no
;

END
GO
