/****** Object:  StoredProcedure [TEMP].[SP_RPT_Presale_Order_BK]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Presale_Order_BK] AS
BEGIN
truncate table [DW_OMS].[RPT_Presale_Order];
insert into [DW_OMS].[RPT_Presale_Order]
select distinct
    so.sales_order_number,
    po.purchase_order_number,
    a.payed_deposit_payment_no,
    b.payed_balance_payment_no,
    so.order_amount,
    so.payed_amount,
    null as payable_deposit_amount,
    a.payed_deposit_amount as payed_deposit_amount,
    null as payable_balance_amount,
    b.payed_balance_amount as payed_balance_amount,
    so.payment_status_cd as payment_status_cd,
    po.internal_status as po_internal_status_cd,
    a.payed_deposit_time as payed_deposit_time,
    b.payed_balance_time as payed_balance_time,
    po.logistics_number as logistics_number,
	cm.name as logistics_shipping_company,
	case when so.payment_status_cd = 1 then N'已付尾款待发货' 
	     when so.payment_status_cd = 2 and so.[internal_status_cd] = 'CANCELLED' then N'已付订金未付尾款超时'
	     when so.payment_status_cd = 2 and so.[internal_status_cd] <> 'CANCELLED' then N'已付订金待付尾款' 
	     else '' 
    end COLLATE Chinese_PRC_CS_AI_WS as order_payment_status
    --po.logistics_shipping_company as logistics_shipping_company
    --,current_timestamp
from 
    (
        select
            sales_order_sys_id,
            sum(payment_amoutn) as payed_deposit_amount,
            max(payment_time) as payed_deposit_time,
            --GROUP_CONCAT(payment_time) as payed_deposit_time,
            payment_type,
            max(payment_no) as payed_deposit_payment_no
            --GROUP_CONCAT(payment_no) as payment_no
        from
            STG_OMS.Sales_Order_Payment a
        WHERE 
            payment_type = '2'
        group by sales_order_sys_id,payment_type
    )a
left join
    (
        select
            sales_order_sys_id,
            sum(payment_amoutn) as payed_balance_amount,
            max(payment_time) as payed_balance_time,
            --GROUP_CONCAT(payment_time) as payed_balance_time,
            payment_type,
            max(payment_no) as payed_balance_payment_no
            --GROUP_CONCAT(payment_no) as payment_no
        from
            STG_OMS.Sales_Order_Payment a
        WHERE 
            payment_type = '3'
        group by sales_order_sys_id,payment_type
    )b
on a.sales_order_sys_id = b.sales_order_sys_id
inner join
    (
        select
            sales_order_number,
            sales_order_sys_id,
            order_amount,
            payed_amount,
            payment_status_cd,
			[internal_status_cd]
        from
            DW_OMS.RPT_Sales_Order_Basic_Level
        where
            store_cd = 'S001'
        and 
            type_cd = 7
        and order_date>='2021-05-24'
    ) so
on a.sales_order_sys_id = so.sales_order_sys_id
left join
    (
        select 
            purchase_order_number,
            sales_order_number,
            internal_status,
            logistics_number,
            logistics_shipping_company
        from 
            DW_OMS.DWS_Purchase_Order
        where 
            split_type <> 'SPLIT_ORIGIN'
        and
            store_cd = 'S001'
    ) po
on so.sales_order_number = po.sales_order_number
left join DW_Common.DIM_Logistics_Company_Mapping cm
on po.logistics_shipping_company = cm.code collate SQL_Latin1_General_CP1_CI_AS;
--order by so.sales_order_number,po.purchase_order_number
end

GO
