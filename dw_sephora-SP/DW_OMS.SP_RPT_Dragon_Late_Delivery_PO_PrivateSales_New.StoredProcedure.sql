/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_Dragon_Late_Delivery_PO_PrivateSales_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_Dragon_Late_Delivery_PO_PrivateSales_New] @dt [VARCHAR](10),@delivery_pending_days [int] AS BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-03-01       houshuangqiang     change DW_OMS.DWS_Purchase_Order/DW_OMS.RPT_Sales_Order_Basic_Level to DWD.Fact_Sales_Order
-- 2023-03-29       wangzhichun        change source table
-- 2023-06-05       wangzhichun        change new oms order_status
-- ========================================================================================
--DECLARE @dt date,SP_RPT_Dragon_Late_Delivery_PO_PrivateSales
--@delivery_pending_days int
--set
--    @dt = '2021-09-03'
--set
--    @delivery_pending_days = 1
--EXECUTE [DW_OMS].[SP_RPT_Dragon_Late_Delivery_PO_PrivateSales] '2021-09-03', 3

--新档期大促清空 前一天
if ((select format(getdate(),'yyyy-MM-dd')) = '2022-10-24' and (@delivery_pending_days = 5))
begin
    delete from [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales_New]
    where report_pending_days = 5
end

if ((select format(getdate(),'yyyy-MM-dd')) = '2022-10-26' and (@delivery_pending_days = 7))
begin
    delete from [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales_New]
    where report_pending_days = 7
end

delete from [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales_New] WHERE [dt] =@dt AND [report_pending_days] =@delivery_pending_days;
insert into [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales_New]
select
    a.[sales_order_number],
    a.member_id,
    a.[place_time],
    a.[actual_pending_days],
    @delivery_pending_days as [report_pending_days],
    @dt as [dt]
from
(
	select 	so.sales_order_number
			,m.eb_user_id as member_id
			,so.place_time
			,datediff(day,case when so.sub_type_code=3 then isnull(so.shipping_time,so.place_time) else so.place_time end,cast(isnull(so.logistics_shipping_time, dateadd(day,1,@dt)) as date)) as [actual_pending_days]
			,row_number() over(partition by m.eb_user_id order by case when so.sub_type_code=3 then isnull(so.shipping_time,so.place_time) else so.place_time end) as [seq]
	from
	(

		select 	so.sales_order_number
				,so.member_card
				,sub_type_code
				,place_time
				,so.shipping_time
                ,logis.logistics_shipping_time
		from 	DWD.Fact_OMS_Sales_Order_New so
        left join 
                DWD.Fact_Logistics_Order_New logis 
        on logis.purchase_order_number=so.purchase_order_number
		where 	so.source = 'NEW OMS'
		and 	channel_code = 'SOA'
        and     coalesce(so.po_order_status,so.so_order_status) not in (N'取消','TRADE_CLOSED','TRADE_CANCELED')
		and 	case when sub_type_code =3 then isnull(so.shipping_time,place_time) else place_time end >= '2021-11-09 20:00:00.000' -- 增量跑数，其实可以不用限制了
		and 	format(place_time, 'yyyy-MM-dd') >= dateadd(day, @delivery_pending_days *(-1), @dt)
        and     format(place_time, 'yyyy-MM-dd')  < @dt
		and 	datediff(day,case when sub_type_code =3 then isnull(so.shipping_time,place_time) else place_time end,cast(isnull(logis.logistics_shipping_time, dateadd(day,1,@dt)) as date)) > @delivery_pending_days
		group 	by so.sales_order_number,so.member_card,sub_type_code,place_time,so.shipping_time,logis.logistics_shipping_time
	) so
	left 	join DWD.DIM_Member_INFO m
	on 		so.member_card = m.member_card
) a
left join
(
    select *
    from [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales]
    where dt <= dateadd(day,-1,@dt)
) b ON a.member_id = b.member_id and b.[report_pending_days] = @delivery_pending_days
where a.seq = 1 and b.[dt] is null
;
END


GO
