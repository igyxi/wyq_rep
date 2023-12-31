/****** Object:  StoredProcedure [TEMP].[SP_DWS_Store_Order_With_SKU_Bak20230221]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Store_Order_With_SKU_Bak20230221] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-27       houshuangqiang     Initial Version
-- 2022-11-29       houshuangqiang     delete def_warehouse/actual_warehouse
-- 2022-12-06       houshuangqiang     update area logic
-- 2022-12-07       houshuangqiang     update member_card_grade logic & add store_name
-- 2022-12-13       houshuangqiang     add is_sync column
-- 2022-12-15       wangzhichun        change source table schema
-- 2022-12-22       houshuangqiang     delete dim_member_card_grade_scd logic
-- 2022-12-26       houshuangqiang     add ticket_sa/ticket_rt
-- 2022-12-28       houshuangqiang     add total_amount/amount_paid
-- ========================================================================================
truncate table [DW_NEW_OMS].[DWS_Store_Order_With_SKU];
insert into [DW_NEW_OMS].[DWS_Store_Order_With_SKU]
select
    o.source_bill_no as sales_order_id, -- 平台id, 导出至bi_datamart需要这个字段。
    o.bill_no as sales_order_number,
    null as purchase_order_number,
    case when o.is_synt = 1 then o.invoice_no else '66' + o.bill_no end as invoice_no,
    case when o.is_synt = 1 then o.bill_no else o.ticket_sa end invoice_id,
    case when upper(channel.code) = 'DAZHONGDIANPING' then 'DIANPING'
          when upper(channel.code) = 'JINGDONGDAOJIA' then 'JDDJ'
          else upper(channel.code)
    end as channel_code,
    channel.name as channel_name,
    ware.code as store_code,
    ware.name as store_name,
    case when area1.name in (N'西藏自治区',N'宁夏回族自治区',N'广西壮族自治区',N'澳门特别行政区',N'香港特别行政区',N'新疆维吾尔自治区') then left(area1.name, 2)
         when area1.name = N'内蒙古自治区' then N'内蒙古'
         else replace(area1.name, N'省', '')
    end as province,
    area2.name as city,
    area3.name as district,
    o.member_card_no as member_card,
    o.pay_state as payment_status,
    case when upper(channel.code) = 'DAZHONGDIANPING' and o.distribution_state = 4 then 8
         when upper(channel.code) = 'DAZHONGDIANPING' and o.distribution_state = 6 then 2
         when upper(channel.code) = 'DAZHONGDIANPING' and o.distribution_state in (1, 2, 3, 5, 9) then o.distribution_state -- 先这样写
         when upper(channel.code) = 'MEITUAN' and o.status = 8 then o.distribution_state
         else o.distribution_state
    end as order_status,
    case when upper(channel.code) = 'DAZHONGDIANPING' and o.distribution_state = 4 then 1
         when upper(channel.code) = 'DAZHONGDIANPING' and o.distribution_state = 6 then 0
         when upper(channel.code) = 'DAZHONGDIANPING' and o.distribution_state in (1, 2, 3, 5, 9) then 0 -- 先这样写
         when upper(channel.code) = 'MEITUAN' and o.distribution_state is null and o.status = 8 then 1
         when o.distribution_state = 8 then 1
         else 0
    end  as is_placed, -- 见mapping 映射订单主表 订单状态
    o.pay_date as place_time,
    o.create_date as order_time,
    o.pay_date as payment_time,
    o.pick_time as pick_time,
    o.complete_date as complete_time,
    sku.code as item_sku_code,
    sku.name as item_sku_name,
    --,o.qty -- 购买数量
    --,detail.vb_qty -- vb购买数量
    --,detail.qty
    coalesce(detail.vb_qty, detail.qty) as item_quantity,
    detail.share_payment + coalesce(detail.merchant_discount_fee, 0) as item_total_amount, -- share_payment 实付总价 + 商家优惠
--    coalesce(detail.vb_origin_price * detail.vb_qty, detail.original_price * detail.qty) as item_total_amount,
--    detail.share_payment as item_apportion_amount, -- share_payment是原价-商家优惠金额，本身包含平台优惠，是实际入账金额
   -- 2023-01-09 surpluse_price_total是扣减取消退款后的入账金额。surpluse_price_total=share_payment - 已完成逆向申请单中对应商品的的退款金额（omni_refund_apply_item.refund_price_total）
    detail.surplus_price_total as item_apportion_amount,
    coalesce(detail.merchant_discount_fee, 0) as item_discount_amount, -- 商家优惠
--    def_ware.name as def_warehouse,
--    real_ware.name as actual_warehouse,
    o.amount_total as total_amount, -- 订单总金额（商品总额+订单级优惠金额+邮费），bi_datamart使用
    o.amount_paid as total_paid_amount, -- 全款支付情况下，实付总价=应付总价
    o.express_fee as shipping_amount,
    o.is_synt as is_sync, -- 核对日报数据使用，同步过来的数据和迁移之后数据，报表逻辑有差异
    o.create_date as create_time,
    o.modify_date as update_time,
    current_timestamp as insert_timestamp
from
    STG_New_OMS.Omni_Retail_Order_Bill o
left join
    STG_New_OMS.Omni_Retail_Ord_Goods_Detail detail
on o.id = detail.retail_order_bill_id
--(
--    select  retail_order_bill_id
--            ,singleproduct_id
--            ,sum(vb_qty) as vb_qty
--            ,sum(qty) as qty
--            ,sum(share_payment) share_payment
--            ,sum(surplus_price_total) as surplus_price_total
--            ,sum(merchant_discount_fee) as merchant_discount_fee
--    from    STG_New_OMS.Omni_Retail_Ord_Goods_Detail
--    group  by retail_order_bill_id,singleproduct_id
--) detail -- 先聚聚合，再关联,为了与orderhub数据对齐
--on o.id = detail.retail_order_bill_id
left join
    STG_IMS.SYS_Dict_Detail channel
on  o.platform_id = channel.id
left join
    STG_IMS.Bas_Warehouse ware
on o.warehouse_id = ware.id
left join
    STG_IMS.Bas_Adminarea area1
on  ware.province = area1.id
and area1.type = '02'
left join
    STG_IMS.Bas_Adminarea area2
on  ware.city = area2.id
and area2.type = '03'
left join
    STG_IMS.Bas_Adminarea area3
on  ware.area = area3.id
and area3.type = '04'
left join
    STG_IMS.Gds_Btsinglprodu sku
on detail.singleproduct_id = sku.id
END
GO
