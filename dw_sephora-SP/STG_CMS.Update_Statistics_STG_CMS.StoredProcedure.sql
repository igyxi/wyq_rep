/****** Object:  StoredProcedure [STG_CMS].[Update_Statistics_STG_CMS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_CMS].[Update_Statistics_STG_CMS] AS
begin
update statistics STG_CMS.DP_IQ_FD_Record;
update statistics STG_CMS.DP_IQ_Record;
end
GO
