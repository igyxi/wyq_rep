/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Convert_Medium]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Convert_Medium] @dt [VARCHAR](10) AS 
begin
truncate table DW_Sensor.RPT_Sensor_MNP_APP_Convert_Medium;
insert into DW_Sensor.RPT_Sensor_MNP_APP_Convert_Medium
select
    statics_month,
    channel_cd,
    avg_convert_duration,
    medium_convert_duration,
    current_timestamp as insert_timestamp
from
(
    select
        statics_month,
        channel_cd,
        convert_duration,
        sum(convert_duration) over (partition by channel_cd,statics_month)/count(card_no) over (partition by channel_cd,statics_month) as avg_convert_duration,
        case when row_no = Ceiling(max(row_no) over (partition by channel_cd,statics_month)/2) then convert_duration end as medium_convert_duration
    from
    (
        select
            a.card_no,
            cast(a.first_order_date as varchar(7)) as statics_month,
            a.channel_cd as channel_cd,
            datediff(day,b.first_date,a.first_order_date) as convert_duration,
            row_number() over (partition by channel_cd,cast(a.first_order_date as varchar(7)) order by datediff(day,b.first_date,a.first_order_date)) as row_no
        from
            DW_OMS.RPT_First_Order_Buyer a
        inner join
        (
            select 
                card_no,
                platform_type,
                min(first_date) as first_date
            from
                DW_Sensor.DWS_Sensor_User_First_Login  
            where
                dt<=@dt  --example: dt='2022-1-31' 因为志春修改了DWS_Sensor_User_First_Login逻辑 那么为了拿到历史所有数据 所以此处修改为 dt<=@dt
            group by
                card_no,
                platform_type
        )b
        on a.card_no collate Chinese_PRC_CS_AI_WS  = b.card_no
        and a.channel_cd collate Chinese_PRC_CS_AI_WS  = b.platform_type
        where
            a.first_order_date >= b.first_date
    )t
)t1
where 
    medium_convert_duration is not null
;

end 

GO
