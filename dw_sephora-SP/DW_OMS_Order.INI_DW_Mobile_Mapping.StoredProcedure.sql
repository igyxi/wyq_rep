/****** Object:  StoredProcedure [DW_OMS_Order].[INI_DW_Mobile_Mapping]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[INI_DW_Mobile_Mapping] @dt [VARCHAR](10) AS 
begin

truncate table DW_OMS_Order.DW_Mobile_Mapping;
insert into DW_OMS_Order.DW_Mobile_Mapping
select 	row_number() over(order by a.mobile_md5) as mobile_id,
		a.mobile_md5,
        @dt as dt
from
(
    select distinct 
	       case  when trim(receiver_mobile) not in ('','null') then trim(receiver_mobile)
                 when trim(receiver_phone) not in ('','null') then trim(receiver_phone)
           end   as mobile_md5                              
     from 
         ODS_OMS_Order.OMS_STD_Trade 
     where
         dt <= @dt
     and (trim(receiver_mobile) not in ('','null') or trim(receiver_phone) not in ('','null'))
) a
end
GO
