/****** Object:  StoredProcedure [TEMP].[SP_Fact_Member_MNP_Register_Bak20221212]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Member_MNP_Register_Bak20221212] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-08       Tali           Initial Version
-- 2022-03-25       Tali           change source from olap to oltp
-- 2022-08-30       Tali           set null for moblie
-- ========================================================================================

truncate table [DWD].[Fact_Member_MNP_Register];
insert into [DWD].[Fact_Member_MNP_Register]
select 
    a.account_miniprogram_id,
    b.store_code,
    a.register_time as miniprogram_register_time,
    a.bind_mobile_time as miniprogram_bind_mobile_time,
    null as bind_mobile,
    -- a.mobile as bind_mobile,
    -- a.account_id,
    a.bind_card_num as account_number,
    -- c.store_code,
    a.channel as bind_channel,
    a.sub_channel as bind_sub_channel,
    a.card_type,
    case 
        when a.card_type = 0 then 'PINK'
        when a.card_type = 1 then 'WHITE'
        when a.card_type = 2 then 'BLACK'
        when a.card_type = 3 then 'GOLD'
        else null
    end as card_type_name,
    a.unionid,
    a.openid,
    a.create_date,
    a.update_date,
    a.[status],
    'CRM' as source,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    ODS_CRM.account_miniprogram a
left join 
    DW_CRM.Dim_Store b
on a.place_id = b.store_id
END

GO
