/****** Object:  StoredProcedure [DWD].[SP_Fact_Logistics_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Logistics_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-12       zeyuan           Initial Version
-- 2023-04-24       zeyuan             修改主题域
-- ========================================================================================


truncate table DWD.Fact_Logistics_Order
insert into DWD.Fact_Logistics_Order
select
	t2.delivery_no as logistics_number
	,t2.logistics_name as logistics_company
	,t1.source_bill_no as sales_order_number
	,t1.bill_no as purchase_order_number
	,t2.province_name_real as province
	,t2.city_name_real as city
	,t2.district_name_real as district
	,t1.vip_card_no as  member_card
	,t1.collection_time as logistics_shipping_time
	,t1.presell_delivery_time as order_shipping_time
	,t1.delivery_time as shipping_time
	,t2.receipt_date as sign_time
	,t1.express_fee as  shipping_amount
    ,t1.remarks as shipping_comment
	,t2.ware_house_default as def_warehouse
	,t2.ware_house_real as actual_warehouse
	,t2.wh_area_type_out as warehouse_code
	,'' as parcel_number --parcel_number暂时置空
	,'' as status -- status 暂时置空
    ,0  as missing_flag -- missing_flag 暂时置空
    ,t1.data_create_time
    ,t1.data_update_time
    ,'OMS' as source
    ,CURRENT_TIMESTAMP as insert_timestamp
from
	[ODS_OMS_Order].[OMS_Retail_Order_Bill] t1
left join
(
		select
			a.delivery_no
            ,a.bill_no
            ,a.retail_order_bill_id
            ,a.province_id
            ,a.city_id
            ,a.district_id
            ,a.ware_house_default_id
            ,a.ware_house_real_id
            ,a.wh_area_type_out_id
            ,a.receipt_date
            ,a.order_remark
            ,b.name as province_name_real
            ,c.name as city_name_real
            ,d.name as district_name_real
            ,e.code as ware_house_default
            ,f.code as ware_house_real
            ,g.name as wh_area_type_out
            ,delivery.code as logistics_name
		from
			[ODS_OMS_Order].[ORD_Retail_ORD_DIS_Info] a
		left join
			[ods_oims_support].[BAS_Adminarea]b
		on a.province_id = b.id
		left join
			[ods_oims_support].[BAS_Adminarea]c
		on a.city_id = c.id
		left join
			[ods_oims_support].[BAS_Adminarea]d
		on a.district_id = d.id
        left join
            (select distinct id,code from [ods_oims_support].[BAS_warehouse]) e
        on a.ware_house_default_id = e.id
        left join
            (select distinct id,code from [ods_oims_support].[BAS_warehouse]) f
        on a.ware_house_real_id = f.id
        left join
            [ods_oims_support].[BAS_Storehouse] g
        on a.wh_area_type_out_id = g.id
        left join
            (select id,code from ODS_OIMS_Support.Bas_Delivery_Type where status = '09') delivery
        on a.delivery_type_id = delivery.id
) t2
on t1.bill_no = t2.bill_no
where t2.delivery_no is not null
END;
GO
