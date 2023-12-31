/****** Object:  StoredProcedure [TEST].[SP_SmartBA_list_for_2022Sep_PS]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_SmartBA_list_for_2022Sep_PS] @dt [VARCHAR](10) AS
BEGIN
    -- [TEST].[SP_SmartBA_list_for_2022Sep_PS] '2022-08-22'
    -- DECLARE @dt [VARCHAR](10)
    -- SET @dt = '2022-08-22'
    DELETE FROM TEST.SmartBA_list_for_2022Sep_PS WHERE dt = @dt;

    INSERT INTO TEST.SmartBA_list_for_2022Sep_PS
    SELECT
        a.smartba_member_unionid,
        b.member_card,
        -- c.card_type,
        case when c.card_type = 0 then 'PINK'
when c.card_type = 1 then 'WHITE'
when c.card_type = 2 then 'BLACK'
when c.card_type = 3 then 'GOLD'
ELSE 'Non-Member' END AS [card_type],
        @dt as [dt]

    FROM
        (
        select [unionid] as [smartba_member_unionid],
            min(bind_time) as [first_bind_time],
            max(bind_time) as [last_bind_time]
        FROM (
            select a.*
            FROM [DWD].[Fact_Member_BA_Bind] a
                left join
                (
                select distinct unionid, ba_staff_no
                from [DWD].[Fact_Member_BA_Bind] a
                where [status] <> 0
                    and bind_time < @dt
            ) b
                ON a.unionid = b.unionid
                    and a.ba_staff_no = b.ba_staff_no
            WHERE a.[status] = 0
                and b.unionid is NULL
        ) a
        WHERE bind_time <= @dt
        GROUP BY unionid
) a
        LEFT JOIN
        (
    SELECT distinct [unionid], member_card
        FROM [DWD].[Fact_Member_MNP_Register]
        WHERE [status] = 1
            and unionid IS NOT NULL
) b
        on a.smartba_member_unionid = b.unionid
        left JOIN
        DWD.DIM_Member_Info c
        on b.member_card = c.member_card

END
GO
