/****** Object:  StoredProcedure [DWD].[SP_Fact_SmartBA_Marking_Relation_Log]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_SmartBA_Marking_Relation_Log] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-10       leozhai        Initial Version
-- ========================================================================================
delete from DWD.Fact_SmartBA_Marking_Relation_Log where format(create_time, 'yyyy-MM-dd') = @dt;
insert into DWD.Fact_SmartBA_Marking_Relation_Log
select
	id,
	batch_no,
	unionid,
	external_userid,
	emp_userid,
	bind_time,
	tag_name,
	create_time,
	update_time,
    'SmartBA' as source,
    current_timestamp as insert_timestamp
from
    ods_smartba.t_marking_relation_log
where
	format(create_time, 'yyyy-MM-dd') = @dt
END
GO
