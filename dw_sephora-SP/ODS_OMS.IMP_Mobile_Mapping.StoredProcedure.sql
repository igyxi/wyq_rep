/****** Object:  StoredProcedure [ODS_OMS].[IMP_Mobile_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Mobile_Mapping] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Mobile_Mapping where dt = @dt;
insert into ODS_OMS.Mobile_Mapping
select 
    mobile_id,
    mobile_md5,
    @dt as dt 
from
(
    select
        t.mobile_id + coalesce( t1.max_mobile_id, 0) as mobile_id,
        t.mobile_md5 as mobile_md5
    from
    (
        select 
            row_number() over(order by a.mobile_md5) as mobile_id,
            a.mobile_md5
        from
        (
            select distinct 
                case 
                    when trim(mobile) not in ('','null') then trim(mobile)
                    when trim(pohone) not in ('','null') then trim(pohone)
                end as mobile_md5                             
            from 
                ODS_OMS.Sales_Order_Address 
            where
                dt = @dt
            and (trim(mobile) not in ('','null') or trim(pohone) not in ('','null'))
        ) a
        left join
        (
            select distinct mobile_md5 from ODS_OMS.Mobile_Mapping where dt < @dt
        ) b
        on 
            a.mobile_md5 = b.mobile_md5
        where 
            b.mobile_md5 is null
    )t
    cross join
    (
        select max(mobile_id) as max_mobile_id from ODS_OMS.Mobile_Mapping where dt < @dt
    ) t1
) t2
END


GO
