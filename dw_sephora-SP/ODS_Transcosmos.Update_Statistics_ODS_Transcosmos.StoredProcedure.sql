/****** Object:  StoredProcedure [ODS_Transcosmos].[Update_Statistics_ODS_Transcosmos]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Transcosmos].[Update_Statistics_ODS_Transcosmos] AS
begin
update statistics ODS_Transcosmos.CS_IM_Service;
update statistics ODS_Transcosmos.Seat_Info;
update statistics ODS_Transcosmos.CS_IM_Service_Detail;
end




GO
