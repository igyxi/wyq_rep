/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Events_Page_Value_20220803]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Events_Page_Value_20220803] @dt [VARCHAR](10) AS --存储过程名称是否修改 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-**-01       未知           Initial Version
-- 2022-08-03       hsq            将两个脚本合并为一个脚本，优化逻辑
-- ========================================================================================

delete from [DW_Sensor].[DWS_Events_Page_Value] where [DATE]=@dt;

-- 提交订单的事件数据
with Order_Events as
(
  select 
       event
      ,user_id
      ,orderid
      ,date
      ,max(time) as time
      ,op_code as buy_op_code
      ,platform_type
  from 
      [stg_sensor].[events]
  where 
      date = @dt
  and 
      event = 'submitOrderBySku'
  and 
      user_id is not null
  -- 是应该加一个 orderid is not null 吧
  -- and orderid is not null
  group by 
      event
     ,user_id
     ,orderid
     ,date
     ,op_code
     ,platform_type
),

-- 浏览30s页面的数据集，('$AppViewScreen','$pageview','$MPViewScreen','viewCommodityDetail')
Events_Session as
(
   select distinct 
          event
         ,user_id
         ,op_code
         ,pageid_wo_prefix -- 取值用的是 pageid_wo_prefix
		 ,page_id -- 用这个 rigt(page_id,7) 去关联
         ,sessionid
         ,date
         ,time
         ,platform_type
         ,current_timestamp as insert_timestamp
    from 
         [dw_sensor].[dws_events_session_cutby30m]
    where 
        date = @dt
    and 
        event in ('$AppViewScreen','$pageview','$MPViewScreen','viewCommodityDetail')
),

Fact_Order as 
(
	select distinct 
		oe.orderid
		,es.event
		,es.user_id
		,oe.buy_op_code
		,es.op_code
		,es.pageid_wo_prefix as page_id
		,es.sessionid
		,es.date
		,es.time
		,es.platform_type
		,od.apportion_amount
		,current_timestamp as insert_timestamp
	from 
		Events_Session es
	inner join 
		Order_Events oe -- submitOrderBySku 提交订单事件 
	on 
		es.user_id = oe.user_id 
	and 
		es.date = oe.date 
	and 
		upper(es.platform_type collate chinese_prc_cs_ai_ws) = upper(oe.platform_type)
	inner join 
	(
		select 
			so.sales_order_number
			,sku.eb_product_id
			,sum(so.item_apportion_amount) as apportion_amount
		from 
			DWD.Fact_Sales_Order so 
		left join 
			DWD.DIM_SKU_Info sku 
		on 
			so.item_sku_code = sku.sku_code
		where 
			so.is_placed = 1
		group by 
			so.sales_order_number,sku.eb_product_id
		) od -- order 
	on 
		oe.orderid collate chinese_prc_cs_ai_ws = od.sales_order_number -- 排序规则应该不需要吧
	and 
		oe.buy_op_code collate chinese_prc_cs_ai_ws = cast(od.eb_product_id as nvarchar) collate chinese_prc_cs_ai_ws
	left join
		DW_Sensor.DIM_Events_Page_Value_Page p 
	on 
		right(es.page_id, 7) = p.page_id
	where 
		es.time <= oe.time
	and 
		es.event in ('$AppViewScreen','$pageview','$MPViewScreen')
	and
	    p.page_id is null
),
 

-- 用户产品详情，并下单的明细数据
Submit_Order as 
(
    select 
         oe.orderid
        ,es.event
        ,es.user_id
        ,oe.buy_op_code
        ,es.op_code
        ,es.pageid_wo_prefix as page_id
        ,es.sessionid
        ,es.date
        ,lag(es.time, 1) over (partition by oe.orderid,es.event,es.user_id,oe.buy_op_code,es.platform_type,es.sessionid order by es.time) as start_time
        ,es.time as end_time
        ,es.platform_type
        ,row_number() over (partition by oe.orderid,es.event,es.user_id,oe.buy_op_code,es.platform_type,es.sessionid order by es.time) as row_num
    from 
	     Events_Session es
    left join 
         Order_Events oe -- submitOrderBySku 提交订单事件
      on 
         es.user_id = oe.user_id
     and 
         es.date = oe.date
     and 
         es.op_code = oe.buy_op_code collate chinese_prc_cs_ai_ws
     and 
         upper(es.platform_type collate chinese_prc_cs_ai_ws)=upper(oe.platform_type)
   where 
         es.time <= oe.time 
     and 
         oe.user_id is not null 
     and 
         es.event = 'viewCommodityDetail'
     and 
         es.pageid_wo_prefix is not null
)


-- 最后结果表
insert into [DW_Sensor].[DWS_Events_Page_Value]
select distinct 
     p.orderid
    ,p.event
    ,p.user_id
    ,p.buy_op_code
    ,p.op_code
    ,p.page_id
    ,p.sessionid
    ,p.date
    ,p.platform_type
    ,p.apportion_amount
    ,case 
		  when p.time > isnull(t.start_time, '') and p.time <= t.end_time then t.row_num
		  else 0
     end as row_num
    ,current_timestamp as insert_timestamp
from  	
	Fact_Order p
left join 
	Submit_Order t
on 
    p.orderid = t.orderid collate chinese_prc_cs_ai_ws
and 
    p.user_id = t.user_id
and 
    p.date = t.date
and 
    p.time > isnull(t.start_time, '')
and 
    p.time <= t.end_time
and 
    p.sessionid = t.sessionid
and 
    p.platform_type = t.platform_type
where 
    t.sessionid is not null
;
end
GO
