/****** Object:  StoredProcedure [STG_CRMHub].[Update_Statistics_STG_CRMHub]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_CRMHub].[Update_Statistics_STG_CRMHub] AS 
BEGIN
update statistics STG_CRMHub.Omni_Card_Base_Info;
update statistics STG_CRMHub.Omni_Card_Third_Mapping;
END

GO
