/****** Object:  StoredProcedure [ODS_OMS].[IMP_Purchase_Order_Address]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Purchase_Order_Address] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Purchase_Order_Address where dt = @dt;
insert into ODS_OMS.Purchase_Order_Address
select 
    purchase_order_address_sys_id,
    r_oms_stkout_hd_sys_id,
    purchase_order_sys_id,
    convert(varchar(max),HASHBYTES('SHA2_256', address), 2) as address,
    address_type,
    city,
    comment,
    country,
    create_op,
    create_time,
    district,
    sign_time,
    exp_tracking_number,
    exp_vendor,
    province,
    convert(varchar(max),HASHBYTES('SHA2_256', email),2) as email,
    convert(varchar(max),HASHBYTES('MD5', mobile),2) as mobile,
    name,
    convert(varchar(max),HASHBYTES('MD5', phone),2) as phone,
    shipping_time,
    status,
    update_op,
    update_time,
    warehouse_code,
    zipcode,
    basic_status,
    sys_create_time,
    sys_update_time,
    is_encrypt,
    desen_mobile,
    desen_telephone,
    @dt as dt 
from 
    ODS_OMS.WRK_Purchase_Order_Address;
truncate table ODS_OMS.WRK_Purchase_Order_Address;
END



GO
