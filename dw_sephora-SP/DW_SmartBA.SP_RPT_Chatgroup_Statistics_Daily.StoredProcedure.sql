/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_Chatgroup_Statistics_Daily]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_Chatgroup_Statistics_Daily] @dt [varchar](10) AS 
BEGIN
delete from DW_SmartBA.RPT_Chatgroup_Statistics_Daily where dt = @dt;
insert into DW_SmartBA.RPT_Chatgroup_Statistics_Daily
select
    place_date,
    chat_name,
    chat_type,
    channel_name, 
    count(distinct sales_order_number) as order_cnt,
    sum(payed_amount) as amount,
    count(distinct member_card) as buyers,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        distinct
        place_date,
        chat_name,
        chat_type,
        channel_name, 
        sales_order_number,
        payed_amount,
        member_card
    from
        DW_SmartBA.RPT_Chatgroup_Sales_Order_Detail
    where
        place_date = @dt   
        and payment_date is not null
) a   
group by 
    place_date,
    chat_name,
    chat_type,
    channel_name;
END


GO
