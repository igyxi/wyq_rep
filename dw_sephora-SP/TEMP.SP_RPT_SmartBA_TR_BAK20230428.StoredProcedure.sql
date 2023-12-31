/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_TR_BAK20230428]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_TR_BAK20230428] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.RPT_SmartBA_TR where dt = @dt;
insert into DW_Sensor.RPT_SmartBA_TR
select 
	orders.place_date,
	orders.orders,
	uv.uv,
	orders.orders*1.0/uv.uv,
	current_timestamp as insert_timestamp,
    @dt as dt
from 
(
	select 
		place_date,
		count(case when tos.order_id is not null and so.payment_status_cd=1 then sales_order_number end) as orders
	from 
	(
		select 
            sales_order_number,
            place_date,
            payment_status_cd
        from 
            DW_OMS.RPT_Sales_Order_Basic_Level 
		where 
            store_cd = 'S001' 
		and 
            order_date >= '2020-03-01' 
		and 
            place_date = @dt
		and 
            is_placed_flag = 1 
	) so
	left join
	(
        select 
            order_id 
        from 
            STG_Order.Order_Source 
        where 
            utm_campaign = 'BA' 
        and 
            utm_medium ='seco'
    ) tos
	on so.sales_order_number = tos.order_id
	group by place_date
) orders
left join 
(
	select
        uv,
        dt
    from
        DW_Sensor.RPT_SmartBA_PV_UV_Daily
    where
        dt=@dt
) uv
on orders.place_date = uv.dt;
END
GO
