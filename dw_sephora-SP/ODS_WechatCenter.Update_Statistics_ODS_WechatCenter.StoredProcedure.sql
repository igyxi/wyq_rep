/****** Object:  StoredProcedure [ODS_WechatCenter].[Update_Statistics_ODS_WechatCenter]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_WechatCenter].[Update_Statistics_ODS_WechatCenter] AS
begin
update statistics ODS_WechatCenter.Wechat_BA_Bind;
update statistics ODS_WechatCenter.Wechat_Bind_Mobile_History;
update statistics ODS_WechatCenter.Wechat_Bind_Mobile_List;
update statistics ODS_WechatCenter.Wechat_Register_Info;
update statistics ODS_WechatCenter.Wechat_KMS_Encrypt;
end
GO
