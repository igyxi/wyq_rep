/****** Object:  StoredProcedure [DW_OMS].[SP_DWS_PS_Phase2_Order_20221028]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DWS_PS_Phase2_Order_20221028] @dragon_start_time [varchar](13),@dragon_end_time [varchar](13),@tm_start_time [varchar](13),@tm_end_time [varchar](13),@tm_wei_start_time [varchar](13),@tm_wei_end_time [varchar](13),@tm_ptr_start_time [varchar](13),@tm_ptr_end_time [varchar](13),@tm_chaling_start_time [varchar](13),@tm_chaling_end_time [varchar](13),@jd_start_time [varchar](13),@jd_end_time [varchar](13),@dy_start_time [varchar](13),@dy_end_time [varchar](13) AS
BEGIN
truncate table [DW_OMS].[DWS_PS_Phase2_Order];
insert into [DW_OMS].[DWS_PS_Phase2_Order]
    select
        case 
            when p.store_id = 'S001' then 'Dragon'
            when p.channel_id = 'TMALL' and p.shop_id = 'TM2' then 'TMALL_WEI'
	        when p.channel_id = 'TMALL' and p.store_id = 'TMALL004' then 'TMALL_CHALING' 
            when p.channel_id = 'TMALL' and p.store_id = 'TMALL005' then 'TMALL_PTR'
            else p.channel_id 
        end as store,
        p.sales_order_number,
        p.purchase_order_number,
        s.place_time as payment_time,
        cast(s.place_time as date) as payment_date,
        p.payed_amount,
        p.order_internal_status,
        case
            p.order_internal_status
            when 'SHIPPED' then 'DELIVERY'
            when 'SIGNED' then 'DELIVERY'
            when 'REJECTED' then 'DELIVERY'
            when 'INTERCEPT' then 'DELIVERY'
            when 'CANT_CONTACTED' then 'DELIVERY'
            when 'CANCELLED' then 'CANCEL'
            when 'PARTAIL_CANCEL' then 'CANCEL'
            when 'WAIT_SAPPROCESS' then 'WAITING'
            when 'EXCEPTION' then 'WAITING'
            when 'PENDING' then 'WAITING'
            when 'WAIT_JD_CONFIRM' then 'WAITING'
            when 'WAIT_JDPROCESS' then 'WAITING'
            when 'WAIT_SEND_SAP' then 'WAITING'
            when 'WAIT_TMALLPROCESS' then 'WAITING'
            when 'WAIT_WAREHOUSE_PROCESS' then 'WAITING'
            when 'SPLITED' then 'WAITING'
            when 'WAIT_ROUTE_ORDER' then 'WAITING'
            else 'OTHER' 
        end as status,
        p.shipping_time as shipping_time,
        cast(p.shipping_time as date) as shipping_date,
        current_timestamp as insert_timestamp
    from
    (
        select
        *,
        case when [type] = 8 or ( [type] != 8 and payment_status = 1) then 1 else 0 end as is_placed_flag,
        case when [type] <> 8 then payment_time else order_time end as place_time
        from 
        [STG_OMS].[v_Sales_Order_rt]
        where 
        (store_id = 'S001' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @dragon_start_time and @dragon_end_time)) 
        or (store_id in ('TMALL001','TMALL002') and shop_id is null and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_start_time and @tm_end_time))
        or (store_id = 'TMALL004' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_chaling_start_time and @tm_chaling_end_time))
        or (store_id = 'TMALL005' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_ptr_start_time and @tm_ptr_end_time))
        or (channel_id = 'TMALL' and shop_id = 'TM2' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_wei_start_time and @tm_wei_end_time))

        or (channel_id = 'JD' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @jd_start_time and @jd_end_time))
        or (channel_id = 'DOUYIN' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @dy_start_time and @dy_end_time))
    )s
    left join
    (
        select * from [STG_OMS].[v_Purchase_Order_rt] 
            where 
            (format(sys_create_time,'yyyy-MM-dd HH')>= @dragon_start_time and store_id = 'S001')
            or (format(sys_create_time,'yyyy-MM-dd HH')>= @tm_start_time and store_id in ('TMALL001','TMALL002') and shop_id is null )
            or (format(sys_create_time,'yyyy-MM-dd HH')>= @tm_chaling_start_time and store_id = 'TMALL004')
            or (format(sys_create_time,'yyyy-MM-dd HH')>= @tm_ptr_start_time and store_id = 'TMALL005')
            or (format(sys_create_time,'yyyy-MM-dd HH')>= @tm_wei_start_time and channel_id = 'TMALL' and shop_id = 'TM2')

            or (format(sys_create_time,'yyyy-MM-dd HH')>= @jd_start_time and channel_id = 'JD')
            or (format(sys_create_time,'yyyy-MM-dd HH')>= @dy_start_time and channel_id = 'DOUYIN')
        
    ) p 
    on p.sales_order_sys_id = s.sales_order_sys_id
    where
        (p.basic_status != 'DELETED' or p.order_internal_status = 'PARTAIL_CANCEL')
        and p.order_internal_status in ('SHIPPED', 'SIGNED','REJECTED','INTERCEPT','CANT_CONTACTED','CANCELLED','PARTAIL_CANCEL','WAIT_SAPPROCESS','EXCEPTION','PENDING','WAIT_SEND_SAP','WAIT_WAREHOUSE_PROCESS','WAIT_ROUTE_ORDER','SPLITED')
        and p.store_id != 'GWP001'
        and p.type != 2
        and p.split_type != 'SPLIT_ORIGIN'
		and s.is_placed_flag = 1 -- adhoc added for 202110 PS
        -- and cast(case when s.type != 8 then s.payment_time else s.order_time end as date) >= '2021-09-02'
    union all
    select
        case 
            when s.store_id = 'S001' then 'Dragon'
            when s.channel_id = 'TMALL' and s.shop_id = 'TM2' then 'TMALL_WEI'
	        when s.channel_id = 'TMALL' and s.store_id = 'TMALL004' then 'TMALL_CHALING' 
            when s.channel_id = 'TMALL' and s.store_id = 'TMALL005' then 'TMALL_PTR'
            else s.channel_id 
        end as store,
        s.sales_order_number,
        null as purchase_order_number,
        s.place_time as payment_time,
        cast(s.place_time as date) as payment_date,
        s.payed_amount,
        s.order_internal_status,
        case
            s.order_internal_status
            when 'SHIPPED' then 'DELIVERY'
            when 'SIGNED' then 'DELIVERY'
            when 'REJECTED' then 'DELIVERY'
            when 'INTERCEPT' then 'DELIVERY'
            when 'CANT_CONTACTED' then 'DELIVERY'
            when 'CANCELLED' then 'CANCEL'
            when 'PARTAIL_CANCEL' then 'CANCEL'
            when 'WAIT_SAPPROCESS' then 'WAITING'
            when 'EXCEPTION' then 'WAITING'
            when 'PENDING' then 'WAITING'
            when 'WAIT_JD_CONFIRM' then 'WAITING'
            when 'WAIT_JDPROCESS' then 'WAITING'
            when 'WAIT_SEND_SAP' then 'WAITING'
            when 'WAIT_TMALLPROCESS' then 'WAITING'
            when 'WAIT_WAREHOUSE_PROCESS' then 'WAITING'
            when 'SPLITED' then 'WAITING'
            when 'WAIT_ROUTE_ORDER' then 'WAITING'
            else 'OTHER' 
        end as status, 
        null as shipping_time,
        null as shipping_date,
        current_timestamp as insert_timestamp
    from
    (
        select
        *,
        case when [type] = 8 or ( [type] != 8 and payment_status = 1) then 1 else 0 end as is_placed_flag,
        case when [type] <> 8 then payment_time else order_time end as place_time
        from 
        [STG_OMS].[v_Sales_Order_rt]
        where 
        (store_id = 'S001' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @dragon_start_time and @dragon_end_time)) 
        or (store_id in ('TMALL001','TMALL002') and shop_id is null and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_start_time and @tm_end_time))
        or (store_id = 'TMALL004' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_chaling_start_time and @tm_chaling_end_time))
        or (store_id = 'TMALL005' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_ptr_start_time and @tm_ptr_end_time))
        or (channel_id = 'TMALL' and shop_id = 'TM2' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @tm_wei_start_time and @tm_wei_end_time))

        or (channel_id = 'JD' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @jd_start_time and @jd_end_time))
        or (channel_id = 'DOUYIN' and (FORMAT(case when [type] <> 8 then payment_time else order_time end,'yyyy-MM-dd HH') between @dy_start_time and @dy_end_time))
    )s
    left join
    (
        select * from [STG_OMS].[v_Purchase_Order_rt] 
        where 
        (format(sys_create_time,'yyyy-MM-dd HH')>= @dragon_start_time and store_id = 'S001')
        or (format(sys_create_time,'yyyy-MM-dd HH')>= @tm_start_time and store_id in ('TMALL001','TMALL002') and shop_id is null )
        or (format(sys_create_time,'yyyy-MM-dd HH')>= @tm_chaling_start_time and store_id = 'TMALL004')
        or (format(sys_create_time,'yyyy-MM-dd HH')>= @tm_ptr_start_time and store_id = 'TMALL005')
        or (format(sys_create_time,'yyyy-MM-dd HH')>= @tm_wei_start_time and channel_id = 'TMALL' and shop_id = 'TM2')
        or (format(sys_create_time,'yyyy-MM-dd HH')>= @jd_start_time and channel_id = 'JD')
        or (format(sys_create_time,'yyyy-MM-dd HH')>= @dy_start_time and channel_id = 'DOUYIN')
    ) p 
    on p.sales_order_sys_id = s.sales_order_sys_id
    where
        s.store_id != 'GWP001'
        and s.basic_status != 'DELETED'
        and is_placed_flag = 1
        and s.order_internal_status in ('EXCEPTION', 'WAIT_JD_CONFIRM', 'PENDING','WAIT_TMALLPROCESS')
        and p.sales_order_sys_id is null;
        -- and cast(place_time as date) >= '2021-09-02'
end;
GO
