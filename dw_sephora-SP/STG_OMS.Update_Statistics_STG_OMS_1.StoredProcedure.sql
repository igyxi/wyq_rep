/****** Object:  StoredProcedure [STG_OMS].[Update_Statistics_STG_OMS_1]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[Update_Statistics_STG_OMS_1] AS 
BEGIN
update statistics STG_OMS.OMS_KMS_Encrypt;
END
GO
