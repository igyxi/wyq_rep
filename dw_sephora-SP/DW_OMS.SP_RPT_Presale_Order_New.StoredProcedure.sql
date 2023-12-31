/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_Presale_Order_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_Presale_Order_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-02-22       houshuangqiang     replace STG_OMS.Sales_Order_Payment/DW_OMS.RPT_Sales_Order_Basic_Level/DW_OMS.DWS_Purchase_Order
-- 2023-06-05       wangzhichun        change new oms order_status
-- ========================================================================================
truncate table [DW_OMS].[RPT_Presale_Order_New];
insert into [DW_OMS].[RPT_Presale_Order_New]
select distinct
    o.sales_order_number,
    o.purchase_order_number,
    a.payed_deposit_payment_no,
    b.payed_balance_payment_no,
    o.payment_amount as order_amount,
    o.payment_amount as payed_amount, -- 从数据上看支付金额和订单金额是一样的
    null as payable_deposit_amount,
    a.payed_deposit_amount as payed_deposit_amount,
    null as payable_balance_amount,
    b.payed_balance_amount as payed_balance_amount,
    o.payment_status as payment_status_cd,
    so_order_status  as so_internal_status_cd,
    po_order_status  as po_internal_status_cd,
    -- o.order_status as po_internal_status_cd,
    a.payed_deposit_time as payed_deposit_time,
    b.payed_balance_time as payed_balance_time,
    o.logistics_number as logistics_number,
    o.logistics_company as logistics_shipping_company,
    case when o.payment_status = 1 then N'已付尾款待发货'
         when o.payment_status = 2 and coalesce(po_order_status,so_order_status) IN (N'取消','TRADE_CLOSED','TRADE_CANCELED') then N'已付订金未付尾款超时'
         when o.payment_status = 2 and coalesce(po_order_status,so_order_status) NOT IN (N'取消','TRADE_CLOSED','TRADE_CANCELED') then N'已付订金待付尾款'
         else ''
    end as order_payment_status
from
(
    select  sales_order_number,
            sum(payment_amount) as payed_deposit_amount,
            max(payment_time) as payed_deposit_time,
            payment_type,
            max(payment_no) as payed_deposit_payment_no
    from    DWD.Fact_Payment_Order
    WHERE   payment_type = '2'
    group   by sales_order_number,payment_type
 )a
left join
(
    select  sales_order_number,
            sum(payment_amount) as payed_balance_amount,
            max(payment_time) as payed_balance_time,
            payment_type,
            max(payment_no) as payed_balance_payment_no
    from    DWD.Fact_Payment_Order
    where   payment_type = '3'
    group   by sales_order_number,payment_type
)b
on a.sales_order_number = b.sales_order_number
inner join
(
    select  distinct
            sales_order_number
            ,purchase_order_number
            ,payment_amount
            ,payment_status
            ,so_order_status
            ,po_order_status
            ,logistics_number
			,logistics_company
    from    [DWD].[Fact_OMS_Sales_Order_New]
    where   channel_code = 'SOA'
    and     source='NEW OMS'
    and     type_code = 7
    and     format(order_time, 'yyyy-MM-dd') >='2021-05-24'
) o
on 	a.sales_order_number = o.sales_order_number
-- left join DW_Common.DIM_Logistics_Company_Mapping cm
-- on o.logistics_company = cm.code
end
GO
