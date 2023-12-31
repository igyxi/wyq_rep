/****** Object:  StoredProcedure [DWD].[SP_Fact_Payment_Order_History]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Payment_Order_History] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-22       houshuangqiang           Initial Version
-- 2023-06-15       houshuangqiang           fix duplication logic
-- ========================================================================================
truncate table [DWD].[Fact_Payment_Order];
insert into DWD.Fact_Payment_Order
select	p.sales_order_payment_sys_id as id
        ,p.payment_serial_id
        ,p.payment_no
        ,o.sales_order_number
        ,o.member_card
        ,o.member_card_grade
        ,p.payment_amoutn as payment_amount
--        ,o.payed_amount  -- 订单表中的支付金额和付款表中的支付金额有差异
--        ,o.payable_amount
        ,p.payment_method
        ,p.payment_status
--        ,o.payment_status
        ,p.payment_type
        ,p.payment_time
--        ,o.payment_time
        ,p.payment_code
        ,p.payment_comment
        ,p.create_time
        ,p.create_op
        ,p.update_time
        ,p.update_op
        ,'OMS' as source
        ,current_timestamp as insert_timestamp
from    
(
	select 	*,row_number() over(partition by payment_no,sales_order_sys_id order by sales_order_payment_sys_id desc) as row_rank
	from 	STG_OMS.Sales_Order_Payment
        where   payment_no is not null
) p 
inner   join  STG_OMS.Sales_Order o -- 存在sales_order_sys_id关联不上的情况
on      p.sales_order_sys_id = o.sales_order_sys_id
where 	p.row_rank = 1

END
GO
