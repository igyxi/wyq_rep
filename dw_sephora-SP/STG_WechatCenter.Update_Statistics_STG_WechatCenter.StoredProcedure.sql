/****** Object:  StoredProcedure [STG_WechatCenter].[Update_Statistics_STG_WechatCenter]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_WechatCenter].[Update_Statistics_STG_WechatCenter] AS
begin
update statistics STG_WechatCenter.Wechat_BA_Bind;
update statistics STG_WechatCenter.Wechat_Bind_Mobile_History;
update statistics STG_WechatCenter.Wechat_Bind_Mobile_List;
update statistics STG_WechatCenter.Wechat_Register_Info;
update statistics STG_WechatCenter.Wechat_KMS_Encrypt;
end
GO
