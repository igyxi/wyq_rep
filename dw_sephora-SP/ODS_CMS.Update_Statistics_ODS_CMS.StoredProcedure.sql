/****** Object:  StoredProcedure [ODS_CMS].[Update_Statistics_ODS_CMS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_CMS].[Update_Statistics_ODS_CMS] AS
begin
update statistics ODS_CMS.DP_IQ_FD_Record;
update statistics ODS_CMS.DP_IQ_Record;
end
GO
