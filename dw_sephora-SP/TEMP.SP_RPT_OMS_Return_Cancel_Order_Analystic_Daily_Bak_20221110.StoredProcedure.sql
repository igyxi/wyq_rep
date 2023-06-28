/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Return_Cancel_Order_Analystic_Daily_Bak_20221110]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Return_Cancel_Order_Analystic_Daily_Bak_20221110] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-03-29       wangzhichun        Initial Version
-- 2022-10-27       houshuangqiang     update cancel_amount logic & Switch to RPT
-- ========================================================================================
delete from [RPT].[RPT_OMS_Return_Cancel_Order_Analystic_Daily] where [date] = @dt;
select  p1.[date],
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
        sum(p2.refund_amount) as refund_amount,
        sum(p1.oms_sales_amount) as oms_sales_amount,
        sum(p2.cancel_amount) as cancel_amount,
        current_timestamp as insert_timestamp
from
(
	select  format(place_time,'yyyy-MM-dd') as [date],
			channel_code,
			case when channel_code = 'SOA' then 'S01' else sub_channel_code end as sub_channel_code,
			sum(product_amount) as oms_sales_amount
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
	select   date,
             channel_code,
             sub_channel_code,
             sum(case when refund_type in ('ONLINE_RETURN_REFUND','RETURN_REFUND')
                    or product_out_status in ('CANT_CONTACTED','REJECTED','INTERCEPT')
                    or refund_reason in ('REJECTED','CANT_CONTACT')
                    then refund_amount end) as refund_amount,
             sum(case when purchase_order_status = 'CANCELLED' then refund_amount end) as cancel_amount
	from
	(
		select  distinct -- order 
                format(refund_time,'yyyy-MM-dd') as date,
                refund_number,
                channel_code,
                case when channel_code = 'SOA' then 'S01' else sub_channel_code end as sub_channel_code,
                refund_type,
                product_out_status,
                refund_reason,
                purchase_order_status,
                refund_amount
		from 	DWD.Fact_Refund_Order_New
		where 	refund_status = 'REFUNDED'
		and     source = 'OMS'
		and 	format(refund_time,'yyyy-MM-dd') = @dt
		and  	sub_channel_code not in ('REDBOOK001','GWP001')
	) p
	group by date,channel_code,sub_channel_code
) p2
on 		p1.channel_code = p2.channel_code
and  	p1.sub_channel_code = p2.sub_channel_code
and     p1.[date] = p2.date
group 	by p1.[date],
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
;
END
GO
