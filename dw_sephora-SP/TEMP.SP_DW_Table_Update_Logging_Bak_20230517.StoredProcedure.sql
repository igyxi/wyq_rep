/****** Object:  StoredProcedure [TEMP].[SP_DW_Table_Update_Logging_Bak_20230517]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_Table_Update_Logging_Bak_20230517] @objectName [NVARCHAR](512) AS
BEGIN
	IF (CHARINDEX('.', @objectName) > 0)
	BEGIN
        DECLARE @cnt bigint=NULL;
        DECLARE @incremental_timestamp nvarchar(512) = null;

        DECLARE @sqls nvarchar(1000);
        DECLARE @cmd nvarchar(1000);
        -- IF upper(@objectName) in ('ODS_CRM.ACCOUNT_OFFER', 'ODS_CRM.ACCOUNT_LOG', 'ODS_CRM.REDEMPTION_ORDER_DETAIL', 'ODS_CRM.REDEMPTION_ORDER', 'ODS_CRM.OPERATION', 'ODS_CRM.COMMUNICATION_TRACK_LINKED_OBJ')
        IF upper(@objectName) in (select upper(CONCAT(dw_schema, '.[',  source_table, ']')) from Management.DW_Source_Table_List where import_type in (2,3))
        BEGIN
            -- select @sqls = 'select @mt = max([timestamp]) from ' + @objectName
            select @sqls = concat('select @mt = cast(max(', incremental_column, ') as nvarchar) from ', dw_schema, '.[', source_table, ']') from Management.DW_Source_Table_List where import_type in (2,3) and upper(CONCAT(dw_schema, '.',  source_table)) = upper(@objectName)
            exec sp_executesql @sqls,N'@mt nvarchar(512) output',@mt = @incremental_timestamp output
        END
        -- IF upper(trim(PARSENAME(@objectName, 2))) = 'STG_CRM'
        
        select @cmd = 'select @a = count_big(1) from ' + @objectName
        exec sp_executesql @cmd,N'@a bigint output',@a = @cnt output
        
        -- select @exit=1 from [Management].[Table_Last_Update_Logging] where upper(CONCAT([schema],'.',[table])) = upper(@objectName)
        -- IF @exit is not NULL
        -- BEGIN
        --     update [Management].[Table_Last_Update_Logging] set [last_update_time] = DATEADD(HOUR, 8, GETDATE()) where upper(CONCAT([schema],'.',[table])) = upper(@objectName)
        -- END
        -- ELSE
        -- BEGIN
        INSERT INTO [Management].[DW_Table_Update_Logging]
        (
            [schema], [table], [last_update_time], [last_incremental_timestamp], [row_count]
        )
        SELECT
            -- [dbo].[clearstrwithreplace](SUBSTRING(@objectName, 1, CHARINDEX('.', @objectName) - 1)) AS [schema]
            -- ,[dbo].[clearstrwithreplace](SUBSTRING(@objectName, CHARINDEX('.', @objectName) + 1, 512)) AS [table]
            upper(trim(PARSENAME(@objectName, 2))) as [schema]
            ,upper(trim(PARSENAME(@objectName, 1))) as [table]
            ,DATEADD(HOUR, 8, GETDATE()) AS [last_update_time]
            ,@incremental_timestamp as [last_incremental_timestamp]
            ,@cnt as c
        -- END
	END
	ELSE
	BEGIN
		RAISERROR ('Provided ObjectName is not valid.', 16, 0)
	END
END

GO
