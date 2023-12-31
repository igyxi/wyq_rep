/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_OMS_Sales_Order_With_SKU_Bak_20230619]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_OMS_Sales_Order_With_SKU_Bak_20230619] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       houshuangqiang     Initial Version
-- 2023-02-16       houshuangqiang     update OMS_STD_Trade main table
-- 2023-04-12       houshuangqiang     add column
-- 2023-04-20       houshuangqiang     add column joint_order_number & item_sale_price
-- 2023-04-24       zeyuan             修改主题域
-- 2023-05-08       houshuangqiang     add STG_Order.Order
-- 2023-05-16       houshuangqiang     add TRP001
-- 2023-05-18       houshuangqiang     add address mapping
-- 2023-06-05       houshuangqiang     add po_order_status
-- 2023-06-05       wangzhichun        update province、city、district
-- 2023-06-14       houshuangqiang     add trade_from 排除O2O中的订单数据 & add sys_create_time/sys_update_time
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
truncate table DW_OMS_Order.DW_OMS_Sales_Order_With_SKU;
with so_order as
(
    select  so.tid as sales_order_number
            ,so.merge_no as joint_order_number
            ,case when so.tid = so.merge_no then 1 else null end sub_type_code
            -- ,so.bill_no as purchase_order_number
            ,case when upper(so.platform) = 'TAOBAO' then 'TMALL'
                  when upper(so.platform) = 'JINGDONG' then 'JD'
                  when upper(so.platform) = 'DOUYINXIAODIAN' then 'DOUYIN'
                  when upper(so.platform) = 'XIAOHONGSHU' then 'REDBOOK'
                  else upper(so.platform)
             end as channel_code
            ,case when upper(so.platform) = 'TAOBAO' then N'天猫'
                  when upper(so.platform) = 'JINGDONG' then N'京东'
                  when upper(so.platform) = 'DOUYINXIAODIAN' then N'抖音'
                  when upper(so.platform) = 'XIAOHONGSHU' then N'小红书'
                  when upper(so.platform) = 'SOA' then N'官网'
                  when upper(so.platform) = 'OFF_LINE' then N'线下'
             end as channel_name
			,case when so.shop_code = 'S001' then so.channel_id
				  else so.shop_code
			end as sub_channel_code
			,case when so.shop_code = 'S001' then so.channel_id
				 else channel.name
			end as sub_channel_name
            ,so.shop_code -- 关联mapping表
            -- ,so.store_id as store_id
--            ,so.store_number
            ,trim(customer_id) as member_id
            ,case when so.channel_id = 'JD' and so.vip_card_no like 'JD%' then SUBSTRING(so.vip_card_no, 3, len(so.vip_card_no)-2) else so.vip_card_no end as member_card
            ,coalesce(case when so.member_level_name = 'GOLDEN' then 'GOLD' else so.member_level_name  end, o.group_name)  as member_card_grade
            ,case when so.smart_BA_flag is not null then so.smart_BA_flag
                  when os.order_id is not null and so.channel_id = 'MINIPROGRAM' then 1
                  else 0
             end as smartba_flag
            ,so.created as order_time
            ,so.pay_time as payment_time
            ,so.payment as payment_amount
            ,case when so.pay_status = 1 then 2
		  when so.pay_status = 2 then 1
		  else so.pay_status  -- 枚举类型和老oms是相反的，需要转换回去。
	    end as payment_status
            ,so.status as order_status
            ,so.front_order_type as type_code
			,case when so.shop_code not in ('TMALL002', 'GWP001')
				  and so.front_order_type not in ('2', '9') -- 老oms order_type的枚举是2,9
				  and ((so.pay_status = 2 or so.pay_time is not null) or so.front_order_type = '8')
				  and (so.total_fee - coalesce(item.merchant_discount_fee, 0)) > 1 then 1
				  else 0
			end is_placed
			,case when so.front_order_type = '8' then so.created else coalesce(so.pay_time, so.created) end as place_time
            -- ,so.receiver_state as province
            -- ,so.receiver_city as city
            -- ,so.receiver_district as district
            ,case 
                when trim(lower(so.receiver_state)) in ('null', '') then null 
                when t1.province_short_name is not null then t1.province_short_name
                else trim(so.receiver_state)
            end as province
            ,case 
                when trim(lower(so.receiver_city)) in ('null', '') then null 
                when t2.city_short_name is not null then t2.city_short_name
                when t3.city_short_name is not null then t3.city_short_name
                else trim(so.receiver_city)
            end as city
            ,case 
                when trim(lower(so.receiver_district)) in ('null', '') then null 
                when t3.district_short_name is not null then t3.district_short_name
                when t4.district_short_name is not null then t4.district_short_name
                else trim(so.receiver_district) 
            end as district
    from    ODS_New_OMS.OMS_STD_Trade so
    inner  	join  stg_oms.oms_to_oims_sync_fail_log fail
    on     	so.tid = fail.sales_order_number
    and   	fail.sync_status = 1
	and   	fail.update_time >= @start_time
    and   	fail.update_time <= @end_time
	left 	join
	(
		select 	tid
			,sum(merchant_discount_fee) as merchant_discount_fee
		from 	 ODS_New_OMS.OMS_STD_Trade_Item
		where 	data_update_time >=  @start_time
		and 	data_update_time <= @end_time
		group 	by tid
	)	item
	on 		so.tid = item.tid
    left    join ODS_OIMS_Support.Bas_Channel channel
    on      so.shop_id = channel.id
	left 	join
	(
		select order_id, group_name from STG_Order.Orders where group_name <> 'O2O'
	) o
	on 	so.tid = o.order_id
	left 	join
	(
		select order_id from STG_Order.Order_Source where utm_campaign = 'BA'and utm_medium ='seco' group by order_id
	) os
	on  so.tid = os.order_id
    left join 
    (
        select distinct province_name,province_short_name from DW_Common.DIM_Area
    ) t1
    on trim(so.receiver_state) = t1.province_name
    left join 
        (select distinct province_short_name, city_name, city_short_name from DW_Common.DIM_Area) t2
    on (case when t1.province_short_name is not null then t1.province_short_name else trim(so.receiver_state) end) = t2.province_short_name
    and trim(so.receiver_city) = t2.city_name
    left join
        (select distinct province_short_name, city_short_name, district_name, district_short_name from DW_Common.DIM_Area) t3
    on (case when t1.province_short_name is not null then t1.province_short_name else trim(so.receiver_state) end) = t3.province_short_name
    and trim(so.receiver_city) = t3.district_name
    left join 
        (select distinct province_short_name, district_name, district_short_name from DW_Common.DIM_Area) t4
    on (case when t1.province_short_name is not null then t1.province_short_name else trim(so.receiver_state) end) = t4.province_short_name
    and trim(so.receiver_district) = t4.district_name
    where  trade_from in ('taobao','jingdong','douyinxiaodian','SOA', 'other')
 	-- where 	so.data_update_time >= @start_time
 	-- and 	so.data_update_time <= @end_time
    -- where   so.platform in ('jingdong','SOA','xiaohongshu','OFF_LINE','douyinxiaodian','taobao')
),

po_order as
(
    select  o.source_bill_no as sales_order_number
            ,o.bill_no as purchase_order_number
		,o.bill_no as invoice_no
            ,o.pos_invoice_id as invoice_id
            ,o.front_order_type as type_code
        --     ,case  when item.activity_type = 3 and o.is_plit = 1 then 3
        --            when item.activity_type = 3 and o.is_plit_new = 1 then 3
        --            when item.activity_type = 3 and o.is_plit = 0 and o.is_plit_new = 0 then 2
        --      end as sub_type_code
        --     ,case when item.activity_type = 3 and o.is_plit = 0 then 2 else item.activity_type end as sub_type_code
            ,item.activity_type as sub_type_code
            ,o.member_card_no as member_card
            ,case when o.member_level_name = 'GOLDEN' then 'GOLD' else o.member_level_name end as member_card_grade
            ,case when o.pay_state = 0 then N'支付状态'
                  when o.pay_state = 1 then N'部分付款'
                  when o.pay_state = 2 then N'已付款'
             end as payment_status
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
			,item.item_sku_code
			,null as item_sku_name
            ,sum(item.item_quantity) as item_quantity
            ,max(item.item_sale_price) as item_sale_price
--            ,sum(item.amount) as item_total_amount
            ,sum(item.item_apportion_amount) + sum(item.item_discount_amount) as item_total_amount
            ,sum(item.item_apportion_amount) as item_apportion_amount
            ,sum(item.item_discount_amount) as item_discount_amount
            ,max(item.virtual_sku_code) as virtual_sku_code
--            ,sum(item.qty) as virtual_quantity
--            ,sum(item.vb_qty) as virtual_quantity
--            ,sum(item.vb_total_amount) as virtual_apportion_amount
--            ,sum(item.virtual_discount_amount) as virtual_discount_amount
            ,sum(item.virtual_quantity) as virtual_quantity
            ,sum(item.virtual_apportion_amount) as virtual_apportion_amount
            ,sum(item.virtual_discount_amount) as virtual_discount_amount
            ,o.delivery_time as shipping_time
            ,o.express_fee as shipping_amount
            ,o.push_pos_time as pos_sync_time
            ,o.push_pos as pos_sync_status     -- 推送pos 0-待推送，1-推送成功，2-推送失败
            ,o.data_create_time as sys_create_time
            ,o.data_update_time as sys_update_time
    from    ODS_New_OMS.OMS_Retail_Order_Bill o
    left    join
	(
		select 	retail_order_bill_id
				,activity_type
				,sum(qty) as item_quantity
--				,price as item_sale_price
                        -- ,max(price_tag) as item_sale_price
                        ,max(price) as item_sale_price
				--,amount
				,sku_code as item_sku_code
				,sum(share_payment) as item_apportion_amount
				,sum(coalesce(merchant_discount_fee, 0)  + coalesce(platform_discount_fee, 0)) as item_discount_amount
				,max(vb_code) as virtual_sku_code
--                ,vb_code
--				,vb_qty
--				,vb_total_amount
--				,coalesce(vb_origin_price, 0) - coalesce(vb_total_amount, 0) as virtual_discount_amount
                ,sum(case when substring(vb_code, 1, 1) = 'V' then qty else 0 end) as virtual_quantity
                ,sum(case when substring(vb_code, 1, 1) = 'V' then share_payment else 0 end) as virtual_apportion_amount
                ,sum(case when substring(vb_code, 1, 1) = 'V' then coalesce(merchant_discount_fee, 0)  + coalesce(platform_discount_fee, 0) else 0 end) as virtual_discount_amount
		from 	ODS_New_OMS.OMS_Retail_Goods_Detalis
 		where 	data_update_time >=  @start_time
		and   	data_update_time <= @end_time
		group   by retail_order_bill_id,sku_code,activity_type
		union 	all
		select  id as retail_order_bill_id
				,activity_type
				,1 as item_quantity
				,0 as item_sale_price
				--,0 as amount
				,'TRP001' as item_sku_code
				,express_fee as item_apportion_amount
				,0 as item_discount_amount
				,null as virtual_sku_code
--				,0 as vb_qty
--				,0 as vb_total_amount
--				,0 as virtual_discount_amount
				,0 as virtual_quantity
				,0 as virtual_apportion_amount
				,0 as virtual_discount_amount
		from 	ODS_New_OMS.OMS_Retail_Order_Bill
		where front_order_type <> 2
		and 	express_fee > 0
		and   is_plit <> '1'
            and   distribution_state <> '9'
    --	and 	coalesce(is_plit, 0) = 0
    --	and 	is_plit_new = 1
		and 	data_update_time >=  @start_time
		and   	data_update_time <= @end_time
	) item
    on      o.id = item.retail_order_bill_id
    --left    join ODS_OIMS_Goods.Gds_Btsinglprodu sku
    --on      item.outer_sku_id = sku.code
    --on      item.singleproduct_id = sku.id
 	where 	o.data_update_time >=  @start_time
 	and 	o.data_update_time <= @end_time
	and   o.is_plit <> '1'
      and   o.front_order_type <> 2
      and   o.distribution_state <> '9'
--	and 	coalesce(o.is_plit, 0) = 0
--	and 	o.is_plit_new = 1
--		and     is_plit <> '1'
	group 	by o.source_bill_no,o.bill_no,o.bill_no,o.pos_invoice_id,o.front_order_type,o.member_card_no,o.activity_type,
                case when o.member_level_name = 'GOLDEN' then 'GOLD' else o.member_level_name end,
                case when o.pay_state = 0 then N'支付状态' when o.pay_state = 1 then N'部分付款' when o.pay_state = 2 then N'已付款' end,
                case when o.distribution_state = 0 then N'待预检'
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
            end,
	item.item_sku_code,o.delivery_time,o.express_fee,o.push_pos_time,o.push_pos,item.activity_type,o.data_create_time,o.data_update_time
        --,case when item.activity_type = 3 and is_plit = 0 then 2 when item.activity_type = 3 and is_plit = 1 then 3 end
        -- ,case when item.activity_type = 3 and o.is_plit = 0 then 2 else item.activity_type end

),

-- 获取发货仓
warehouse as
(
    select  addr.purchase_order_number
            ,delivery.name as logistics_company
            ,addr.logistics_number
            ,def_warehouse.code as def_warehouse
            ,real_warehouse.code as actual_warehouse
    from
    (
         select bill_no as purchase_order_number
                ,delivery_type_id
                ,trim(delivery_no) as logistics_number
                ,ware_house_default_id
                ,ware_house_real_id
        from    ODS_New_OMS.ORD_Retail_ORD_DIS_Info
 		where 	data_update_time >=  @start_time
 		and 	data_update_time <= @end_time
        group   by bill_no,delivery_type_id,delivery_no,ware_house_default_id,ware_house_real_id
    ) addr
    left    join ODS_OIMS_Support.Bas_Delivery_Type delivery
    on      addr.delivery_type_id = delivery.id
    and     delivery.status = '09'
    left    join ODS_OIMS_Support.Bas_Warehouse def_warehouse
    on      addr.ware_house_default_id = def_warehouse.id
    left    join ODS_OIMS_Support.Bas_Warehouse real_warehouse
    on      addr.ware_house_real_id = real_warehouse.id
)

insert into DW_OMS_Order.DW_OMS_Sales_Order_With_SKU
select  distinct
        so.sales_order_number
        ,so.joint_order_number
        ,po.purchase_order_number
        ,po.invoice_no -- 这里可能也需要像O2O那样转换，历史数据和新数据从不同的地方取值
        -- ,po.purchase_order_number as invoice_no
        ,po.invoice_id
        ,so.channel_code
        ,so.channel_name
        ,so.sub_channel_code
        ,so.sub_channel_name
        ,store.store_code
        ,opcm.crm_province as province
        ,opcm.crm_city as city
        ,so.district
        ,coalesce(po.type_code, so.type_code) as type_code
        ,po.sub_type_code
        -- ,so.sub_type_code
        ,so.member_id
        ,so.member_card
        ,coalesce(po.member_card_grade, so.member_card_grade) as member_card_grade
        ,so.payment_amount
        ,so.payment_status
        -- ,coalesce(po.order_status, so.order_status) as order_status
        ,so.order_status as so_order_status
        ,po.order_status as po_order_status
        ,so.order_time
        ,so.payment_time
        ,so.is_placed
        ,so.place_time
        ,so.smartba_flag
        ,po.item_sku_code
        ,po.item_sku_name
        ,po.item_quantity
        ,po.item_sale_price
        ,po.item_total_amount
        ,po.item_apportion_amount
        ,po.item_discount_amount
        ,item.virtual_sku_code
        ,item.virtual_quantity
        ,item.virtual_apportion_amount
        ,item.virtual_discount_amount
        ,warehouse.logistics_company
        ,warehouse.logistics_number
        ,po.shipping_time
        ,po.shipping_amount
        ,warehouse.def_warehouse
        ,warehouse.actual_warehouse
        ,po.pos_sync_time
        ,po.pos_sync_status
        ,po.sys_create_time
        ,po.sys_update_time
        ,current_timestamp as insert_timestamp
from    so_order so
left    join po_order po
on      so.sales_order_number = po.sales_order_number
-- and     so.type_code = po.type_code
left    join
(
    select  tid as sales_order_number
            ,outer_sku_id as virtual_sku_code
            ,sum(num) as virtual_quantity
            ,sum(divide_order_fee) as virtual_apportion_amount
            ,sum(discount_fee) as virtual_discount_amount
    from    ODS_New_OMS.OMS_STD_Trade_Item
    where   substring(outer_sku_id, 1,1) = 'V'
    and     data_update_time >= @start_time
    and   	data_update_time <= @end_time
    group   by tid,outer_sku_id
) item
on      so.sales_order_number = item.sales_order_number
and     po.virtual_sku_code = item.virtual_sku_code
left    join warehouse
on      po.purchase_order_number = warehouse.purchase_order_number
left    join STG_OMS.OMS_Store_Mapping store
on      so.shop_code = store.store_id
and     warehouse.actual_warehouse = store.warehouse
left join
    STG_OMS.OMS_Province_City_Mapping opcm
on so.province = opcm.oms_province
and isnull(so.city, '') = isnull(opcm.oms_city, '')
;
END
GO
