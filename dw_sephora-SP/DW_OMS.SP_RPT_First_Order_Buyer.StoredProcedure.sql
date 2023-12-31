/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_First_Order_Buyer]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_First_Order_Buyer] AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- ========================================================================================
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
            when sub_channel_code in('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM') then 'MiniProgram'
            when sub_channel_code in('APP(IOS)','APP(ANDROID)','APP') then 'APP'
            else sub_channel_code 
        end as channel_cd,
        order_date,
        place_time
    from
        [RPT].[RPT_Sales_Order_Basic_Level]
    where 
        is_placed=1
        and order_date >='2020-01-01'
        and channel_order_placed_seq=1
        and sub_channel_code in('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','APP(IOS)','APP(ANDROID)','APP')
)a
group by 
    channel_cd,
    card_no;
UPDATE STATISTICS DW_OMS.RPT_First_Order_Buyer;
END

GO
