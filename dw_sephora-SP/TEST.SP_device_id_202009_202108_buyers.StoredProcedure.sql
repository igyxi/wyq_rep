/****** Object:  StoredProcedure [TEST].[SP_device_id_202009_202108_buyers]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_device_id_202009_202108_buyers] @dt [varchar](10) AS
begin
delete from [test].[device_id_202009_202108_buyers] where dt = @dt;
insert into test.device_id_202009_202108_buyers
select 
    distinct e.mobile_md5,t.active_date
from 
(
    select 
        distinct a.android_id as device_id,'android_id' as device_id_type,b.user_id,a.active_date
    from
    (
    select distinct android_id,cast(active_time as date) as active_date
    from ODS_TD.Tb_Android_Install
    where cast(active_time as date) = @dt
    )a
    inner join
    (
        select distinct
            android_id,
            user_id
        from
            DW_Sensor.DWS_Sensor_User_Info with (nolock)
        where 
            dt >= @dt 
        and 
            user_id is not null
        and 
            android_id is not null
    )b
    on 
        a.android_id COLLATE Chinese_PRC_CS_AI_WS = b.android_id
    union all 
    select 
        distinct a.idfa as device_id,'idfa' as device_id_type,b.user_id,a.active_date
    from
    (
    select distinct idfa,cast(active_time as date) as active_date
    from ODS_TD.Tb_IOS_Install
    where cast(active_time as date) = @dt
    )a
    inner join
    (
        select distinct
            idfa,
            user_id
        from
            DW_Sensor.DWS_Sensor_User_Info with (nolock)
        where 
            dt >= @dt
        and 
            user_id is not null
        and 
            idfa is not null
    )b
    on 
        a.idfa COLLATE Chinese_PRC_CS_AI_WS = b.idfa
)t
inner join 
(select distinct sephora_user_id,sales_order_sys_id from DW_OMS.RPT_Sales_Order_Basic_Level 
where is_placed_flag=1
and place_date between '2020-09-01' and '2021-08-31'
)c
on t.user_id = c.sephora_user_id
inner JOIN DW_Sephora.STG_OMS.Order_Guid_Info d
on c.sales_order_sys_id = d.sales_order_sys_id
inner JOIN ods_oms.Mobile_Mapping e
on d.mobile_guid = e.mobile_id;
end
GO
