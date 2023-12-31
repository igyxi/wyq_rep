/****** Object:  StoredProcedure [TEMP].[SP_BeautyIn_Temp_Process]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_BeautyIn_Temp_Process] AS

BEGIN

    select b.post_id, cast(a.topics as nvarchar(512)) as  [topics], b.orderby
    INTO #temp_result
    FROM [TEMP].[BeautyIn_Temp_Upload] b
        left JOIN ODS_BEA.Beauty_Send_Timeline a
        on a.post_id = b.post_id
        WHERE b.post_id IS NOT NULL

    DECLARE @result NVARCHAR(max)
    DECLARE @i INT
    DECLARE @row INT

    SET @i = 1
    SET @row = (select count(1)
    from #temp_result)

    -- SELECT @i
    -- SELECT @row

    SET @result = '['
    WHILE (@i <= @row)
BEGIN
        set @result = (SELECT @result + '{"post_id": "' + post_id + '", "topics":[' + replace(replace(isnull(topics,''),'{''','"'),'''}','"') + ']},'
        FROM #temp_result
        WHERE orderby = @i)
        set @i = (SELECT @i + 1)
    END

    set @result = (SELECT SUBSTRING(@result, 1, LEN(@result)-1) + ']')

    TRUNCATE TABLE [TEMP].[BeautyIn_Temp_Upload_Recommend_Group]

    INSERT INTO [TEMP].[BeautyIn_Temp_Upload_Recommend_Group]
    select '0' as [group_id],
        @result as [postid_list]


-- SELECT * FROM [TEMP].[BeautyIn_Temp_Upload_Recommend_Group]
END
GO
