/****** Object:  StoredProcedure [DWD].[SP_DIM_Calendar]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Calendar] AS
begin 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-30       wangzhichun    Initial Version
-- 2023-03-15       tali           change animation_name to null
-- ========================================================================================
truncate table DWD.DIM_Calendar;
insert into DWD.DIM_Calendar
select distinct
    date_id,
    date_str,
    date_date,
    year_month,
    year,
    quarter,
    month,
    week,
    merchandise_week,
    day,
    day_of_week,
    day_of_year,
    week_day_name,
    case when dragon_campaign_type = 'Private Sales' then 1 else 0 end as dragon_campaign_flag,
    case when tmall_sephora_campaign_type = 'Private Sales' then 1 else 0 end as tmall_sephora_campaign_flag,
    case when tmall_wei_campaign_type = 'Private Sales' then 1 else 0 end as tmall_wei_campaign_flag,
    case when jd_campaign_type = 'Private Sales' then 1 else 0 end as jd_campaign_flag,
    case when tiktok_campaign_type = 'Private Sales' then 1 else 0 end as tiktok_campaign_flag,
    case when livestream_campaign_type = 'Private Sales' then 1 else 0 end as livestream_campaign_flag,
    case when b.Animation_Name is not null then 1 else 0 end as animation_flag,
    null as animation_name,
    '' source,
    CURRENT_TIMESTAMP insert_timestamp
from 
    [DW_Common].[Dim_Calendar] a
left join
(
    SELECT 
        [Animation_Name],
        min([Start_Date]) as [Start_Date],
        max([End_Date]) as [End_Date]
    FROM 
        [DW_Common].[Dim_Animation_Retail]
    group by
        Animation_Name
) b
on a.date_date between b.Start_Date and b.End_Date
;
end

GO
