/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_OMS_Sales_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_OMS_Sales_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-27       houshuangqiang  Initial Version
-- ========================================================================================

truncate table DW_OMS_Order.DW_OMS_Sales_Order;
insert into DW_OMS_Order.DW_OMS_Sales_Order
select  so.tid sales_order_sys_id
        ,so.tid as sales_order_number
        ,so.merge_no as joint_order_number
        ,so.shop_code as store_id
        ,trim(so.receiver_state) as province
        ,trim(so.receiver_city) as city
        ,trim(so.receiver_district) as district
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
        ,so.front_order_type as type_code
        ,trim(so.customer_id) as member_id
--        ,case when so.channel_id = 'JD' and so.vip_card_no like 'JD%' then substring(so.vip_card_no, 3, len(so.vip_card_no)-2) else so.vip_card_no end as member_card
        ,case when trim(so.platform) = 'JINGDONG' and so.vip_card_no like 'JD%' then SUBSTRING(so.vip_card_no, 3, len(so.vip_card_no)-2) else so.vip_card_no end as member_card
        ,coalesce(case when so.member_level_name = 'GOLDEN' then 'GOLD' else so.member_level_name  end, o.group_name)  as member_card_grade
        ,so.status as order_status
        ,so.created as order_time
        ,cast(so.pay_status as int) as payment_status
        ,so.pay_time as payment_time
        ,so.payment as payment_amount
        ,case when so.shop_code not in ('TMALL002', 'GWP001')
              and so.front_order_type not in ('2', '9')
              and ((so.pay_status = 2 and so.pay_time is not null) or so.front_order_type = '8')
        --       and (so.total_fee - coalesce(item.merchant_discount_fee, 0)) > 1 then 1
              and so.total_fee > 1 then 1
              else 0
        end is_placed
        ,case when so.front_order_type = '8' then so.created else coalesce(so.pay_time, so.created) end as place_time
        ,format(case when so.front_order_type = '8' then so.created else coalesce(so.pay_time, so.created) end, 'yyyy-MM-dd') as place_date
        ,case when so.smart_BA_flag is not null then cast(so.smart_BA_flag as int)
              when os.order_id is not null and so.channel_id = 'MINIPROGRAM' then 1
              else 0
        end as smartba_flag
        ,so.buyer_open_uid as ouid
        ,so.super_order_id as super_id
        ,guid.mobile_guid
        ,so.data_create_time as create_time -- 这两组时间和老OMS是不一样的，new oms中没有create_time/update_time
        ,format(so.data_create_time, 'yyyy-MM-dd') as create_date
        ,so.data_update_time as update_time
        ,format(so.data_update_time, 'yyyy-MM-dd') as update_date
        ,null as end_time  -- new oms中无此字段
        ,null as end_date
        ,current_timestamp as insert_timestamp
from    ODS_OMS_Order.OMS_STD_Trade so
-- left    join
-- (
--     select  tid
--             ,sum(merchant_discount_fee) as merchant_discount_fee
--     from    ODS_OMS_Order.OMS_STD_Trade_Item
--     group   by tid
-- )    item
-- on      so.tid = item.tid
left    join ODS_OIMS_Support.Bas_Channel channel
on      so.shop_id = channel.id
left    join
(
    select order_id, group_name from ODS_Order.Orders where group_name <> 'O2O'
) o
on     so.tid = o.order_id
left     join
(
    select order_id from ODS_Order.Order_Source where utm_campaign = 'BA'and utm_medium ='seco' group by order_id
) os
on      so.tid = os.order_id
left    join DW_OMS_Order.DW_Order_Guid_Info guid
on      so.tid = guid.sales_order_number
where   so.trade_from in ('taobao','jingdong','douyinxiaodian','SOA')
or     so.platform = 'XIAOHONGSHU'

END;
GO
