/****** Object:  StoredProcedure [STG_TMALLHub].[Update_Statistics_STG_TMALLHub]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TMALLHub].[Update_Statistics_STG_TMALLHub] AS
begin
update statistics STG_TMALLHub.TMALL_Bind_Mobile_Info;
update statistics STG_TMALLHub.TMALL_Order;
update statistics STG_TMALLHub.TMALL_Order_History;
update statistics STG_TMALLHub.TMALL_Order_Item;
end
GO
