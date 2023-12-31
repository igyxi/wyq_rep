/****** Object:  StoredProcedure [TEMP].[SP_RPT_First_Order_Buyer_Bak_20230223]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_First_Order_Buyer_Bak_20230223] AS 
begin
truncate table [DW_OMS].[RPT_First_Order_Buyer];
insert into [DW_OMS].[RPT_First_Order_Buyer]
select
    min(order_date) as first_order_date,
    channel_cd,
    card_no,
    current_timestamp as insert_timestamp
from
(
    select
        member_card as card_no,
        case 
            when channel_cd in('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM') then 'MiniProgram'
            when channel_cd in('APP(IOS)','APP(ANDROID)','APP') then 'APP'
            else channel_cd 
        end as channel_cd,
        order_date,
        place_time
    from
        [DW_OMS].[RPT_Sales_Order_Basic_Level]
    where 
        is_placed_flag=1
        and order_date >='2020-01-01'
        and channel_order_placed_seq=1
        and channel_cd in('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','APP(IOS)','APP(ANDROID)','APP')
)a
group by 
    channel_cd,
    card_no;
UPDATE STATISTICS DW_OMS.RPT_First_Order_Buyer;
END

GO
