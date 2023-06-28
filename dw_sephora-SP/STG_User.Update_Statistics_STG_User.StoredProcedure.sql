/****** Object:  StoredProcedure [STG_User].[Update_Statistics_STG_User]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_User].[Update_Statistics_STG_User] AS
begin
update statistics STG_User.Card;
update statistics STG_User.[User];
update statistics STG_User.User_Device_Status;
update statistics STG_User.User_Profile;
update statistics STG_User.User_Third_Party_Store;
update statistics STG_User.CRM_Store_Channel_Info;
update statistics STG_User.User_KMS_Encrypt;
end
GO
