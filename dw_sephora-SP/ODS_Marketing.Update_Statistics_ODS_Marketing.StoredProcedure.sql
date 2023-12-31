/****** Object:  StoredProcedure [ODS_Marketing].[Update_Statistics_ODS_Marketing]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Marketing].[Update_Statistics_ODS_Marketing] AS
begin
update statistics ODS_Marketing.Activity_Store_Book_Time;
update statistics ODS_Marketing.Activity_Store_Book_User;
update statistics ODS_Marketing.Store;
update statistics ODS_Marketing.Store_Activity;
update statistics ODS_Marketing.Store_Activity_REL;
update statistics ODS_Marketing.Store_Reservation;
update statistics ODS_Marketing.Store_Service;
update statistics ODS_Marketing.Store_Service_REL;
end
GO
