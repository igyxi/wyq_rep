/****** Object:  StoredProcedure [DWD].[SP_Fact_TA_Scoring]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_TA_Scoring] AS
BEGIN
    -- ========================================================================================
    -- --------------------------------- Change Log -------------------------------------------
    -- Date Generated   Updated By     Description
    -- ----------------------------------------------------------------------------------------
    -- 2022-07-06       joeshen           Initial Version
    -- ========================================================================================
    TRUNCATE TABLE [DWD].[Fact_TA_Scoring]

    INSERT INTO [DWD].[Fact_TA_Scoring]
    SELECT
        a.account_number as [member_card],
        b.score as [gold_downgrade_score],
        b.rank as [gold_downgrade_rank],
        b.percentile as [gold_downgrade_percentile],
        c.score as [black_downgrade_score],
        c.rank as [black_downgrade_rank],
        c.percentile as [black_downgrade_percentile],
        d.score as [white_upgrade_black_score],
        d.rank as [white_upgrade_black_rank],
        d.percentile as [white_upgrade_black_percentile],
        e.score as [white_upgrade_gold_score],
        e.rank as [white_upgrade_gold_rank],
        e.percentile as [white_upgrade_gold_percentile],
        f.score as [black_upgrade_gold_score],
        f.rank as [black_upgrade_gold_rank],
        f.percentile as [black_upgrade_gold_percentile],
        DATEADD(HOUR, -8, GETDATE()) AS [insert_timestamp]
    -- INTO DWD.TA_Scoring
    FROM ODS_CRM.account a
        LEFT JOIN [TA_Scoring].[gold_downgrade_score] b
        ON a.account_number = b.member_card
        LEFT JOIN [TA_Scoring].[black_downgrade_score] c
        ON a.account_number = c.member_card
        LEFT JOIN [TA_Scoring].[white_upgrade_black_score] d
        ON a.account_number = d.member_card
        LEFT JOIN [TA_Scoring].[white_upgrade_gold_score] e
        ON a.account_number = e.member_card
        LEFT JOIN [TA_Scoring].[black_upgrade_gold_score] f
        ON a.account_number = f.member_card
    where b.member_card IS NOT NULL
        OR c.member_card IS NOT NULL
        OR d.member_card IS NOT NULL
        OR e.member_card IS NOT NULL
        OR f.member_card IS NOT NULL


END
GO
