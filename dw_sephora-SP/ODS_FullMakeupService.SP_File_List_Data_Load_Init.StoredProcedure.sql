/****** Object:  StoredProcedure [ODS_FullMakeupService].[SP_File_List_Data_Load_Init]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_FullMakeupService].[SP_File_List_Data_Load_Init] AS
BEGIN
    
	UPDATE a
	SET a.[Business_Category]=b.[Business_Category],
		a.[File_Create_Date]= SUBSTRING(a.[File_Name],CHARINDEX(N'_',a.[File_Name])+1,8)
	FROM [ODS_FullMakeupService].[Files_Info] a WITH(NOLOCK) INNER JOIN [ODS_FullMakeupService].[Confg_Files_Type] b WITH(NOLOCK)
					ON a.[File_Name] like CONCAT('%' ,b.[FileName_Key_Words],'%')



	TRUNCATE TABLE [ODS_FullMakeupService].[File_List_Data_Load]

	INSERT INTO [ODS_FullMakeupService].[File_List_Data_Load]([File_Name],[Business_Category])
	SELECT a.[File_Name],
		   a.[Business_Category]
	FROM 
	(
	SELECT  [File_Name]
		  ,[Business_Category]
		  ,ROW_NUMBER() OVER(PARTITION BY [Business_Category] ORDER BY [File_Create_Date] DESC) AS NM
	  FROM [ODS_FullMakeupService].[Files_Info] WITH(NOLOCK)
	  WHERE SUBSTRING([File_Name],CHARINDEX(N'.',[File_Name])+1,3)=N'csv' 
	  ) a
	  WHERE a.NM=1
	

END
GO
