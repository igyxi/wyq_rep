/****** Object:  StoredProcedure [TEST].[sp_Fact_Non_Member_BA_Bind]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_Fact_Non_Member_BA_Bind] AS
BEGIN
IF OBJECT_ID('tempdb..#smartba_bind_member') IS NOT NULL 
DROP TABLE #smartba_bind_member
SELECT DISTINCT 
    ba_bind.unionid
   ,mnp_register.member_card
INTO #smartba_bind_member
FROM  [DWD].[Fact_Member_BA_Bind] ba_bind
LEFT JOIN 
    (
        SELECT DISTINCT [unionid], member_card
        FROM [DWD].[Fact_Member_MNP_Register]
        WHERE unionid is not null
    ) mnp_register 
ON ba_bind.unionid = mnp_register.unionid

TRUNCATE TABLE DWD.Fact_Non_Member_BA_Bind
INSERT INTO DWD.Fact_Non_Member_BA_Bind
SELECT 
#smartba_bind_member.unionid
,getdate() as insert_timestamp
FROM #smartba_bind_member 
LEFT JOIN 
    (
        SELECT DISTINCT member_card 
        FROM DWD.DIM_Member_Info
        WHERE 
        (CASE WHEN card_type=0 THEN single_pink_card_validate_type
        ELSE 1 END)=1
    ) valid_member
 ON #smartba_bind_member.member_card=valid_member.member_card
 WHERE valid_member.member_card iS NULL

END
GO
