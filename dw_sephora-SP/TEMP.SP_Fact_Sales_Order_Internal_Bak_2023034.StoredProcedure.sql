/****** Object:  StoredProcedure [TEMP].[SP_Fact_Sales_Order_Internal_Bak_2023034]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Sales_Order_Internal_Bak_2023034] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description      version
-- ----------------------------------------------------------------------------------------
-- 2022-10-24       houshuangqiang   内卖系统订单     Initial Version
-- 2022-10-25       houshuangqiang   内卖系统订单     add column
-- 2022-10-28       houshuangqiang   内卖系统订单     fix province
-- ========================================================================================
truncate table DWD.Fact_Sales_Order_Internal;
insert 	into DWD.Fact_Sales_Order_Internal
select	o.order_no as sales_order_number
        ,o.purchase_order_number
        ,o.company_id
		,company.company_name
        ,o.activity_id
        ,activity.name as activity_name
--        ,case when o.province in (N'上海', N'北京', N'天津', N'重庆') then concat(o.province, N'市') -- 上海有三条数据不带市,这里为了防止直辖市不带市的情况，增加
--              when o.province = N'宁夏省' then N'宁夏回族自治区' -- 订单中存在宁夏省和广西省
--			  when o.province = N'广西省' then N'广西壮族自治区'
--              when o.province = N'新疆省' then N'新疆维吾尔自治区'
--              when o.province in (N'西藏省', N'内蒙古省') then concat(o.province, N'自治区')
--              when o.province in (N'香港', N'澳门') then concat(o.province, N'特别行政区')
--         else o.province end province
         ,case when o.province in (N'上海市', N'北京市', N'天津市', N'重庆市') then left(o.province,2)
             when o.province in (N'西藏自治区',N'宁夏回族自治区',N'广西壮族自治区',N'澳门特别行政区',N'香港特别行政区',N'新疆维吾尔自治区') then left(o.province, 2)
             when o.province = N'内蒙古自治区' then N'内蒙古'
             else replace(o.province, N'省', '')
        end as province        
        ,o.city
        ,o.district
		,o.card_no as member_card
		,case when o.status = 2 then N'已支付'
			   when o.status = 3 then N'待发货'
			   when o.status = 4 then N'已发货'
			   else N'Unknown'
		end as order_status
        ,o.create_time as order_time
        ,1 as payment_status
        ,o.pay_time as payment_time
        ,1 as is_placed
        ,o.pay_time as placed_time
        ,0 as is_smartba
		,o.total_amount
		,o.goods_amount as product_amount
		,sku.sku_code as item_sku_code
		,sku.product_name_cn as item_sku_name
		,goods.goods_count as item_quantity
		,goods.goods_price as item_sale_price
		,goods.goods_price * goods.goods_count as item_apportion_amount
		,null as item_discount_amount
        ,null as item_animation_name
        ,o.shipping_time
		,o.freight as shipping_amount
		,upper(o.def_warehouse) as def_warehouse
        ,upper(o.real_warehouse) as actual_warehouse
        ,'SIS' as source
        ,CURRENT_TIMESTAMP as insert_timestamp
from 	STG_SIS.SIS_Order o
left 	join STG_SIS.SIS_Company company -- left join 和inner join的数据是一样的，需求给的是join
on 		o.company_id = company.id
and 	o.activity_id = company.activity_id
left 	join STG_SIS.SIS_Activity activity
on 		o.activity_id = activity.id
left 	join STG_SIS.SIS_Order_Goods goods
on 		o.id = goods.order_id
left 	join STG_SIS.SIS_Activity_Goods sku
on 		goods.activity_goods_id = sku.id
where 	o.status = 4

END
GO
