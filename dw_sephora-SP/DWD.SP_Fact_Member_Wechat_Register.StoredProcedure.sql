/****** Object:  StoredProcedure [DWD].[SP_Fact_Member_Wechat_Register]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Member_Wechat_Register] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-22       Tali           Initial Version
-- ========================================================================================
delete from DWD.Fact_Member_Wechat_Register where format(create_time, 'yyyy-MM-dd') = @dt;
insert into DWD.Fact_Member_Wechat_Register
select 
    id,
    unionid,
    openid,
    registertime,
    registerchannel,
    registerstore,
    registersubchannel,
    create_time,
    is_delete,
    'OMS',
    CURRENT_TIMESTAMP
from
    [STG_WechatCenter].[Wechat_Register_Info]
where
    format(create_time, 'yyyy-MM-dd') = @dt
END
GO
