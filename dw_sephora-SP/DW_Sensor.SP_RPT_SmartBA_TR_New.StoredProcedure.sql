/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_SmartBA_TR_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_SmartBA_TR_New] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-02-22       wangzhichun    update DW_OMS.RPT_Sales_Order_Basic_Level-> RPT.RPT_Sales_Order_Basic_Level
-- ========================================================================================
delete from DW_Sensor.RPT_SmartBA_TR_New where dt = @dt;
insert into DW_Sensor.RPT_SmartBA_TR_New
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
            payment_status as payment_status_cd
        from 
            -- DW_OMS.RPT_Sales_Order_Basic_Level 
            RPT.RPT_Sales_Order_Basic_Level
		where 
            channel_code = 'S001' 
		and 
            order_date >= '2020-03-01' 
		and 
            place_date = @dt
		and 
            is_placed = 1 
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
