/****** Object:  StoredProcedure [DWD].[SP_Fact_BeautyIn_Fans]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_BeautyIn_Fans] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-16       weichen        Initial Version
-- ========================================================================================
TRUNCATE TABLE DWD.Fact_BeautyIn_Fans;
INSERT INTO DWD.Fact_BeautyIn_Fans

SELECT
id,
user_id as eb_user_id,
follow_user_id as follow_eb_user_id,
create_time,
update_time,
[status] as current_status,
CURRENT_TIMESTAMP as insert_timestamp
FROM ODS_BEA.Beauty_Follow
;
END
GO
