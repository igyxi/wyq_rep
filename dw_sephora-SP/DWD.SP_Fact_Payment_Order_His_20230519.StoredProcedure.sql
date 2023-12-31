/****** Object:  StoredProcedure [DWD].[SP_Fact_Payment_Order_His_20230519]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Payment_Order_His_20230519] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-22       houshuangqiang           Initial Version
-- ========================================================================================
truncate table [DWD].[Fact_Payment_Order_His];
insert into DWD.Fact_Payment_Order_His
select	o.sales_order_number
        ,o.member_card
        ,o.member_card_grade
        ,sum(p.payment_amoutn) as payment_amount
--        ,o.payed_amount  -- 订单表中的支付金额和付款表中的支付金额有差异
--        ,o.payable_amount
        ,p.payment_method
        ,p.payment_status
--        ,o.payment_status
        ,p.payment_type
        ,max(p.payment_time) as payment_time
--        ,o.payment_time
        ,p.payment_no
        ,p.payment_code
        ,p.payment_serial_id
        ,p.payment_comment
        ,max(p.create_time)
        ,max(p.create_op)
        ,max(p.update_time)
        ,max(p.update_op)
        ,'OMS' as source
        ,current_timestamp as insert_timestamp
from    STG_OMS.Sales_Order_Payment p
inner   join  STG_OMS.Sales_Order o -- 存在sales_order_sys_id关联不上的情况
on      p.sales_order_sys_id = o.sales_order_sys_id
inner   join stg_oms.oms_to_oims_sync_fail_log fail 
on      o.sales_order_number = fail.sales_order_number
and     fail.sync_status = 1
-- and     fail.update_time >= '2023-05-15 18:00:00'
-- and     fail.update_time <= '2023-05-15 20:00:00'
--where 	o.sales_order_number = '2094130188288461869'
--where 	p.payment_amoutn <> o.payed_amount
group 	by o.sales_order_number,o.member_card,o.member_card_grade,p.payment_method,p.payment_status,p.payment_type,p.payment_no,
		   p.payment_code,p.payment_serial_id,p.payment_comment
END
GO
