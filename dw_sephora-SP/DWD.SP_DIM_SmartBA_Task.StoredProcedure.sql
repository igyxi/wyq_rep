/****** Object:  StoredProcedure [DWD].[SP_DIM_SmartBA_Task]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_SmartBA_Task] AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-10       leozhai        Initial Version
-- ========================================================================================
truncate table DWD.DIM_SmartBA_Task;
insert into DWD.DIM_SmartBA_Task
select 
    id,
	name,
	type,
	task_desc,
	begin_time,
	end_time,
	is_close,
	close_time,
	is_deleted,
	notice_time,
	posted_template,
	status,
	posted_notice,
	tag_customer_num,
	tag_name,
	tag_id,
    'SmartBA' as source,
    current_timestamp as insert_timestamp
from 
    stg_smartba.t_task
end;
GO
