/****** Object:  StoredProcedure [STG_CRMHub].[TRANS_Omni_Card_Base_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_CRMHub].[TRANS_Omni_Card_Base_Info] AS
BEGIN
truncate table STG_CRMHub.Omni_Card_Base_Info ;
insert into STG_CRMHub.Omni_Card_Base_Info
select 
    id, 
    case when trim(card_no) in ('null','') then null else trim(card_no) end as card_no,
    case when trim(card_level) in ('null','') then null else trim(card_level) end as card_level,
    card_status,
    available_points,
    total_points,   
    case when trim(register_source) in ('null','') then null else trim(register_source) end as register_source,
    case when trim(register_store) in ('null','') then null else trim(register_store) end as register_store,
    register_time,
    last_update_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_CRMHub.Omni_Card_Base_Info 
) t
where rownum = 1
END


GO
