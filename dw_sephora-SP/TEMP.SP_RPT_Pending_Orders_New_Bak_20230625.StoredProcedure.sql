/****** Object:  StoredProcedure [TEMP].[SP_RPT_Pending_Orders_New_Bak_20230625]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Pending_Orders_New_Bak_20230625] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-25       tali           delete collate
-- 2022-03-31       wangzhichun    add sotre_cd & type_code
-- 2023-03-07       houshuangqiang channge source table
-- 2023-03-28       wangzhichun    channge source table
-- 2023-05-06       zhailonglong   change po_sys_create_time logic
-- 2023-06-07       wangzhichun    update new oms order_status
-- ========================================================================================
delete from [DW_OMS].[RPT_Pending_Orders_New] where [dt] =@dt;
insert into [DW_OMS].[RPT_Pending_Orders_New]
select
    case when channel_code='SOA' THEN 'S001' ELSE sub_channel_code  end store_cd,                    --店铺
    case when sub_channel_code='TMALL006' then 'TMALL_WEI'
        when sub_channel_code='TMALL004' then 'TMALL_CHALING'
        when sub_channel_code='TMALL005' then 'TMALL_PTR'
        when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
        when sub_channel_code='DOUYIN001' then 'DOUYIN'
        when sub_channel_code='REDBOOK001' then 'REDBOOK'
        when sub_channel_code='JD003' then 'JD_FCS'
        when sub_channel_code in ('JD001','JD002') then 'JD'
        when sub_channel_code='GWP001' then 'OFF_LINE'
        else sub_channel_code 
        end  as channel_code                 --渠道
   ,o.sales_order_number         --平台订单
   ,o.purchase_order_number      --sap订单号
   ,case
        when o.type_code is null then o.type_code
        else o.type_code
    end as type_code
   ,o.order_time                 --下单时间
   ,o.payment_time               -- 支付时间
   ,o.place_time                 --有效支付时间
   ,case
        when isnull(o.type_code, o.type_code) = 3 and
            o.payment_status = 1 then payment_time
        else null
    end as balance_payment_time     -- 尾款支付时间
   ,case
        when o.type_code = 7 then logistics.order_shipping_time
        else o.shipping_time
    end as shipping_time           -- 预计发货时间
   --,o.po_sys_create_time         --sap创建时间 -- 缺字段
   --,o.split_type_code              --拆分类型 -- 缺缺字段
  ,o.sys_create_time as po_sys_create_time
   ,'' as split_type_code                 -- 原逻辑是 split_type_cd
   ,case when o.purchase_order_number is not null then item_apportion_amount
         when o.purchase_order_number is null then payment_amount
    end  as payed_amount             --支付总额
   ,o.so_order_status        --so订单状态
   ,o.po_order_status        --po订单状态
   ,o.item_sku_name
   ,o.item_sku_code
   ,o.actual_warehouse as order_actual_ware_house       --实际发货仓库 
   ,o.def_warehouse as order_def_ware_house       -- 默认发货仓库
   ,case
        when coalesce(o.po_order_status,o.so_order_status) in (N'WAIT_BUYER_PAY',N'等待路由') and o.type_code = 3 and logistics.order_shipping_time <= @dt then N'预售_缺库存'
        when type_code = 7 and o.payment_status = 2 then N'定金预售_等待尾款'
        when coalesce(o.po_order_status,o.so_order_status) in (N'等待仓库处理') then N'等待SAP处理'  --NEW OMS中没有对应STG_OMS.Purchase_Order_EXT表，无法判断_取消和_更改，
        -- when o.order_status = 'WAIT_SAPPROCESS' and t.apply_type != 'MODIFY_ADDRESS_APPLY' and t.apply_type is not null then N'等待SAP处理_取消'
        -- when o.order_status = 'WAIT_SAPPROCESS' and t.apply_type = 'MODIFY_ADDRESS_APPLY' then N'等待SAP处理_更改'
        -- when o.order_status = 'WAIT_SAPPROCESS' and t.apply_type != 'MODIFY_ADDRESS_APPLY' and t.apply_type is null and dateadd(hour, 24, o.pos_sync_time) >= @dt then N'等待SAP处理_未关闭'
        -- when o.order_status = 'WAIT_SAPPROCESS' and t.apply_type != 'MODIFY_ADDRESS_APPLY' and t.apply_type is null and @dt > dateadd(hour, 24, o.pos_sync_time) then N'等待SAP处理_未关闭_超时'
        when coalesce(o.po_order_status,o.so_order_status) =N'异常' then N'异常'
        when coalesce(o.po_order_status,o.so_order_status) =N'取消' then N'其他'
        when coalesce(o.po_order_status,o.so_order_status)  in (N'等待适配快递','WAIT_BUYER_CONFIRM_GOODS',N'等待路由') then N'其他'   --等待数据进入对逻辑做判断
    end as pending_reason
   ,datediff(hour,case when type_code = 7 and o.payment_status = 1 then logistics.order_shipping_time else o.place_time end, dateadd(day, 0, cast(format(getdate(), 'yyyy-MM-dd') as datetime))) as [delivery_pending_days]
   ,@dt as dt
   ,o.province
   ,o.city
   ,o.district
from    
    DWD.Fact_OMS_Sales_Order_New o
-- left    join
-- (
--     select distinct purchase_order_number,apply_type from STG_OMS.Purchase_Order_EXT
-- ) t
-- on      o.purchase_order_number = t.purchase_order_number
left    join
(
    select sales_order_number,purchase_order_number,logistics_number,order_shipping_time,create_time from DWD.Fact_Logistics_Order_New
) logistics
on      o.purchase_order_number = logistics.purchase_order_number
where   o.source = 'OMS'
and     (o.is_placed = 1 or type_code in (7,9) or (o.sub_channel_code = 'GWP001' and type_code in (12,5)))
and     ((o.purchase_order_number is not null
and     coalesce(o.po_order_status,o.so_order_status) in ( N'等待仓库处理', N'异常', N'等待适配快递',N'等待路由'))
or      (o.purchase_order_number is null
and     coalesce(o.po_order_status,o.so_order_status) in ('WAIT_BUYER_PAY','WAIT_BUYER_CONFIRM_GOODS',N'异常')))
and     coalesce(o.item_sku_code,'')<>'TRP001'
;
END

GO
