/****** Object:  StoredProcedure [DWD].[SP_Fact_Payment_Order_Bak_20230616]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Payment_Order_Bak_20230616] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-12       houshuangqiang           Initial Version(New OMS)
-- 2023-04-24       zeyuan                   修改主题域 
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
truncate table DWD.Fact_Payment_Order_New;
insert into DWD.Fact_Payment_Order_New
select  payment.id              -- 这是new oms新增的字段
        ,payment.payment_id     -- 这是new oms新增的字段
        ,case when payment.platform = 'jingdong' then 'JDDJ'
              when payment.platform = 'douyinxiaodian' then 'DOUYIN'
              when payment.platform = 'taobao' then 'TMALL'
              else upper(payment.platform)
        end as channel_code       -- 这是new oms新增的字段
        ,payment.tid as sales_order_number
        ,so.vip_card_no as member_card
        ,case when so.member_level_name = 'GOLDEN' then 'GOLD' else so.member_level_name end as member_card_grade
        ,payment.payment_amt as payment_amount
        ,payment.surplus_amount -- 这是new oms新增的字段
        ,payment.payment_method
        ,payment.payment_status
        ,payment.order_pay_type as payment_type
        ,payment.payment_date as payment_time
        ,payment.payment_no
        ,payment.payment_code
        ,null as payment_serial_id
        ,null as payment_comment
        ,payment.bank_type_code as promotion_code -- 这是new oms新增的字段
        ,payment.bank_type_name as promotion_name -- 这是new oms新增的字段
        ,payment.data_create_time as create_time
        ,null as create_op
        ,payment.data_update_time as update_time
        ,null as update_op
        ,'OMS' as source
        ,current_timestamp as insert_timestamp
from    ODS_New_OMS.OMS_STD_Trade_Payment_Method payment
left    join ODS_New_OMS.OMS_STD_Trade so
on      payment.tid = so.tid
inner   join stg_oms.oms_to_oims_sync_fail_log fail 
on      so.tid = fail.sales_order_number
and     fail.sync_status = 1
and     fail.update_time >= @start_time
and     fail.update_time <= @end_time

-- where   payment.data_update_time >= '2023-05-25 18:39:22'
-- and     payment.data_update_time <= '2023-05-26 00:03:00'
-- and     so.data_update_time >= '2023-05-25 18:39:22'
-- and     so.data_update_time <= '2023-05-26 00:03:00'
--where   payment.platform = 'SOA' -- 核对数据的话，只用取SOA官网的数据

END
GO
