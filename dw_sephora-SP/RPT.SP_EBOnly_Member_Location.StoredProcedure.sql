/****** Object:  StoredProcedure [RPT].[SP_EBOnly_Member_Location]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_EBOnly_Member_Location] @dt [date] AS
BEGIN

    -- EXECUTE [RPT].[SP_EBOnly_Member_Location] '2022-05-18'
    -- drop table #result

    DECLARE @rolling_start_date DATE
    -- SET @rolling_start_date = (SELECT DATEADD(DAY, - 365, @dt))
    SET @rolling_start_date = (SELECT DATEADD(DAY, - 365, GETDATE()))

    ;WITH
        online_user
        AS
        (
            SELECT DISTINCT
                a.member_card
            FROM [DWD].[Fact_Sales_Order] a
                JOIN [DWD].[DIM_Member_Info] b
                ON a.member_card = b.member_card
                LEFT JOIN STG_OMS.OMS_Store_Mapping s WITH (NOLOCK)
                ON a.store_code = s.store_code
            WHERE 1=1
                and a.place_time >= @rolling_start_date
                and s.store_id is not null
        )
,
        offline_user
        AS
        (
            SELECT DISTINCT
                a.member_card
            FROM [DWD].[Fact_Sales_Order] a
                JOIN [DWD].[DIM_Member_Info] b
                ON a.member_card = b.member_card
                LEFT JOIN STG_OMS.OMS_Store_Mapping s WITH (NOLOCK)
                ON a.store_code = s.store_code
            WHERE 1=1
                and a.place_time >= @rolling_start_date
                and s.store_id is NULL
                AND a.province is not NULL
        )
,
        online_user_only
        AS
        (
            SELECT
                member_card
            FROM online_user
            WHERE member_card NOT IN (SELECT
                member_card
            FROM offline_user)
        )

,
        EB_Orders
        AS
        (
            SELECT
                [sales_order_number]
   , [province]
   , city
   , district
   , member_card
            FROM (SELECT
                    [sales_order_number]
	   , a.member_card
	   , [province]
	   , city
	   , district
	   , ROW_NUMBER() OVER (PARTITION BY a.member_card ORDER BY place_time DESC) AS [seq]
                FROM [DW_OMS].[RPT_Sales_Order_Basic_Level] a
                -- FROM [DWD].[Fact_Sales_Order] a
                    JOIN online_user_only b
                    ON a.member_card = b.member_card
                WHERE place_date >= @rolling_start_date) a
            WHERE a.seq = 1
        )

    SELECT
        a.member_card
	, b.province
	   , b.city
	   , b.district
	, c.recommendation_store_name
    into #result
    FROM online_user_only a
        INNER JOIN EB_Orders b
        ON a.[member_card] = b.member_card
        LEFT JOIN [DW_Common].[Dim_China_Area_Store_Recommendation] c
        ON (b.city + b.district) = c.area
    -- INNER JOIN [DWD].[DIM_Store] d
    -- ON c.recommendation_store_name = d.[store_code]

    TRUNCATE TABLE RPT.EBOnly_User_Location

    INSERT INTO RPT.EBOnly_User_Location
    SELECT member_card, province, city, district
    FROM #result

    TRUNCATE TABLE RPT.EBOnly_User_Store_Recommend

    INSERT INTO RPT.EBOnly_User_Store_Recommend
    SELECT member_card, province, city, district, recommendation_store_name as [recommendation_store]
    FROM #result
    WHERE recommendation_store_name is not NULL

END

GO
