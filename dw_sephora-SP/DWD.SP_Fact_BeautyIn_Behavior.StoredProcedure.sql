/****** Object:  StoredProcedure [DWD].[SP_Fact_BeautyIn_Behavior]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_BeautyIn_Behavior] @dt [varchar](512) AS
BEGIN
-- [DWD].[SP_Fact_BeautyIn_Behavior] '2023-02-06'

-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-17       ChenxuXu       Initial Version
-- 2023-03-29       ChenxuXu       Update member table
-- ========================================================================================
    TRUNCATE TABLE DWD.Fact_BeautyIn_Behavior;

    INSERT INTO DWD.Fact_BeautyIn_Behavior

SELECT
    a.post_id,
    a.behavior,
    a.behavior_cn,
    b.member_card as [user_id],
    a.behavior_time,
    a.dt,
    a.insert_timestamp
from
    (
    --点赞、收藏
                    SELECT
            post_id,
            behavior,
            CASE behavior
            WHEN 'like' THEN N'点赞'
            WHEN 'collect' THEN N'收藏'
        END AS behavior_cn,
            user_id,
            LEFT(behavior_time,23) as [behavior_time],
            @dt as [dt],
            CURRENT_TIMESTAMP as insert_timestamp
        FROM ODS_BEA.Beauty_Behavior_Post
        WHERE behavior IN ('like','collect')
    UNION ALL
        --分享
        SELECT
            post_id,
            'share' AS behavior,
            N'分享' AS behavior_cn,
            user_id,
            LEFT(create_time,23),
            @dt,
            CURRENT_TIMESTAMP
        FROM [ODS_BEA].[Beauty_Share_Process]
        WHERE post_id IS NOT NULL
    UNION ALL
        --评论
        SELECT
            post_id,
            'comment' AS behavior,
            N'评论' AS behavior_cn,
            author_id,
            LEFT(create_time,23),
            @dt,
            CURRENT_TIMESTAMP
        FROM [ODS_BEA].[Beauty_Comment]
    UNION ALL
        SELECT
            com.post_id,
            'comment' AS behavior,
            N'评论' AS behavior_cn,
            comr.author_id,
            LEFT(comr.create_time,23),
            @dt,
            CURRENT_TIMESTAMP
        FROM [ODS_BEA].[Beauty_Comment] AS com
            JOIN [ODS_BEA].[Beauty_Comment_reply] AS comr ON com.comment_id=comr.comment_id
    ) a
    INNER JOIN dwd.dim_member_info b
    ON a.user_id = b.eb_user_id

END
GO
