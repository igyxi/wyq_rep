/****** Object:  StoredProcedure [DW_OMS].[SP_DW_OMS_Partial_Cancel_Order_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DW_OMS_Partial_Cancel_Order_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-06       houshuangqiang           Initial Version
-- ======================================================================================
truncate table DW_OMS.DW_OMS_Partial_Cancel_Order_New;
insert into DW_OMS.DW_OMS_Partial_Cancel_Order_New
select  po.sales_order_number
        ,po.purchase_order_number
        ,po.purchase_order_number as invoice_no
        ,sap.invoice_id
        ,po.channel_id as channel_code
        ,store.channel_name
        ,case when po.store_id = 'S001' then po.channel_id
              when po.store_id = 'TMALL001' and po.shop_id = 'TM2' then 'TMALL006'
              else po.store_id
        end as sub_channel_code
        ,case
            when po.store_id = 'S001' then po.channel_id
            when po.store_id = 'TMALL001' and po.shop_id = 'TM2' then N'天猫WEI旗舰店'
            else store.store_name
        end as sub_channel_name
        ,store1.store_code
        ,address.province
        ,address.city
        ,address.district
        ,po.type_code
        ,po.sub_type_code
        ,po.member_id
--        ,po.member_card
--        ,so.member_card_grade
        ,case when store.channel_id = 'JD' and po.member_card like 'JD%' then substring(po.member_card, 3, len(po.member_card) - 2) else po.member_card end as member_card
        ,coalesce(so.member_card_grade, orders.group_name) as member_card_grade
        ,so.payment_status
        ,so.payment_amount
        ,po.order_status
        ,so.order_time
        ,so.payment_time
        ,0 as is_placed -- 部分取消订单的sku商品，一定是没有完成的
        ,so.place_time
        ,case when so.smartba_flag is not null then so.smartba_flag
              when source.order_id is not null and po.channel_id = 'MINIPROGRAM' then 1
              else 0
         end as smartba_flag
        ,cancel.item_sku_code
        ,cancel.item_sku_name
        ,cancel.item_quantity
        ,cancel.item_sale_price
        ,cancel.item_total_amount
        ,cancel.item_apportion_amount
        ,cancel.item_discount_amount
        ,cancel.virtual_sku_code
        ,null as virtual_quantity
        ,null as virtual_apportion_amount
        ,null as virtual_discount_amount
        ,po.logistics_company
        ,po.logistics_number
        ,po.shipping_time
        ,po.shipping_amount
        ,po.def_warehouse
        ,po.actual_warehouse
        ,sap.pos_sync_time
        ,sap.pos_sync_status
        ,current_timestamp as insert_timestamp
from
(
    select  sales_order_sys_id
            ,sales_order_number
            ,purchase_order_sys_id
            ,purchase_order_number
            ,channel_id
            ,store_id
            ,shop_id
            ,member_id
            ,member_card
            ,[type] as type_code
            ,merge_flag as sub_type_code
            ,order_internal_status as order_status
            ,order_def_ware_house as def_warehouse
            ,order_actual_ware_house as actual_warehouse
--            ,order_time
            ,shipping_time
--            ,order_shipping_time
--            ,sign_time
--            ,payed_amount -- payment_amount支付金额，用po单中的支付金额，还是so单中的支付金额，这两个金额不一样
            ,shipping_total as shipping_amount
            ,logistics_shipping_company as logistics_company
            ,logistics_number
            ,row_number() over(partition by purchase_order_number order by sys_create_time desc) rownum
    from    STG_OMS.Purchase_Order
    where   coalesce(split_type, 'SPLIT_ORIGIN') <> 'SPLIT_ORIGIN' -- split_type=SPLIT_ORIGIN 和null的需要过滤掉
    and     basic_status = 'DELETED'
    and     order_internal_status = 'PARTAIL_CANCEL'
) po -- PO单部分取消订单
left  join
(
    select  sales_order_sys_id
            ,member_id
            ,member_card
            ,member_card_grade
            ,payed_amount as payment_amount
            ,payment_status
            ,payment_time
            ,order_time
            ,case when type = 8 then order_time
                  else coalesce(payment_time, order_time)
             end as place_time
            ,smartba_flag
--            ,row_number() over(partition by purchase_order_number order by sys_create_time desc) rownum
    from    STG_OMS.Sales_Order
) so
on      po.sales_order_sys_id = so.sales_order_sys_id
left  join
(
    select   --purchase_order_sys_id -- 存在空值
    		 sales_order_number
    		 ,purchase_order_number
             ,item_sku as item_sku_code
             ,item_name as item_sku_name
             ,sum(item_rg_quantity) as item_quantity -- 取消数量
             ,item_sale_price
             ,sum(abs(apportion_amount)) as item_apportion_amount
             ,sum(abs(item_adjustment_total)) as item_discount_amount
             ,sum(abs(apportion_amount)) + sum(abs(item_adjustment_total)) as item_total_amount
             ,virtual_sku as virtual_sku_code
    from     STG_OMS.OMS_Partial_Cancel_Item
    group    by sales_order_number,purchase_order_number,item_sku,item_name,item_sale_price,virtual_sku
) cancel
--on      po.purchase_order_sys_id = cancel.purchase_order_sys_id
on     po.sales_order_number = cancel.sales_order_number
and    (po.purchase_order_number = cancel.purchase_order_number or cancel.purchase_order_number is null)
left join
(
    select 	purchase_order_sys_id
			,case when coalesce(mapping.crm_province, N'其他') = N'其他' then addr.province
				-- when coalesce(mapping.crm_province N'其他') = '' then addr.province
				else mapping.crm_province
			end as province
			,case when coalesce(mapping.crm_city, N'其他') = N'其他' then addr.city
				else mapping.crm_city
			end as city
			,addr.district
			,row_number() over(partition by purchase_order_sys_id order by create_time desc) rownum
    from 	STG_OMS.Purchase_Order_Address addr
    left 	join STG_OMS.OMS_Province_City_Mapping mapping
    on 		addr.province = mapping.oms_province
    and 	addr.city = mapping.oms_city
    where   addr.purchase_order_sys_id is not null
) address
on      po.purchase_order_sys_id = address.purchase_order_sys_id
and     address.rownum = 1
left    join  STG_OMS.Purchase_To_SAP sap
on      po.purchase_order_sys_id = sap.purchase_order_sys_id

--left    join DWD.DIM_Store store -- 最终用DIM_Store表
--on
left    join STG_OMS.OMS_Store_Info store
on      case when po.store_id = 'TMALL001' and po.shop_id = 'TM2' then 'TMALL006' else po.store_id end = store.store_id
left    join  STG_OMS.OMS_Store_Mapping store1
on      po.store_id = store1.store_id
and     po.actual_warehouse = store1.warehouse
left    join
(
    select order_id, group_name from STG_Order.Orders where group_name <> 'O2O'
) orders
on      po.sales_order_number = orders.order_id
left    join
(
    select  order_id
    from    STG_Order.Order_Source
    where   utm_campaign = 'BA'
    and     utm_medium ='seco'
    group   by order_id
) source
on      po.sales_order_number = source.order_id
where   po.rownum = 1
END
GO
