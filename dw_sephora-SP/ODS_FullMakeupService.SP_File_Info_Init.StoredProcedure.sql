/****** Object:  StoredProcedure [ODS_FullMakeupService].[SP_File_Info_Init]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_FullMakeupService].[SP_File_Info_Init] @File_Name [nvarchar](200) AS
BEGIN
    
	INSERT INTO [ODS_FullMakeupService].[Files_Info]([File_Name])
	SELECT @File_Name
	

END
GO
