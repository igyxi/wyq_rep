/****** Object:  StoredProcedure [DWD].[SP_DIM_Offer]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Offer] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-15       tali           Initial Version
-- ========================================================================================
truncate table DWD.DIM_Offer;
insert into DWD.DIM_Offer
select 
    offer_id,
    offer_name,
    display_txt,
    display_flag,
    -- b.offer_type_code,
    b.offer_type_name_en,
    b.offer_type_name,
    a.effective_from_date,
    a.effective_to_date,
    a.sku,
    a.internet_code,
    a.limit_times,
    a.campaign_id,
    a.status,
    a.is_exported,
    a.is_dragon_exported,
    a.is_web_exported,
    a.create_time,
    a.setting_time,
    'CRM' as sourece,
    CURRENT_TIMESTAMP
from 
    ods_crm.offer a
left join 
    ods_crm.offer_type b
on a.offer_type_id = b.offer_type_id
;
END
GO
