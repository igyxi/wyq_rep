/****** Object:  StoredProcedure [TEMP].[SP_RPT_Purchase_Order_Status_Bak_20230417]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Purchase_Order_Status_Bak_20230417] AS 
begin
truncate table [DW_OMS].[RPT_Purchase_Order_Status];
insert into [DW_OMS].[RPT_Purchase_Order_Status]
select distinct
    a.purchase_order_number,
    a.store_cd,
    a.order_time,
    c.place_time,
    a.order_def_ware_house,
    a.order_actual_ware_house,
    a.internal_status,
    a.logistics_shipping_company,
    a.logistics_number,
    a.logistics_shipping_time,
    case b.apply_type 
        when 'CANCEL_APPLY' then '取消申请'
        when 'MODIFY_ADDRESS_APPLY' then '信息修改申请'
        when 'PARTIAL_CANCEL_APPLY' then '部分取消申请'
    else b.apply_type end as apply_type,
    case b.task_status
         when 'REJECTED' then '取消失败'
         when 'FINISHED' then '已处理'
         when 'TACK_CANCELLED' then '已撤销任务'
         when 'APPLYING_WAIT' then '申请等待中'
         when 'INTERCEPT_DONE' then '仓库拦截成功'
         when 'INTERCEPT_FAILTURE' then '仓库拦截失败'
         when 'MODIFY_DONE' then '仓库修改信息成功'
         when 'CANCEL_DONE' then '仓库取消成功'
         when 'TASK_INITIALIZED' then '申请初始化'
         when 'MODIFY_FAILTURE' then '仓库修改信息失败'
         when 'RECEIVED' then '仓库已接收'
         when 'WAITTING' then '等待处理'
         when 'CANCELED' then '取消成功'
         when 'CANCELLED' then '取消成功'
         else b.task_status end as task_status,
    current_timestamp as insert_timestamp
from
(
    select
        purchase_order_number,
        order_time,
        store_cd,
        order_def_ware_house,
        order_actual_ware_house,
        internal_status,
        logistics_shipping_company,
        logistics_number,
        logistics_shipping_time
    from
        DW_OMS.DWS_Purchase_Order
    where
        split_type <> 'SPLIT_ORIGIN'
    and
        basic_status <> 'DELETED'
    and 
        store_cd <> 'GWP001'
    and 
        type_cd<>2
    and 
        item_sku_cd is not null
)a
left join
(
    select 
        source_order_no,
        apply_type,
        task_status
    from
        STG_OMS.Sap_Order_Cancel_Task
    where 
        basic_status<>'DELETED'
) b
on 
    a.purchase_order_number = b.source_order_no
left join
(
    select distinct 
        purchase_order_number,
        place_time
    from
        dw_oms.RPT_Sales_Order_SKU_Level
) c
on 
    a.purchase_order_number = c.purchase_order_number
;
UPDATE STATISTICS DW_OMS.RPT_Purchase_Order_Status;
END
GO
