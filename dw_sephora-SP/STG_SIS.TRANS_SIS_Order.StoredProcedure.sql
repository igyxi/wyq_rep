/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Order] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-26       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Order;
insert into STG_SIS.SIS_Order
select 
		id,
		case when trim(order_no) in ('','null') then null else trim(order_no) end as order_no,
		total_amount,
		goods_amount,
		freight,
		status,
		activity_id,
		company_id,
		case when trim(open_id) in ('','null') then null else trim(open_id) end as open_id,
		case when trim(card_no) in ('','null') then null else trim(card_no) end as card_no,
		case when trim(del_flag) in ('','null') then null else trim(del_flag) end as del_flag,
		create_time,
		update_time,
		pay_time,
		case when trim(wechat_no) in ('','null') then null else trim(wechat_no) end as wechat_no,
		case when trim(prepay_no) in ('','null') then null else trim(prepay_no) end as prepay_no,
		case when trim(receiver) in ('','null') then null else trim(receiver) end as receiver,
		case when trim(province) in ('','null') then null else trim(province) end as province,
		case when trim(city) in ('','null') then null else trim(city) end as city,
		case when trim(district) in ('','null') then null else trim(district) end as district,
		case when trim(mobile) in ('','null') then null else trim(mobile) end as mobile,
		case when trim(detail_address) in ('','null') then null else trim(detail_address) end as detail_address,
		case when trim(refund_id) in ('','null') then null else trim(refund_id) end as refund_id,
		refund_amount,
		case when trim(refund_desc) in ('','null') then null else trim(refund_desc) end as refund_desc,
		shipping_time,
		case when trim(shipping_code) in ('','null') then null else trim(shipping_code) end as shipping_code,
		case when trim(shipping_company_code) in ('','null') then null else trim(shipping_company_code) end as shipping_company_code,
		case when trim(real_warehouse) in ('','null') then null else trim(real_warehouse) end as real_warehouse,
		case when trim(def_warehouse) in ('','null') then null else trim(def_warehouse) end as def_warehouse,
		warehouse_close_order_time,
		shipping_sign_for_time,
		expiration_time,
		origin_total_amount,
		resend_oms,
		is_out_of_stock,
		case when trim(purchase_order_number) in ('','null') then null else trim(purchase_order_number) end as purchase_order_number,
		current_timestamp as insert_timestamp
from
(
    select *,row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Order
) t
where rownum = 1
END
GO
