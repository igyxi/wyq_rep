/****** Object:  StoredProcedure [STG_ECard].[TRANS_EntityCard_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_EntityCard_Order] @dt [varchar](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_Ecard.EntityCard_Order;
insert into STG_Ecard.EntityCard_Order
select 
		id,
		case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
		case when trim(wechat_order_id) in ('', 'null', 'None') then null else trim(wechat_order_id) end as wechat_order_id,
		case when trim(trans_id) in ('', 'null', 'None') then null else trim(trans_id) end as trans_id,
		case when trim(prepay_id) in ('', 'null', 'None') then null else trim(prepay_id) end as prepay_id,
		case when trim(pos_number) in ('', 'null', 'None') then null else trim(pos_number) end as pos_number,
		quantity,
		receive_quantity,
		total_price,
        order_status,
		case when trim(mini_openid) in ('', 'null', 'None') then null else trim(mini_openid) end as mini_openid,
		case when trim(openid) in ('', 'null', 'None') then null else trim(openid) end as openid,
		case when trim(unionid) in ('', 'null', 'None') then null else trim(unionid) end as unionid,
		expire,
		pay_finish_time,
		case when trim(store_sn) in ('', 'null', 'None') then null else trim(store_sn) end as store_sn,
		case when trim(store_staff) in ('', 'null', 'None') then null else trim(store_staff) end as store_staff,
		case when trim(store_name) in ('', 'null', 'None') then null else trim(store_name) end as store_name,
        status,
        pay_status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
FROM 
    ODS_Ecard.EntityCard_Order
WHERE
    dt=@dt
END
GO
