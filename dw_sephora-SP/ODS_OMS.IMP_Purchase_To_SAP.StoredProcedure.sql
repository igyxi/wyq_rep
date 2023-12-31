/****** Object:  StoredProcedure [ODS_OMS].[IMP_Purchase_To_SAP]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Purchase_To_SAP] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Purchase_To_SAP where dt = @dt;
insert into ODS_OMS.Purchase_To_SAP
select 
    a.purchase_to_sap_sys_id,
	purchase_order_sys_id,
	pos_filename,
	ors_create_time,
	m50_sync_time,
	pos_sync_status,
	pos_sync_time,
	ors_filename,
	purchase_order_number,
	ors_generated_status,
	ors_model,
	store_location_id,
	create_time,
	update_time,
	m50_generated_status,
	ors_num,
	invoice_id,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_OMS.Purchase_To_SAP where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select purchase_to_sap_sys_id from ODS_OMS.WRK_Purchase_To_SAP
) b
on a.purchase_to_sap_sys_id = b.purchase_to_sap_sys_id
where b.purchase_to_sap_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_Purchase_To_SAP;
delete from ODS_OMS.Purchase_To_SAP where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
