/****** Object:  StoredProcedure [DWD].[SP_DIM_SmartBA_Info_DF]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_SmartBA_Info_DF] @dt [NVARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-15       tali           Initial Version
-- ========================================================================================
delete from DWD.DIM_SmartBA_Info_DF where dt = @dt;
insert into DWD.DIM_SmartBA_Info_DF
select 
    userid,
    [name],
    en_name,
    gender,
    try_cast(bir as datetime),
    null as id_card_no,
    null as email,
    null as tel,
    fax_code,
    shop_info_code,
    join_date,
    leader,
    status,
    created_at,
    modify_time,
    'SmartBA',
    current_timestamp as insert_timestamp,
    @dt as dt
from
    [ODS_SmartBA].[Staff_Info]
where
    dt = @dt
END

GO
