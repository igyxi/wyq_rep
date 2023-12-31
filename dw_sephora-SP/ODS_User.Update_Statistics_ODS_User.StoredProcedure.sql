/****** Object:  StoredProcedure [ODS_User].[Update_Statistics_ODS_User]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_User].[Update_Statistics_ODS_User] AS
begin
update statistics ODS_User.Card;
update statistics ODS_User.[User];
update statistics ODS_User.User_Device_Status;
update statistics ODS_User.User_Profile;
update statistics ODS_User.User_Third_Party_Store;
update statistics ODS_User.CRM_Store_Channel_Info;
update statistics ODS_User.User_KMS_Encrypt;
end
GO
