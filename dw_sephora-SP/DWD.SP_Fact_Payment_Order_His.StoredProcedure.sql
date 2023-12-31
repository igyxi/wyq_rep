/****** Object:  StoredProcedure [DWD].[SP_Fact_Payment_Order_His]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Payment_Order_His] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-22       houshuangqiang           Initial Version
-- ========================================================================================
DECLARE @start_time datetime = null;
DECLARE @end_time datetime = null;
select
    -- get max timestamp of the day before
    @start_time = start_time,
    @end_time = end_time
from
(
   select top 1 start_time, end_time from [DW_OMS_Order].[DW_Datetime_Config] where is_delete = '0'  order by start_time desc
) t
;

truncate table [DWD].[Fact_Payment_Order_His];
insert into DWD.Fact_Payment_Order_His
select	p.sales_order_payment_sys_id
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
inner   join stg_oms.oms_to_oims_sync_fail_log fail 
on      o.sales_order_number = fail.sales_order_number
and     fail.sync_status = 1
and     fail.update_time >= @start_time
and     fail.update_time <= @end_time
where   p.row_rank = 1
--where 	o.sales_order_number = '2094130188288461869'
--where 	p.payment_amoutn <> o.payed_amount

END
GO
