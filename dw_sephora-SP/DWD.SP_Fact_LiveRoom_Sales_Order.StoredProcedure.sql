/****** Object:  StoredProcedure [DWD].[SP_Fact_LiveRoom_Sales_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_LiveRoom_Sales_Order] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-17       houshuangqiang           initial version(new oms替换Fact_LiveRoom_Sales_Order, 需要确定直播是否关联rooms)
-- ========================================================================================


truncate table DWD.Fact_LiveRoom_Sales_Order;
insert into DWD.Fact_LiveRoom_Sales_Order
select  o.tid as sales_order_number
        ,case when o.platform = 'jingdong' then 'JD'
              when o.platform = 'taobao' then 'TMALL'
              else o.platform
        end as channel_code
        ,o.channel_id as sub_channel_code
        ,o.live_id
        ,null as live_channel
        ,format(rooms.begin_live_time, 'yyyy-MM-dd') as live_date
        ,rooms.begin_live_time
        ,rooms.end_live_time
        ,format(o.pay_time, 'yyyy-MM-dd') as payment_date
        ,o.pay_time as payment_time
        ,item.outer_sku_id as item_sku_code
        ,sku.eb_sku_name as item_sku_name
        ,sku.eb_main_sku_code as item_main_code
        ,item.category as itm_category
        ,item.brand as item_brand_name
        ,item.num as item_quantity
        ,item.payment as apportion_amount
        ,current_timestamp as insert_timestamp
from    ODS_OMS_Order.OMS_STD_Trade o
left    join ODS_OMS_Order.OMS_STD_Trade_Item item
on      o.tid = item.tid
left    join ods_live.rooms rooms
on      o.live_id = rooms.il_id
left    join DWD.DIM_SKU_Info sku
on      item.outer_sku_id = sku.sku_code
where   o.trade_from in ('taobao','jingdong','douyinxiaodian','SOA')

END
GO
