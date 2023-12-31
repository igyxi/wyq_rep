/****** Object:  StoredProcedure [Management].[SP_Get_Table_Last_Update]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Management].[SP_Get_Table_Last_Update] @objectName [NVARCHAR](512) AS
BEGIN
	BEGIN
        select 
            min(last_update_time) as update_date
        from
        (
            SELECT CONCAT([schema],'.',[table]) as table_name, Max(format([last_update_time], 'yyyy-MM-dd')) as last_update_time
            FROM [Management].[Table_Last_Update_Logging]
            where CONCAT([schema],'.',[table]) in (upper(@objectName))
            group by CONCAT([schema],'.',[table])
        ) t
	END
END

GO
