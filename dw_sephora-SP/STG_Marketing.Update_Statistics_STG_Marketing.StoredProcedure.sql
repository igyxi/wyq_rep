/****** Object:  StoredProcedure [STG_Marketing].[Update_Statistics_STG_Marketing]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Marketing].[Update_Statistics_STG_Marketing] AS
begin
update statistics STG_Marketing.Activity_Store_Book_Time;
update statistics STG_Marketing.Activity_Store_Book_User;
update statistics STG_Marketing.Store;
update statistics STG_Marketing.Store_Activity;
update statistics STG_Marketing.Store_Activity_REL;
update statistics STG_Marketing.Store_Reservation;
update statistics STG_Marketing.Store_Service;
update statistics STG_Marketing.Store_Service_REL;
end
GO
