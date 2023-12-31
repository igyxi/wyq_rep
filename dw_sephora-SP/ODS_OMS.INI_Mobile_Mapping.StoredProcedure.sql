/****** Object:  StoredProcedure [ODS_OMS].[INI_Mobile_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[INI_Mobile_Mapping] @dt [VARCHAR](10) AS 
begin
truncate table ODS_OMS.Mobile_Mapping;
insert into ODS_OMS.Mobile_Mapping
select 
            row_number() over(order by a.mobile_md5) as mobile_id,
            a.mobile_md5,
            @dt as dt
        from
        (
            select distinct 
                case when trim(mobile) not in ('','null') then trim(mobile)
                     when trim(pohone) not in ('','null') then trim(pohone)
                     end
                     as mobile_md5
                                             
            from 
                ODS_OMS.Sales_Order_Address 
            where
                dt = @dt
            and (trim(mobile) not in ('','null') or trim(pohone) not in ('','null'))
        ) a
end
GO
