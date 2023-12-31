/****** Object:  StoredProcedure [TEMP].[SP_DWS_OMS_Sales_Order_With_SKU]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_OMS_Sales_Order_With_SKU] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       houshuangqiang     Initial Version
-- ========================================================================================
truncate table DW_New_OMS.DWS_OMS_Sales_Order_With_SKU;
insert into DW_New_OMS.DWS_OMS_Sales_Order_With_SKU
select  o.source_bill_no as sales_order_number
        ,o.bill_no as purchase_order_number
        ,'' as invoice_no
        ,'' as invoice_id
       -- ,o.platform_id -- 后面注释掉
        ,case when channel.code = 'jingdong' then 'JD'
              when channel.code = 'douyinxiaodian' then 'DOUYIN'
              when channel.code = 'taobao' then 'TMALL'  -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
              else upper(channel.code)
        end as channel_code
        ,case when channel.name = N'京东商城' then N'京东'
              when channel.name = N'OFF_LINE' then N'线下'
              when channel.name = N'抖音小店' then N'抖音'
              when channel.name = N'淘宝' then N'天猫' -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
        end as channel_name
--        ,origin as sub_channel_code
        ,upper(o.trade_from) as sub_channel_code
        ,upper(channel1.name) as sub_channel_name -- case when 转换
        ,o.store_code
--        ,o.store_name
        ,province.province_name as province
        ,city.city_name as city
        ,district.county_name as district
        ,o.order_type as type_code
        ,'' as member_id -- 暂时没有会员id
        ,o.member_card_no as member_card
		,'' as member_card_grade
--        ,o.member_level_name as member_card_grade -- 数据接入需要新增字段
        ,case when o.pay_state = 0 then N'支付状态'
              when o.pay_state = 1 then N'部分付款'
              when o.pay_state = 2 then N'已付款'
         end as payment_status
        ,o.status as order_status -- 订单状态0 未确认、1 已确认、2 异常、8 已完成、9  已终止（作废单）、10 取消（取消单)
        ,o.bill_date as order_time -- 下单时间
        ,o.pay_date as payment_time
        ,case when o.pay_state = 2 then 1 else 0 end as is_placed
        ,o.pay_date as place_time
        ,null as smartba_flag -- 后续补充
--        ,detail.out_sku_id as item_sku_code -- vb_code
        ,sku.code as item_sku_code
        ,sku.name as item_sku_name
--
--        ,detail.outer_sku_id as item_sku_code
        ,detail.qty as item_quantity
        ,detail.amount as item_total_amount
		,null as item_apportion_amount
        ,detail.discount as item_discount_amount
		,null as virtual_sku_code
        ,null as virtual_quantity
		,null as virtual_apportion_amount
		,null as virtual_discount_amount
		,o.delivery_time as shipping_time
        ,o.express_fee as shipping_amount
        ,def_warehouse.name as def_warehouse
        ,real_warehouse.name as actual_warehouse
		,null as pos_sync_time
		,null as pos_sync_status
		,current_timestamp as insert_timestamp
from    STG_New_OMS.OMS_Retail_Order_Bill o
left    join STG_New_OMS.oms_retail_goods_detalis detail
on      o.id = detail.retail_order_bill_id
left    join STG_IMS.SYS_Dict_Detail_STG channel
on      o.platform_id = channel.id
left    join STG_IMS.SYS_Dict_Detail_STG channel1 -- 这样设计不大合理
on      o.trade_from = channel1.code
left    join STG_IMS.Gds_Btsinglprodu_STG sku
--on      detail.outer_sku_id = sku.code
on      detail.singleproduct_id = sku.id
left    join
(
    select  bill_no
            ,province_id
--            ,province_name
            ,city_id
            ,district_id
--            ,district_name
            ,ware_house_default_id
            ,ware_house_real_id
    from    STG_New_OMS.ORD_Retail_ORD_DIS_Info
    group   by bill_no,province_id,city_id,district_id,ware_house_default_id,ware_house_real_id
) addr
on      o.bill_no = addr.bill_no
left    join DW_New_OMS.DIM_Province province
on      addr.province_id = province.id
left    join DW_New_OMS.DIM_City city
on      addr.city_id = city.id
left    join DW_New_OMS.DIM_County district
on	    addr.district_id = district.id
left    join STG_IMS.Bas_Warehouse_STG def_warehouse
on      addr.ware_house_default_id = def_warehouse.id
left    join STG_IMS.Bas_Warehouse_STG real_warehouse
on      addr.ware_house_real_id = real_warehouse.id
;
END
GO
