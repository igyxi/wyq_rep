/****** Object:  StoredProcedure [DWD].[SP_Fact_Wechat_ServiceAccount_Bind]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Wechat_ServiceAccount_Bind] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-25       Tali           Initial Version
-- 2023-06-16       Leozhai        change user source to ODS
-- ========================================================================================
truncate table DWD.Fact_Wechat_ServiceAccount_Bind;
insert into DWD.Fact_Wechat_ServiceAccount_Bind
select 
    id,
    openid,
    subscribe as is_subscribe,
    subscribe_time,
    subscribe_scene,
    qr_scene,
    qr_scene_str,
    unionid,
    nickname,
    sex,
    language,
    city,
    province,
    country,
    remark,
    groupid,
    tagid_list,
    create_time,
    update_time,
    'OMS' as source,
    current_timestamp as insert_timestamp
from 
    [ODS_MS_Wechat].[Fans_10010001]
;
END
GO
