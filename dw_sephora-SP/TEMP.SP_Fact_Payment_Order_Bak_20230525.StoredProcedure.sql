/****** Object:  StoredProcedure [TEMP].[SP_Fact_Payment_Order_Bak_20230525]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Payment_Order_Bak_20230525] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-12       houshuangqiang           Initial Version(New OMS)
-- 2023-04-24       zeyuan                   修改主题域 
-- ========================================================================================
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
where   payment.data_update_time >= '2023-05-23 17:15:00'
and     payment.data_update_time <= '2023-05-23 17:30:00'   
and     so.data_update_time >= '2023-05-23 17:15:00'
and     so.data_update_time <= '2023-05-23 17:30:00'     
--where   payment.platform = 'SOA' -- 核对数据的话，只用取SOA官网的数据

END
GO
