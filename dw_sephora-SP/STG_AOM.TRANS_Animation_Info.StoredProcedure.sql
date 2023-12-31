/****** Object:  StoredProcedure [STG_AOM].[TRANS_Animation_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_AOM].[TRANS_Animation_Info] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-14       tali           Initial Version
-- ========================================================================================
truncate table STG_AOM.Animation_Info;
insert into STG_AOM.Animation_Info
select 
    case when trim(animation_name) in ('null','') then null else trim(animation_name) end as animation_name,
    from_date,
    till_date,
    case when trim(category) in ('null','') then null else trim(category) end as category,
    case when trim(brand) in ('null','') then null else trim(brand) end as brand,
    case when trim(material) in ('null','') then null else trim(material) end as material,
    current_timestamp as insert_timestamp
from 
    ODS_AOM.Animation_Info
where 
    dt= @dt
END


GO
