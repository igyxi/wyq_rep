/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Users_With_Card_Grade_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Users_With_Card_Grade_Monthly] @dt [VARCHAR](10) AS
begin
--统计app和MNP共有用户各卡别人数
delete from DW_Sensor.RPT_Sensor_MNP_APP_Users_With_Card_Grade_Monthly where dt = @dt;
insert into DW_Sensor.RPT_Sensor_MNP_APP_Users_With_Card_Grade_Monthly
SELECT distinct
    statics_month,
    count(distinct cross_user_id) as cross_buyers,
    card_grade,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
(
    SELECT
        statics_month,
        cross_user_id,
        case 
             when card_level = 1 then 'PINK'
             when card_level = 2 then 'WHITE'
             when card_level = 3 then 'BLACK'
             when card_level = 4 then 'GOLD'
             when card_level = 0 then 'Unknown'
        end as card_grade,
        dt
    FROM
    (
        SELECT
            statics_month,
            cross_user_id,
            max(card_level) as card_level,
            dt
        from
        (
            SELECT
                statics_month,
                cross_user_id,
                card_grade,
                case 
                    when card_grade = 'PINK' then 1
                    when card_grade = 'WHITE'  then 2
                    when card_grade = 'BLACK' then 3
                    when card_grade = 'GOLD' then 4
                    when card_grade = 'Unknown' then 0
                end as card_level,
                dt
            FROM
                DW_Sensor.RPT_Sensor_MNP_APP_User_Monthly
            where dt=@dt
        )a
        group by 
            statics_month,
            cross_user_id,
            dt
    )b
)c
group by 
    statics_month,
    card_grade
;
end

GO
