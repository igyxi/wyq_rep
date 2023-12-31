/****** Object:  StoredProcedure [TEMP].[SP_Fact_Giftcard_Order_Bak_20230228]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Giftcard_Order_Bak_20230228] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-12       litao           Initial Version
-- 2023-01-17       litao           add payment_time,order_status,is_placed
-- ========================================================================================


truncate table [DWD].[Fact_Giftcard_Order];
insert into [DWD].[Fact_Giftcard_Order]
select  
        item.id,--权益卡卡号 
        o.order_id,
        o.trans_id,
        o.outer_str as channel_code,
        o.scene,
        o.member_id,
        item.goods_id,
        item.goods_name,
        item.quantity,
        item.price as sales_amount,
        case when o.status = 1 then N'已支付'
             when o.status = 2 then N'退款'
        end as order_type, 
        case when o.status=1 then N'已支付'
             when o.status=2 then N'已退款'
			 when o.status=3 then N'部分退款'
			 when o.status=4 then N'退款中'
		end as order_status,
        case when o.status in (1,2,3) then 1
             when o.status=4 then 0 
        end as is_placed,
		o.pay_finish_time as payment_time,		
        o.create_time,
        o.update_time,
        current_timestamp as insert_timestamp
from STG_ECard.GiftCard_Equity_Card_Order o
left join STG_ECard.GiftCard_Equity_Card_Order_Code item 
on      o.order_id = item.order_id
;
END
 
GO
