/****** Object:  StoredProcedure [DWD].[SP_Fact_LiveRoom_Sales_Order_History]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_LiveRoom_Sales_Order_History] @dt [VARCHAR](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-15       wangzhichun           initial version
-- ========================================================================================
truncate table DWD.Fact_LiveRoom_Sales_Order;
insert into DWD.Fact_LiveRoom_Sales_Order
select 
        so.sales_order_number,--so订单号
        so.channel_id as sub_channel_code, --渠道,存在 MINIPROGRAM、APP(IOS)、APP(ANDROID)
        item.live_room_id,
        item.live_channel,    --直播渠道
        cast(room.begin_live_time as date) as live_date,--直播日期
        room.begin_live_time, --开始时间
        room.end_live_time,  --结束时间
        cast(so.payment_time as date) as payment_date, --付款日期
        so.payment_time, --付款时间
        item.item_sku as item_sku_code,  --商品编码
        item.item_name as item_sku_name, --商品名称
        sku.eb_main_sku_code as item_main_code,
        sku.eb_category as item_category, 
        sku.eb_brand_name as item_brand_name,
        item.item_quantity,
        item.apportion_amount,
        CURRENT_TIMESTAMP as insert_timestamp
    from 
    (
        select 
            t.sales_order_sys_id as sales_order_sys_id,
            sales_order_number,
            payment_time,
            channel_id
        from 
            stg_oms.sales_order t
        inner join
            stg_oms.sales_order_item t1
        on t.sales_order_sys_id = t1.sales_order_sys_id
        where t1.live_room_id is not null
        group by 
            t.sales_order_sys_id,
            sales_order_number,
            payment_time,
            channel_id
    ) so 
    left join 
        stg_oms.sales_order_item item
    on so.sales_order_sys_id=item.sales_order_sys_id
    left join 
        dwd.dim_sku_info sku
    on item.item_sku = sku.sku_code
    left join 
    (
        select 
            *
        from 
            ods_live.rooms
        where dt=@dt
    ) room 
    on 
        item.live_room_id=room.il_id
END 
GO
