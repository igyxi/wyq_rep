/****** Object:  StoredProcedure [DWD].[SP_DIM_Member_Upgrade_Counter_Config]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Member_Upgrade_Counter_Config] AS 
BEGIN
truncate table DWD.DIM_Member_Upgrade_Counter_Config;
insert into DWD.DIM_Member_Upgrade_Counter_Config
select 
    card_type,
    upgrade_counter_from,
    upgrade_counter_to,
    CURRENT_TIMESTAMP
from 
    ODS_CRM.upgrade_counter_config
END
GO
