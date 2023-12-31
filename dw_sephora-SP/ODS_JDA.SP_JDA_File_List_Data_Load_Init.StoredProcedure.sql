/****** Object:  StoredProcedure [ODS_JDA].[SP_JDA_File_List_Data_Load_Init]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_JDA].[SP_JDA_File_List_Data_Load_Init] AS
BEGIN
    
	UPDATE a
	SET a.[Business_Sub_Category]=b.[Business_Sub_Category],
		a.[File_Create_Date]= SUBSTRING(a.[File_Name],CHARINDEX(N'OUTPUT',a.[File_Name])+7,8)
	FROM [ODS_JDA].[JDA_Files_Info] a WITH(NOLOCK) INNER JOIN [ODS_JDA].[Confg_JDA_Files_Type] b WITH(NOLOCK)
					ON a.[File_Name] like CONCAT('%' ,b.[FileName_Key_Words],'%')



	TRUNCATE TABLE [ODS_JDA].[JDA_File_List_Data_Load]

	INSERT INTO [ODS_JDA].[JDA_File_List_Data_Load]([File_Name],[File_Folder],[Business_Sub_Category])
	SELECT a.[File_Name],
		   a.[File_Folder],
		   a.[Business_Sub_Category]
	FROM 
	(
	SELECT  [File_Name]
		  ,[File_Folder]
		  ,[File_Create_Date]
		  ,[Business_Sub_Category]
		  ,ROW_NUMBER() OVER(PARTITION BY [Business_Sub_Category],[File_Folder] ORDER BY [File_Create_Date] DESC) AS NM
	  FROM [ODS_JDA].[JDA_Files_Info] WITH(NOLOCK)
	  ) a
	  WHERE a.NM=1
	

END
GO
