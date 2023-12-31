/****** Object:  StoredProcedure [DATA_OPS].[SP_Parse_Pipeline]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_Parse_Pipeline] @dt [VARCHAR](10),@api_type [VARCHAR](20) AS
BEGIN

--=======
-- exec [DATA_OPS].[SP_Parse_Pipeline] '2022-05-16'
--=======
	--declare @dt [VARCHAR](10) = '2022-03-27'
	IF OBJECT_ID('tempdb..#tbl') IS NOT NULL
    BEGIN
        DROP TABLE #tbl;
    END;
	
    CREATE TABLE #tbl
    WITH (DISTRIBUTION=ROUND_ROBIN, HEAP) 
	AS 
	SELECT ROW_NUMBER() OVER (ORDER BY [file_name] DESC) AS idx
        ,[json_content]
		,[file_name]
    FROM [DATA_OPS].[ADF_Json_Detail]
	where dt=@dt and api_type = @api_type

	delete from [DATA_OPS].[ADF_Pipeline_Run_Log]
	where dt =@dt 

	DECLARE @end INT =(
                SELECT COUNT(*) FROM #tbl
            ),
            @i INT = 1;

    WHILE @i <= @end
    BEGIN
        DECLARE @sql_code NVARCHAR(MAX) =(
                    SELECT concat('{"value": ', [json_content], '}') FROM #tbl WHERE idx = @i
                );
	insert into [DATA_OPS].[ADF_Pipeline_Run_Log]
	select
		file_name,
		row_num,
		max(case when cat_key = 'id' then CAST([value] AS NVARCHAR(1000)) end) AS id,
		max(case when cat_key = 'runId' then CAST([value] AS NVARCHAR(200)) end) AS runId,
		max(case when cat_key = 'pipelineName' then CAST([value] AS NVARCHAR(200)) end) AS pipelineName,
		max(case when cat_key = 'invokedBy_id' then CAST([value] AS NVARCHAR(200)) end) AS invokedBy_id,
		max(case when cat_key = 'invokedBy_name' then CAST([value] AS NVARCHAR(200)) end) AS invokedBy_name,
		max(case when cat_key = 'invokedBy_invokedByType' then CAST([value] AS NVARCHAR(200)) end) AS invokedBy_invokedByType,
		max(case when cat_key = 'invokedBy_pipelineName' then CAST([value] AS NVARCHAR(200)) end) AS invokedBy_pipelineName,
		max(case when cat_key = 'invokedBy_pipelineRunId' then CAST([value] AS NVARCHAR(200)) end) AS invokedBy_pipelineRunId,
		max(case when cat_key = 'runStart' then CAST([value] AS NVARCHAR(200)) end) AS runStart,
		max(case when cat_key = 'runEnd' then CAST([value] AS NVARCHAR(200)) end) AS runEnd,
		max(case when cat_key = 'durationInMs' then CAST([value] AS NVARCHAR(200)) end) AS durationInMs,
		max(case when cat_key = 'status' then CAST([value] AS NVARCHAR(200)) end) AS status,
		max(case when cat_key = 'message' then CAST([value] AS NVARCHAR(max)) end) AS message,
		CURRENT_TIMESTAMP AS [insert_timestamp],
        @dt AS dt
	from (
        SELECT 
			a.[file_name],
			cast(level2.[key] as int) as row_num,
			case when level3.[type] < 3 then cast(level3.[key] as NVARCHAR(200))
			else cast(concat(level3.[key], '_', level4.[key]) AS NVARCHAR(200)) end as cat_key,
			CASE
				WHEN level1.[type] < 3 THEN level1.[value]
				WHEN level2.[type] < 3 THEN level2.[value]
				WHEN level3.[type] < 3 THEN level3.[value]
				WHEN level4.[type] < 3 THEN level4.[value]
			END AS [value]
        FROM #tbl a
		OUTER APPLY openjson(@sql_code) level1
        OUTER APPLY (SELECT * FROM openjson(level1.[value]) WHERE level1.[type] > 3) level2
        OUTER APPLY (SELECT * FROM openjson(level2.[value]) WHERE level2.[type] > 3) level3
		OUTER APPLY (SELECT * FROM openjson(level3.[value]) WHERE level3.[type] > 3) level4
        WHERE idx = @i
		) t
		where t.[value] is not null
		and t.cat_key in ('message', 'pipelineName', 'runEnd', 'runId', 'runStart','status', 'id', 'invokedBy_id', 'invokedBy_name', 'invokedBy_invokedByType', 'invokedBy_pipelineName', 'invokedBy_pipelineRunId', 'durationInMs')
		group by row_num, [file_name]

        SET @i += 1;
    END;

END;
GO
