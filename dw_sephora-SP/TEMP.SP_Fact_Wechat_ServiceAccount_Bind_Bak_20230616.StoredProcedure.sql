/****** Object:  StoredProcedure [TEMP].[SP_Fact_Wechat_ServiceAccount_Bind_Bak_20230616]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Wechat_ServiceAccount_Bind_Bak_20230616] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-25       Tali           Initial Version
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
    [STG_MS_Wechat].[Fans_10010001]
;
END
GO
