/****** Object:  StoredProcedure [STG_Transcosmos].[Update_Statistics_STG_Transcosmos]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Transcosmos].[Update_Statistics_STG_Transcosmos] AS
begin
update statistics STG_Transcosmos.CS_IM_Service;
update statistics STG_Transcosmos.Seat_Info;
update statistics STG_Transcosmos.CS_IM_Service_Detail;
end
GO
