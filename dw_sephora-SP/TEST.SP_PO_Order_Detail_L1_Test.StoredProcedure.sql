/****** Object:  StoredProcedure [TEST].[SP_PO_Order_Detail_L1_Test]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_PO_Order_Detail_L1_Test] @dt [VARCHAR](10) AS 
begin
truncate table Test.PO_Order_Detail_L1_Test;
insert into Test.PO_Order_Detail_L1_Test
select 
	distinct * 
from
(
	select 
		a.store_cd,
		a.channel_cd,
		a.sales_order_number,
		d.purchase_order_number,
		a.order_time,
		a.payment_time,
		a.place_time,
		d.internal_status,
		case when a.type_cd=1 then N'普通订单'
	         when a.type_cd=2 then N'换货订单'
	         when a.type_cd=3 then N'预售订单'
	         when a.type_cd=4 then N'积分订单'
	         when a.type_cd=5 then N'赠品补寄'
	         when a.type_cd=6 then N'赠品适用'
	         when a.type_cd=7 then N'定金订单'
	         when a.type_cd=8 then N'货到付款'
	         when a.type_cd=9 then N'付邮申领'
	    else 'NO DETAIL' end as type_cd,
		d.basic_status,
		d.split_type,
		d.item_sku_cd,
		d.item_apportion_unit_price,
		d.item_sale_price,
		d.item_market_price,
		b.brand_name_cn,
	    coalesce(c.brand_rename,b.brand_name) as brand_name_en,
		a.item_category,
		d.item_type,
		b.level1_name,
		b.level2_name,
		b.level3_name,
		coalesce(a.member_card_grade,'NULL') as Card_Grade,
		a.member_card,
		a.province,
		a.city,
		a.district,
		d.logistics_shipping_company,
		d.logistics_number,
		d.shipping_time,
		d.item_name,
		a.member_monthly_new_status,
		d.order_def_ware_house,
		d.order_actual_ware_house,
		d.item_quantity,
		d.item_apportion_amount,
		a.payed_amount
	from 
		[DW_OMS].[RPT_Sales_Order_SKU_Level] a
	left join 
		[DW_OMS].[DWS_Purchase_Order] d
	on a.sales_order_sys_id = d.purchase_order_sys_id
	left join 
		[DW_Product].[DWS_SKU_Profile] b 
	on a.item_sku_cd = b.sku_cd
	left join
	    [DW_Product].[DIM_Brand_Rename] c
	on b.brand_name = c.brand_name
    where 
	    a.order_time>=@dt 
	-- where 
	-- 	a.order_time>= @Place_Date_From
	-- and
	-- 	a.order_time<= @Place_Date_To
	and
	    a.member_card_grade in ('NULL','NEW','PINK','BLACK','BLACK','WHITE','GOLD','TEST')
) a 
where 
	store_cd in (select distinct store_cd from DW_OMS.DIM_Store_Channel);
END
GO
