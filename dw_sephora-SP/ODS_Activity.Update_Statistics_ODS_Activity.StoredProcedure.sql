/****** Object:  StoredProcedure [ODS_Activity].[Update_Statistics_ODS_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Activity].[Update_Statistics_ODS_Activity] AS
BEGIN
update statistics ODS_Activity.Gift_Event;
update statistics ODS_Activity.Gift_Event_Partner;
update statistics ODS_Activity.Gift_Event_Receiver;
update statistics ODS_Activity.Gift_Event_SKU;
END

GO
