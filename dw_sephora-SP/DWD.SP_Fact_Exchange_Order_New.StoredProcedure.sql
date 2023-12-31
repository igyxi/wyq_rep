/****** Object:  StoredProcedure [DWD].[SP_Fact_Exchange_Order_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Exchange_Order_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-16       wangzhichun           Initial Version
-- 2023-06-27       wangzhichun           update new oms
-- ========================================================================================
truncate table DWD.Fact_Exchange_Order_New;
insert into DWD.Fact_Exchange_Order_New
select  o.source_bill_no as sales_order_number
            ,o.bill_no as purchase_order_number
            ,null as related_order_number
            ,o.pos_invoice_id as invoice_id
            ,case when o.distribution_state = 0 then N'待预检'
                  when o.distribution_state = 1 then N'等待适配快递'
                  when o.distribution_state = 2 then N'等待下发仓'
                  when o.distribution_state = 3 then N'发货异常挂起'
                  when o.distribution_state = 6 then N'已发货'
                  when o.distribution_state = 8 then N'已签收'
                  when o.distribution_state = 9 then N'已作废'
                  when o.distribution_state = 10 then N'取消'
                  when o.distribution_state = 11 then N'异常'
                  when o.distribution_state = 12 then N'等待路由'
                  when o.distribution_state = 13 then N'订单待下发'
                  when o.distribution_state = 14 then N'等待仓库处理'
                  when o.distribution_state = 15 then N'缺货'
                  when o.distribution_state = 16 then N'拒收'
            end as order_status
            ,o.front_order_type as type_code
            ,o.member_id
            ,o.member_card_no as member_card
            ,o.front_shop_code as sub_channel_code
            ,si.channel_id as channel_code 
            ,store.store_code as store_code
            ,bill_date as order_time
            ,o.delivery_time as shipping_time
            ,amount_total as payment_amount
            ,item.activity_type as sub_type_code
            ,null as is_smartba
            ,item.item_sku_code
            ,eb_sku_name_cn as item_sku_name
            ,item.item_type as item_type
            ,item.item_quantity item_quantity
            ,item.item_sale_price as item_sale_price    
            ,item.item_apportion_amount as item_apportion_amount
            ,item.item_discount_amount as item_discount_amount
            ,exchange.original_sku as exchange_sku_code
            ,CURRENT_TIMESTAMP as insert_timestamp
    from 
        ODS_OMS_Order.OMS_Retail_Order_Bill o
    left    join
	(
		select 	retail_order_bill_id
				,activity_type
                ,case when gift_type = '1' then N'NORMAL'
                    when gift_type = '2' then N'FREE_SAMPLE'
                    when gift_type = '3' then N'VALUE_SET'
                    when gift_type = '4' then N'GWP'
                    when gift_type = '7' then N'VE'
                    when gift_type = '99' then N'BUNDLE'
                    else gift_type
                    end as item_type
				,sum(qty) as item_quantity
                ,max(price) as item_sale_price
				,sku_code as item_sku_code
				,sum(share_payment) as item_apportion_amount
				,sum(coalesce(merchant_discount_fee, 0)  + coalesce(platform_discount_fee, 0)) as item_discount_amount
		from 	ODS_OMS_Order.OMS_Retail_Goods_Detalis
		group   by retail_order_bill_id,sku_code,activity_type,gift_type
	) item
    on      o.id = item.retail_order_bill_id
    left join 
        ODS_OMS_Order.OMS_Store_Info si 
    on o.store_id=si.store_id
    left join 
    (
        select 
            chasing_order_bill_no,original_sku,sku
        from 
            ODS_OMS_Order.ORD_Retail_Return_Chasing_Gds_De 
        group by chasing_order_bill_no,original_sku,sku
    ) exchange
    on exchange.chasing_order_bill_no=o.bill_no and item.item_sku_code=sku
    left join 
        DWD.DIM_SKU_Info info 
    on item.item_sku_code=info.sku_code
    left join 
        ODS_OMS_Order.ORD_Retail_ORD_DIS_Info addr
    on addr.bill_no=o.bill_no
    left join 
        ODS_OIMS_Support.Bas_Warehouse warehouse
    on  addr.ware_house_real_id = warehouse.id
    left join 
        ODS_OMS_Order.OMS_Store_Mapping store
    on      o.store_id = store.store_id
    and     warehouse.code = store.warehouse
 	where   o.is_plit <> '1'
    and     o.front_order_type =2
    and     (o.distribution_state <> '9' or o.distribution_state is null)
END

GO
