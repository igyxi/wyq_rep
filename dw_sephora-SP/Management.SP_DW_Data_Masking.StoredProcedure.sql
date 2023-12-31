/****** Object:  StoredProcedure [Management].[SP_DW_Data_Masking]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Management].[SP_DW_Data_Masking] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-01       LeoZhai        Initial Version
-- 2023-06-19       Leozhai        Add masking for WechatCenter
-- ========================================================================================

update ODS_User.[User]
set email = null, mobile = null
where dt = @dt;

update ODS_User.[User_Profile]
set mobile = null, email = null, address = null
where dt = @dt;

update ODS_User.[User_Third_Party_Store]
set email = null, mobile = null
where dt = @dt;

update ODS_WechatCenter.[Wechat_BA_Bind]
set mobile = null
where dt = @dt;

update ODS_WechatCenter.[Wechat_Bind_Mobile_History]
set newbindmobile = null, oldbindmobile = null, newphonefull = null
where dt = @dt;

update ODS_WechatCenter.[Wechat_Bind_Mobile_List]
set mobile = null
where dt = @dt;


END


GO
