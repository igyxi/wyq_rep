/****** Object:  StoredProcedure [ODS_TMALLHub].[Update_Statistics_ODS_TMALLHub]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TMALLHub].[Update_Statistics_ODS_TMALLHub] AS
begin
update statistics ODS_TMALLHub.TMALL_Bind_Mobile_Info;
update statistics ODS_TMALLHub.TMALL_Order;
update statistics ODS_TMALLHub.TMALL_Order_History;
update statistics ODS_TMALLHub.TMALL_Order_Item;
end
GO
