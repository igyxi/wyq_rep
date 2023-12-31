/****** Object:  StoredProcedure [ODS_FullMakeupService].[SP_Load_STG_Data_To_ODS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_FullMakeupService].[SP_Load_STG_Data_To_ODS] AS
BEGIN
    
	DECLARE @File_Name NVARCHAR(200),@Update_Time NVARCHAR(100)
	SET @Update_Time=(SELECT CONVERT(NVARCHAR(100),DATEADD(HH,8, GETUTCDATE()),120))
--Service_Record--
	SET @File_Name = 
	(
		SELECT DISTINCT [File_Name]
		FROM [STG_FullMakeupService].[Service_Record] WITH(NOLOCK)
	)	

	--Delete exist file's data
	DELETE a
	FROM [ODS_FullMakeupService].[Service_Record] a
	WHERE [File_Name]= @File_Name

	--Update exist data base key [uuid] - set history data to invalid
	UPDATE a
	SET a.[Valid_Flag]=0 , a.[Update_Time]=@Update_Time
	FROM [ODS_FullMakeupService].[Service_Record] a 
			INNER JOIN [STG_FullMakeupService].[Service_Record] b ON a.[uuid]=b.[uuid]
										

	--Insert new file's data
	INSERT INTO [ODS_FullMakeupService].[Service_Record]
	SELECT [uuid]
		  ,[store_code]
		  ,[openid]
		  ,[card_num]
		  ,[card_type]
		  ,[status]
		  ,[created_at]
		  ,[customer_name]
		  ,[mobile]
		  ,[booking_remark]
		  ,[source]
		  ,[book_time]
		  ,[store_name]
		  ,[checkin_time]
		  ,[cancel_time]
		  ,[ba_code]
		  ,[ba_remark]
		  ,[File_Name]
		  ,1 AS [Valid_Flag]
		  ,[Insert_Time]
		  ,NULL AS [Update_Time]
          ,[appointment_type]
	FROM [STG_FullMakeupService].[Service_Record] WITH(NOLOCK)

--Customer_Feedback--
	SET @File_Name = 
	(SELECT DISTINCT [File_Name]
	FROM [STG_FullMakeupService].[Customer_Feedback] WITH(NOLOCK)
	)

	--Delete exist file's data
	DELETE a
	FROM [ODS_FullMakeupService].[Customer_Feedback] a
	WHERE [File_Name]= @File_Name

	--Update exist data base key [uuid] - set history data to invalid
	UPDATE a
	SET a.[Valid_Flag]=0 , a.[Update_Time]=@Update_Time
	FROM [ODS_FullMakeupService].[Customer_Feedback] a 
			INNER JOIN [STG_FullMakeupService].[Customer_Feedback] b ON a.[id]=b.[id]

	--Insert new file's data
	INSERT INTO [ODS_FullMakeupService].[Customer_Feedback]
	SELECT [id]
		  ,[openid]
		  ,[member_card]
		  ,[tel]
		  ,[store_code]
		  ,[store_address]
		  ,[answer_time]
		  ,[channel]
		  ,[q1]
		  ,[q2]
		  ,[q3]
		  ,[q4]
		  ,[q5]
		  ,[q6]
		  ,[q7]
		  ,[q8]
		  ,[File_Name]
		  ,1 AS [Valid_Flag]
		  ,[Insert_Time]
		  ,NULL AS [Update_Time]
	FROM [STG_FullMakeupService].[Customer_Feedback] WITH(NOLOCK)
	

END
GO
