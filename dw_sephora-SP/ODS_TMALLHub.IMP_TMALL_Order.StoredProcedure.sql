/****** Object:  StoredProcedure [ODS_TMALLHub].[IMP_TMALL_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TMALLHub].[IMP_TMALL_Order] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_TMALLHub.TMALL_Order where dt = @dt;
insert into ODS_TMALLHub.TMALL_Order
select 
    a.id,
	order_id,
	oaid,
	discount_fee,
	buyer_nick,
	created,
	status,
	pay_time,
	buyer_memo,
	buyer_message,
	payment,
	post_fee,
	receiver_address,
	receiver_city,
	receiver_district,
	receiver_mobile,
	receiver_name,
	receiver_phone,
	receiver_state,
	receiver_zip,
	type,
	order_tax_fee,
	is_sync,
	last_sync_status,
	logistics_number,
	logistics_company,
	consign_time,
	is_delete,
	create_time,
	update_time,
	create_user,
	update_user,
	sign_time,
	end_time,
	member_card_no,
	member_card_level,
	jdp_modified,
	seller_nick,
	is_encrypted,
    @dt as dt
from 
(
    select * from ODS_TMALLHub.TMALL_Order where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_TMALLHub.WRK_TMALL_Order
) b
on a.id = b.id
where b.id is null
union all
select 
    id,
    order_id,
	oaid,
	discount_fee,
	buyer_nick,
	created,
	status,
	pay_time,
	buyer_memo,
	buyer_message,
	payment,
	post_fee,
	convert(varchar,HASHBYTES('SHA2_256', receiver_address),2) as receiver_address,
	receiver_city,
	receiver_district,
	convert(varchar,HASHBYTES('MD5', receiver_mobile),2) as receiver_mobile,
	receiver_name,
	convert(varchar,HASHBYTES('MD5', receiver_phone),2) as receiver_phone,
	receiver_state,
	receiver_zip,
	type,
	order_tax_fee,
	is_sync,
	last_sync_status,
	logistics_number,
	logistics_company,
	consign_time,
	is_delete,
	create_time,
	update_time,
	create_user,
	update_user,
	sign_time,
	end_time,
	member_card_no,
	member_card_level,
	jdp_modified,
	seller_nick,
	is_encrypted,	
    @dt as dt
from 
    ODS_TMALLHub.WRK_TMALL_Order;
delete from ODS_TMALLHub.TMALL_Order where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
truncate table ODS_TMALLHub.WRK_TMALL_Order;
END



GO
