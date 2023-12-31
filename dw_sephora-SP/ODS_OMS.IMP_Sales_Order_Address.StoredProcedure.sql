/****** Object:  StoredProcedure [ODS_OMS].[IMP_Sales_Order_Address]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Sales_Order_Address] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-31       wangzhichun        Initial Version
-- 2022-04-11       wangzhichun        add column
-- 2022-08-26       tali               delete HASHBYTES
-- ========================================================================================
delete from ODS_OMS.Sales_Order_Address where dt = @dt;
insert into ODS_OMS.Sales_Order_Address
select 
    sales_order_address_sys_id,
    sales_order_sys_id,
    r_oms_order_sys_id,
    mobile,
    pohone,
    name,
    province,
    city,
    district,
    address,
    order_zip,
    is_delete,
    create_op,
    create_time,
    update_op,
    update_time,
    country,
    email,
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
END


GO
