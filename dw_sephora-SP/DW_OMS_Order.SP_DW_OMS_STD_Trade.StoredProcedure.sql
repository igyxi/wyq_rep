/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_OMS_STD_Trade]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_OMS_STD_Trade] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-12       houshuangqiang so 单数据对比逻辑
-- ========================================================================================
truncate table DW_OMS_Order.DW_OMS_STD_Trade;
insert into DW_OMS_Order.DW_OMS_STD_Trade
select  so.tid as sales_order_number
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
        -- ,so.channel_id as sub_channel_code
		-- ,case when so.store_id = 'S001' then so.channel_id
        --      when so.store_id = 'TMALL001' and so.shop_id = 'TM2' then N'天猫WEI旗舰店'
        --      else channel.name
        -- end as sub_channel_name
		,case when so.shop_code = 'S001' then so.channel_id
				  else so.shop_code
			end as sub_channel_code
			,case when so.shop_code = 'S001' then so.channel_id
				 else channel.name
			end as sub_channel_name
		,so.front_order_type as type_code
        ,so.customer_id as member_id
        ,case when so.channel_id = 'JD' and so.vip_card_no like 'JD%' then SUBSTRING(so.vip_card_no, 3, len(so.vip_card_no)-2) else so.vip_card_no end as member_card
        ,coalesce(case when so.member_level_name = 'GOLDEN' then 'GOLD' else so.member_level_name end, o.group_name) as member_card_grade
        ,case when so.pay_status = 1 then 2
              when so.pay_status = 2 then 1
              else so.pay_status  -- 枚举类型和老oms是相反的，需要转换回去。
        end as payment_status
        ,so.payment as payment_amount
        ,so.status as order_status
        ,so.created as order_time
--        ,so.pay_time as payment_time
        ,so.pay_time as place_time
        ,case when so.shop_code not in ('TMALL002', 'GWP001')
			  and so.front_order_type not in ('2', '9') -- 老oms order_type的枚举是2,9
			  and ((so.pay_status = 2 or so.pay_time is not null) or so.front_order_type = '8')
			  and (so.total_fee - item_dicount.merchant_discount_fee) > 1 then 1
			  else 0
		end is_placed
		,case when so.front_order_type = '8' then so.created else coalesce(so.pay_time, so.created) end as place_time
		--when so.pay_status = 2 then 1 else 0 end as is_placed
        --,so.pay_time as place_time
        ,case when so.smart_BA_flag is not null then so.smart_BA_flag
              when os.order_id is not null and so.channel_id = 'MINIPROGRAM' then 1
              else 0
        end as smartba_flag
        ,item.item_sku_code
        ,case when item.item_type = '1' then N'NORMAL'
              when item.item_type = '2' then N'FREE_SAMPLE'
              when item.item_type = '3' then N'VALUE_SET'
              when item.item_type = '4' then N'GWP'
              when item.item_type = '7' then N'VE'
              when item.item_type = '99' then N'BUNDLE'
              else item.item_type
        end as item_type
        ,item.item_quantity
        ,item.item_market_price
        ,item.item_sale_price
        ,item.item_adjustment_total / nullif(item.item_quantity, 0) as item_adjustment_unit
        ,item.item_adjustment_total as item_adjustment_total
--        ,item.apportion_amount_unit as apportion_amount_unit
        ,item.apportion_amount / nullif(item.item_quantity, 0) as item_adjustment_unit
        ,item.apportion_amount
        ,current_timestamp as insert_timestamp
from    ODS_New_OMS.OMS_STD_Trade so
inner   join  stg_oms.oms_to_oims_sync_fail_log fail
on      so.tid = fail.sales_order_number
and     fail.sync_status = 1
and     fail.update_time >= '2023-05-29 11:00:00'
-- and     fail.update_time <= '2023-05-24 22:30:38'
left 	join
(
      select tid
            ,sum(merchant_discount_fee) as merchant_discount_fee
      from 	ODS_New_OMS.OMS_STD_Trade_Item
      where data_update_time >= '2023-05-29 11:00:00'
      -- and 	data_update_time <= '2023-05-23 17:30:00'
      group by tid
) item_dicount
on 		so.tid = item_dicount.tid
left    join
(
    select  tid
            ,outer_sku_id as item_sku_code
            ,gift_type as item_type
            ,sum(num) as item_quantity
            ,max(list_price) as item_market_price
            ,max(sales_price) as item_sale_price
            ,sum(discount_fee) as item_adjustment_total
            ,max(divide_price) as apportion_amount_unit
            ,sum(payment) as apportion_amount
		-- ,sum(merchant_discount_fee) as merchant_discount_fee 
    from    ODS_New_OMS.OMS_STD_Trade_Item
    where  data_update_time >= '2023-05-29 11:00:00'
    group   by tid,outer_sku_id,gift_type
) item
on      so.tid = item.tid
left    join ODS_OIMS_Support.Bas_Channel channel
on      so.shop_id = channel.id
left 	join
(
        select order_id, group_name from STG_Order.Orders where group_name <> 'O2O' group by order_id, group_name
) o
on 		so.tid = o.order_id
left 	join
(
    select order_id from STG_Order.Order_Source where utm_campaign = 'BA'and utm_medium ='seco' group by order_id
) os
on  so.tid = os.order_id
where so.data_update_time >= '2023-05-29 11:00:00'
--and
END
GO
