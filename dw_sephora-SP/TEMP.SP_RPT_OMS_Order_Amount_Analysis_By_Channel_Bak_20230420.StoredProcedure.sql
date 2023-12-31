/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Order_Amount_Analysis_By_Channel_Bak_20230420]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Order_Amount_Analysis_By_Channel_Bak_20230420] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-03-29       wangzhichun        Initial Version
-- 2022-10-27       houshuangqiang     update cancel_amount logic & Switch the upstream data source to RPT/DWD -- old table name DW_OMS.RPT_OMS_Return_Cancel_Order_Analystic_Daily
-- 2022-11-03       houshuangqiang     update 按新逻辑取数，数据差异较大，上游数据与stg原表中数据存在差异, 先暂时从stg层取refund_amount和cancel_amount,JD003的需要直接到SO单中取值（之前的数据，没有JD FCS取消订单金额）
-- ========================================================================================
delete from [RPT].[RPT_OMS_Order_Amount_Analysis_By_Channel] where [dt] = @dt;
insert  into [RPT].[RPT_OMS_Order_Amount_Analysis_By_Channel]
select  p1.dt,
         case when p1.sub_channel_code = 'TMALL004' then N'TMALL_Chaling'
             when p1.sub_channel_code = 'TMALL005' then N'TMALL_PTR'
             when p1.sub_channel_code = 'TMALL006' then N'TMALL_WEI'
             when p1.sub_channel_code in ('JD001','JD002') then 'JD FSS'
             when p1.sub_channel_code = 'JD003' then N'JD FCS'
             when p1.channel_code = 'TMALL' then N'TMALL'
             when p1.channel_code = 'SOA' then N'官网'
             when p1.channel_code = 'DOUYIN' then N'DOUYIN001'
             else p1.channel_code
        end as channel,
        sum(p1.oms_sales_amount) as oms_sales_amount,
        sum(p2.refund_amount) as refund_amount,
        -- sum(p2.cancel_amount),
        -- sum(p3.cancel_amount),
        -- sum(p2.cancel_amount) + sum(p3.cancel_amount) as cancel_amount, -- 数字+null = null,
        sum(case when p2.cancel_amount is null and p3.cancel_amount is null then null
        	 else coalesce(p2.cancel_amount, 0) + coalesce(p3.cancel_amount, 0)
        end) as cancel_amount,  -- 确认没有退款金额，保留数值为null, 还是写0， 之前按存的是0
        current_timestamp as insert_timestamp
from
(
	select  format(place_time,'yyyy-MM-dd') as dt,
			channel_code,
			case when channel_code = 'SOA' then 'S01' else sub_channel_code end as sub_channel_code,
			sum(product_amount) as oms_sales_amount
--			sum(case when order_internal_status = 'CANCELLED' then product_amount end) as cancel_amount
	from 	RPT.RPT_Sales_Order_Basic_Level
	where 	is_placed = 1
	and 	order_status <> 'DELETED'
	and 	order_type <> 2
	and  	sub_channel_code not in ('REDBOOK001','GWP001')
	and 	format(place_time,'yyyy-MM-dd') = @dt
	group   by format(place_time,'yyyy-MM-dd'),channel_code,case when channel_code = 'SOA' then 'S01' else sub_channel_code end
) p1
left 	join
(
    select
            format(refund.refund_time,'yyyy-MM-dd') as dt,
            store.channel_id as channel_code,
            case when store.channel_id = 'SOA' then 'S01' else store.store_id end as sub_channel_code,
            sum(case when refund_type in ('ONLINE_RETURN_REFUND','RETURN_REFUND')
                or product_out_status in ('CANT_CONTACTED','REJECTED','INTERCEPT')
                or refund_reason in ('REJECTED','CANT_CONTACT')
                then refund_sum end) as refund_amount,
            sum(case when refund_type in ('ONLINE_PARTIAL_CANCEL','FULL_ITEM_REFUND','PARTIAL_ITEM_REFUND','FULL_ITEM_DEPOSIT_REFUND')
                and product_out_status not in ('CANT_CONTACTED','REJECTED','INTERCEPT')
                and (refund_reason not in ('CANT_CONTACTED','REJECTED','CANT_CONTACT') or refund_reason is null)
                then refund_sum end) as cancel_amount
    from    STG_OMS.OMS_Order_Refund refund
    left    join  STG_OMS.OMS_Store_Info store
    on      refund.store_id = store.store_id
    where   refund.refund_status='REFUNDED' -- 无shop_id
    and     format(refund.refund_time,'yyyy-MM-dd') = @dt
    and  	refund.store_id not in ('REDBOOK001','GWP001')
    group   by format(refund.refund_time,'yyyy-MM-dd'),store.channel_id,case when store.channel_id = 'SOA' then 'S01' else store.store_id end
) p2
on 		p1.dt = p2.dt
and     p1.channel_code = p2.channel_code
and  	p1.sub_channel_code = p2.sub_channel_code
left    join
(
    -- 单独计算 JD003的取消订单，用update_time作为JD003取消订单退款时间
	select  format(update_time,'yyyy-MM-dd') as dt,
			channel_code,
			case when channel_code = 'SOA' then 'S01' else sub_channel_code end as sub_channel_code,
			sum(case when order_status = 'CANCELLED' then product_amount end) as cancel_amount
	from 	RPT.RPT_Sales_Order_Basic_Level
	where 	is_placed = 1
	and 	order_status <> 'DELETED'
	and 	order_type <> 2 -- 订单状态
	and  	sub_channel_code = 'JD003'
	and 	format(update_time,'yyyy-MM-dd') = @dt
	group   by format(update_time,'yyyy-MM-dd'),channel_code,case when channel_code = 'SOA' then 'S01' else sub_channel_code end
) p3
on 		p1.dt = p3.dt
and 	p1.channel_code = p3.channel_code
and  	p1.sub_channel_code = p3.sub_channel_code
group 	by p1.dt,
		 case when p1.sub_channel_code = 'TMALL004' then N'TMALL_Chaling'
			 when p1.sub_channel_code = 'TMALL005' then N'TMALL_PTR'
			 when p1.sub_channel_code = 'TMALL006' then N'TMALL_WEI'
			 when p1.sub_channel_code in ('JD001','JD002') then 'JD FSS'
			 when p1.sub_channel_code = 'JD003' then N'JD FCS'
			 when p1.channel_code = 'TMALL' then N'TMALL'
			 when p1.channel_code = 'SOA' then N'官网'
			 when p1.channel_code = 'DOUYIN' then N'DOUYIN001'
			 else p1.channel_code
		end
END
GO
