/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_Mobile_Mapping]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_Mobile_Mapping] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-26       houshuangqiang     从老OMS中切换至new oms中数据(老逻辑为：ODS_OMS.IMP_Mobile_Mapping)
-- ----------------------------------------------------------------------------------------
delete from DW_OMS_Order.DW_Mobile_Mapping where dt = @dt;
insert into DW_OMS_Order.DW_Mobile_Mapping
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
                   case  when trim(receiver_mobile) not in ('','null') then trim(receiver_mobile)
                         when trim(receiver_phone) not in ('','null') then trim(receiver_phone)
                   end   as mobile_md5
             from
                 ODS_OMS_Order.OMS_STD_Trade
             where
                 dt = @dt
             and (trim(receiver_mobile) not in ('','null') or trim(receiver_phone) not in ('','null'))
        ) a
        left join
        (
            select distinct mobile_md5 from DW_OMS_Order.DW_Mobile_Mapping where dt < @dt
        ) b
        on
            a.mobile_md5 = b.mobile_md5
        where
            b.mobile_md5 is null
    )t
    cross join
    (
        select max(mobile_id) as max_mobile_id from DW_OMS_Order.DW_Mobile_Mapping where dt < @dt
    ) t1
) t2
END
GO
