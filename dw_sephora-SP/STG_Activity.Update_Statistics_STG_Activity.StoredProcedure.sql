/****** Object:  StoredProcedure [STG_Activity].[Update_Statistics_STG_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Activity].[Update_Statistics_STG_Activity] AS
BEGIN
update statistics STG_Activity.Gift_Event;
update statistics STG_Activity.Gift_Event_Partner;
update statistics STG_Activity.Gift_Event_Receiver;
update statistics STG_Activity.Gift_Event_SKU;
END

GO
