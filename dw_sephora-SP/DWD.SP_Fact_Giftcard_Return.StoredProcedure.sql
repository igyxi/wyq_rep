/****** Object:  StoredProcedure [DWD].[SP_Fact_Giftcard_Return]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Giftcard_Return] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-12       litao           Initial Version
-- 2023-01-17       litao           add order_status,is_placed
-- 2023-02-28       houshuangqiang     Change source_table
-- ========================================================================================

truncate table [DWD].[Fact_Giftcard_Return];
insert into [DWD].[Fact_Giftcard_Return]
select  
       a.id,
       a.order_id,
       a.trans_id,
       a.outer_str as channel_code,
       a.scene,
       coalesce(a.member_id, u.member_id) as member_id,
       b.goods_id,
       b.goods_name,       
       b.quantity,
       b.price as sales_amount,
       b.refund_fee as refund_amount,
	   case  when a.status=1 then N'已支付'
             when a.status=2 then N'已退款'
			 when a.status=3 then N'部分退款'
			 when a.status=4 then N'退款中'
		end as order_status,   
	   case when a.status in (1,2,3) then 1
            when a.status=4          then 0 
       end as is_placed,
       a.create_time,
       a.update_time,
       current_timestamp as insert_timestamp
from   ODS_ECard.GiftCard_Equity_Card_Order a
left join ODS_ECard.GiftCard_Equity_Card_Order_Code b 
on a.order_id = b.order_id
left join ODS_ECard.GiftCard_Userinfo u
on a.open_id =u.open_id
where b.status = 2 
and a.member_id != ''
;
END
GO
