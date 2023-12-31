/****** Object:  StoredProcedure [REALTIME_OMS].[SP_Computer_Dragon_Sales_By_Channel_Accmulated_History]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [REALTIME_OMS].[SP_Computer_Dragon_Sales_By_Channel_Accmulated_History] @dt [VARCHAR](10) AS
BEGIN
delete from REALTIME_OMS.Computer_Dragon_Sales_By_Channel_Accmulated_History where dt =@dt;
insert into REALTIME_OMS.Computer_Dragon_Sales_By_Channel_Accmulated_History
select 
    channel_id
    ,sum(payed_amount) as channel_amt
    ,@dt as dt
    ,DATEADD(HOUR,8, CURRENT_TIMESTAMP) as insert_timestamp
from 
    REALTIME_OMS.V_Process_Computer_Dragon_Sales_Order_Accumulated 
where 
    payment_time < format(DATEADD(DAY,1,@dt), 'yyyy-MM-dd')
group by 
    channel_id
;    
END
GO
