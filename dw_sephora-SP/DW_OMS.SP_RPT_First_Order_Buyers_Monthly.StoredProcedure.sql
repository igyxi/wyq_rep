/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_First_Order_Buyers_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_First_Order_Buyers_Monthly] AS 
begin
truncate table [DW_OMS].[RPT_First_Order_Buyers_Monthly];
insert into [DW_OMS].[RPT_First_Order_Buyers_Monthly]
select
    cast(first_order_date as varchar(7)) as statics_month,
    channel_cd,
    count(card_no) as buyers,
    current_timestamp as insert_timestamp
from
    DW_OMS.RPT_First_Order_Buyer
group by 
    cast(first_order_date as varchar(7)),
    channel_cd;
UPDATE STATISTICS DW_OMS.RPT_First_Order_Buyers_Monthly;
END

GO
