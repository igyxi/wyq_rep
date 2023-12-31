/****** Object:  StoredProcedure [DW_Common].[SP_DIM_Dim_Calendar_Manual]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Common].[SP_DIM_Dim_Calendar_Manual] @dt [VARCHAR](4) AS
 BEGIN
-- 1删除临时表数据
 delete from  TEMP.Dim_Calendar;
-- 2将需要更新的数据写入临时表

insert into  TEMP.Dim_Calendar
 SELECT
*
FROM
	[DW_Common].[Dim_Calendar] 
WHERE
	[year] =  @dt;
-- 3删除要更新的数据
delete from [DW_Common].[Dim_Calendar]  where [year] = @dt;
-- 4插入更新的数据
insert into [DW_Common].[Dim_Calendar]

SELECT
	a.[date_id],
	a.[date_str],
	a.[date_date],
	a.[year_month],
	a.[year],
	a.[quarter],
	a.[month],
	a.[week],
	a.[merchandise_week],
	a.[day],
	a.[day_of_week],
	a.[day_of_year],
	a.[week_day_name],
	a.[dragon_campaign_type],
	b.[dragon_campaign],
	a.[dragon_campaign_overlap],
	a.[tmall_sephora_campaign_type],
	b.[tmall_sephora_campaign],
	a.[tmall_sephora_campaign_overlap],
	a.[tmall_wei_campaign_type],
	b.[tmall_wei_campaign],
	a.[tmall_wei_campaign_overlap],
	a.[jd_campaign_type],
	a.[jd_campaign],
	a.[jd_campaign_overlap],
	a.[tiktok_campaign_type],
	b.[tiktok_campaign],
	a.[tiktok_campaign_overlap],
	a.[livestream_campaign_type],
	b.[livestream_campaign],
	a.[livestream_campaign_overlap] 
FROM
	TEMP.Dim_Calendar a
	LEFT JOIN TEMP.Dim_Calendar_Temp b ON a.date_date= b.date_date


END
GO
