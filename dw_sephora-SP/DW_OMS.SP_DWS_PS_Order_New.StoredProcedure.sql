/****** Object:  StoredProcedure [DW_OMS].[SP_DWS_PS_Order_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DWS_PS_Order_New] AS
BEGIN
truncate table [DW_OMS].[DWS_PS_Order_New];
insert into [DW_OMS].[DWS_PS_Order_New]
select distinct 
    ps_channel, 
    sales_order_number, 
    [purchase_order_number], 
    payment_time, 
    format(payment_time, 'yyyy-MM-dd') as payment_date,
    payment_amount, 
    order_status, 
    CASE order_status
        WHEN 'SHIPPED' THEN 'DELIVERY'
        WHEN 'SIGNED' THEN 'DELIVERY'
        WHEN 'REJECTED' THEN 'DELIVERY'
        WHEN 'INTERCEPT' THEN 'DELIVERY'
        WHEN 'CANT_CONTACTED' THEN 'DELIVERY'
        WHEN 'CANCELLED' THEN 'CANCEL'
        WHEN 'PARTAIL_CANCEL' THEN 'CANCEL'
        WHEN 'WAIT_SAPPROCESS' THEN 'WAITING'
        WHEN 'EXCEPTION' THEN 'WAITING'
        WHEN 'PENDING' THEN 'WAITING'
        WHEN 'WAIT_JD_CONFIRM' THEN 'WAITING'
        WHEN 'WAIT_JDPROCESS' THEN 'WAITING'
        WHEN 'WAIT_SEND_SAP' THEN 'WAITING'
        WHEN 'WAIT_TMALLPROCESS' THEN 'WAITING'
        WHEN 'WAIT_WAREHOUSE_PROCESS' THEN 'WAITING'
        WHEN 'SPLITED' THEN 'WAITING'
        WHEN 'WAIT_ROUTE_ORDER' THEN 'WAITING'
        ELSE 'OTHER'
    END AS [status], 
    shipping_time,
    format(shipping_time, 'yyyy-MM-dd') as shipping_date,
    CURRENT_TIMESTAMP
from 
(
    select 
        *, 
        CASE
            WHEN channel_code = 'SOA' THEN 'Dragon'
            WHEN sub_channel_code IN ('TMALL001','TMALL002') THEN 'TMALL_Sephora'
            WHEN sub_channel_code = 'TMALL004' THEN 'TMALL_CHALING'
            WHEN sub_channel_code = 'TMALL005' THEN 'TMALL_PTR'
            WHEN sub_channel_code = 'TMALL006' THEN 'TMALL_WEI'
            WHEN sub_channel_code IN ('JD001','JD002') THEN 'JD_FSS'
			WHEN sub_channel_code = 'JD003' THEN 'JD_FCS'
            WHEN channel_code = 'DOUYIN' THEN 'DOUYIN'
        END as ps_channel
    from DWD.Fact_Sales_Order a
    where is_placed = 1 
    and source = 'OMS'
) t
join
    DATA_OPS.DIM_PrivateSales_Config b
on case when t.ps_channel in ('JD_FSS', 'JD_FCS') then 'JD' else t.ps_channel end = b.Channel
and b.[Status] = 1
where 
    format(t.place_time, 'yyyy-MM-dd HH') between FORMAT(StartDate,'yyyy-MM-dd')+' '+LTRIM(StartHour) and FORMAT(EndDate,'yyyy-MM-dd')+' '+LTRIM(EndHour)
;
END

GO
