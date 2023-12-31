/****** Object:  StoredProcedure [DWD].[SP_Fact_Payment_Order_Bak_20230620]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Payment_Order_Bak_20230620] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-22       houshuangqiang           Initial Version
-- ========================================================================================
truncate table [DWD].[Fact_Payment_Order];
insert into DWD.Fact_Payment_Order
select	o.sales_order_number
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
        ,p.payment_no
        ,p.payment_code
        ,p.payment_serial_id
        ,p.payment_comment
        ,p.create_time
        ,p.create_op
        ,p.update_time
        ,p.update_op
        ,'OMS' as source
        ,current_timestamp as insert_timestamp
from    STG_OMS.Sales_Order_Payment p
inner   join  STG_OMS.Sales_Order o -- 存在sales_order_sys_id关联不上的情况
on      p.sales_order_sys_id = o.sales_order_sys_id
--where 	o.sales_order_number = '2094130188288461869'
--where 	p.payment_amoutn <> o.payed_amount

END
GO
