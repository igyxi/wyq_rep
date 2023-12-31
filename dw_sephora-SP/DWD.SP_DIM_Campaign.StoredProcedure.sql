/****** Object:  StoredProcedure [DWD].[SP_DIM_Campaign]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Campaign] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-15       tali           Initial Version
-- ========================================================================================
truncate table DWD.DIM_Campaign;
insert into DWD.DIM_Campaign
select 
    a.campaign_id,
    a.campaign_code,
    a.name,
    a.campaign_class,
    b.campaign_type_code,
    b.campaign_type_name,
    c.campaign_category_code,
    a.[status],
    a.from_date,
    a.to_date,
    a.active_flag,
    a.create_time,
    a.setting_time,
    'CRM' as sourece,
    CURRENT_TIMESTAMP
from 
    ods_crm.campaign a
left join 
    ods_crm.campaign_type b
on a.campaign_type_id = b.campaign_type_id
left join
    ods_crm.campaign_category c
on b.campaign_category_id = c.campaign_category_id
;
END
GO
