/****** Object:  StoredProcedure [TEMP].[IMP_Sales_Order_Address_Bak20220826]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[IMP_Sales_Order_Address_Bak20220826] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Sales_Order_Address where dt = @dt;
insert into ODS_OMS.Sales_Order_Address
select 
    sales_order_address_sys_id,
    sales_order_sys_id,
    r_oms_order_sys_id,
    convert(varchar(max), HASHBYTES('MD5', mobile),2) as mobile,
    convert(varchar(max), HASHBYTES('MD5', pohone),2) as pohone,
    name,
    province,
    city,
    district,
    convert(varchar(max), HASHBYTES('SHA2_256', address),2) as address,
    order_zip,
    is_delete,
    create_op,
    create_time,
    update_op,
    update_time,
    country,
    convert(varchar(max), HASHBYTES('SHA2_256', email),2) as email,
    address_type,
    address_seq,
    sys_create_time,
    sys_update_time,
    name_invalid,
    address_invalid,
    is_encrypt,
    desen_mobile,
    desen_telephone,
    oaid,
    @dt as dt 
from 
    ODS_OMS.WRK_Sales_Order_Address;
truncate table ODS_OMS.WRK_Sales_Order_Address;
END

GO
