/****** Object:  StoredProcedure [ODS_JDA].[SP_JDA_File_Info_Init]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_JDA].[SP_JDA_File_Info_Init] @File_Name [nvarchar](200),@File_Folder [nvarchar](100) AS
BEGIN
    
	INSERT INTO [ODS_JDA].[JDA_Files_Info]([File_Name],[File_Folder])
	SELECT @File_Name,@File_Folder
	

END
GO
