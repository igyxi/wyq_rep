/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Convert_old]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Convert_old] AS
BEGIN
truncate table DW_Sensor.RPT_Sensor_MNP_APP_Convert;
insert into DW_Sensor.RPT_Sensor_MNP_APP_Convert
select cast(a.first_order_date as varchar(7)) as statics_month, a.channel_cd, case when datediff(day,b.first_date,a.first_order_date)=0 then '0'          when datediff(day,b.first_date,a.first_order_date) between 1 and 30 then '1~30'          when datediff(day,b.first_date,a.first_order_date) between 31 and 60 then '31~60'          when datediff(day,b.first_date,a.first_order_date) between 61 and 90 then '61~90'          when datediff(day,b.first_date,a.first_order_date)>=91 then '>90'     end as convert_duration, count(distinct a.card_no) as cross_buyers, current_timestamp as insert_timestamp
from [DW_OMS].[DWS_First_Order_Buyer] a inner join (     select card_no, platform_type, min(first_date) as first_date
    from DW_Sensor.DWS_Sensor_User_First_Login
    where dt <= '2022-01-31'
    --where         dt='2022-01-31' DWS_Sensor_User_First_Login表优化前逻辑
    group by         card_no,         platform_type )b on a.card_no collate Chinese_PRC_CS_AI_WS = b.card_no and a.channel_cd collate Chinese_PRC_CS_AI_WS = b.platform_type
where     a.first_order_date >= b.first_date
group by      cast(a.first_order_date as varchar(7)),     a.channel_cd,     case when datediff(day,b.first_date,a.first_order_date)=0 then '0'          when datediff(day,b.first_date,a.first_order_date) between 1 and 30 then '1~30'          when datediff(day,b.first_date,a.first_order_date) between 31 and 60 then '31~60'          when datediff(day,b.first_date,a.first_order_date) between 61 and 90 then '61~90'          when datediff(day,b.first_date,a.first_order_date)>=91 then '>90'     end
;
end
GO
