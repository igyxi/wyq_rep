/****** Object:  StoredProcedure [DW_BEA].[SP_Fact_Beauty_KPI_Detail_Init]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_BEA].[SP_Fact_Beauty_KPI_Detail_Init] @Date_ID_Cut_Off [INT] AS
BEGIN
    
	TRUNCATE TABLE  [DW_BEA].[Fact_Beauty_KPI_Detail];



	----1. Init KPI: New_Fans(每日新增用户数),Total_Fans(累计总用户数)
	----2. Init KPI: Post(每日新增帖子数),Total_Post(累计总帖子数),Featured(每日加精数),Total_Featured(累计加精帖子数)
	----3. Init KPI: Like(每日点赞数),Total_Like(累计点赞数),Collection(每日收藏数),Total_Collection(累计收藏数)
	----4. Init KPI: Follow(每日关注数),Total_Follow(累计关注数)
	----5. Init KPI: Share(每日分享数),Total_Share(累计分享数)
	----6. Init KPI: Comment(每日评论数),Total_Comment(累计评论数)
	----7. Init KPI: Checkin(每日签到数) ； Engaged_User_Checkin(每日签到用户数) ----
	----8. Init KPI: Engaged(每日总互动数) ； Engaged_User(美印互动用户) ----

	----1. Init KPI: New_Fans(新增用户数),Total_Fans(累计总用户数) Start----

	;
	  WITH New_Fans AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 --'New_Fans' AS [KPI_Name],
			 COUNT([fans_user_id]) AS New_Fans
	  FROM [ODS_BEA].[Beauty_Fans] obf WITH(NOLOCK) 
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obf.[create_time],23)), 112)=ddbc.[date_ID]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obf.[user_id]=dbb.[Brand_Code]
									   
	  WHERE ddbc.[date_ID]<=@Date_ID_Cut_Off --AND obf.[user_id]='2003778896'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 )

	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			1 AS [KPI_ID],--'New_Fans'
			New_Fans AS [KPI_Value]
	 FROM New_Fans 
	 


	----1. Init KPI: New_Fans(每日新增用户数),Total_Fans(累计总用户数) End----


	----2. Init KPI: Post(每日新增帖子数),Total_Post(累计总帖子数),Featured(每日加精数),Total_Featured(累计加精帖子数) Start----

		--Post 新增帖子数
	  ;
	  WITH New_Post AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 --'New_Post' AS [KPI_Name],
			 COUNT([post_id]) AS New_Post,
			 COUNT(DISTINCT(obs.[user_id])) AS New_Post_User --Engaged_User_Post 每日发帖用户数
	  FROM [ODS_BEA].[Beauty_Send_Timeline] obs WITH(NOLOCK) 									   
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obs.[create_time],23)), 112)=ddbc.[date_ID]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obs.[user_id]=dbb.[Brand_Code]
	  WHERE ddbc.[date_ID]>20190305 AND ddbc.[date_ID]<=@Date_ID_Cut_Off --AND Brand_User.[user_id]='2003778896'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 --ORDER BY ddbc.[date_ID],obf.[user_id]
	 )

	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			3 AS [KPI_ID],--'New_Post'
			New_Post AS [KPI_Value]
	 FROM New_Post 
	 UNION
	 SELECT [date_ID],
			[Brand_ID],
			29 AS [KPI_ID],--'New_Post'
			New_Post_User AS [KPI_Value]
	 FROM New_Post 
	

	 --Featured 加精数
	  ;
	 -- WITH New_Featured AS(
	 -- SELECT ddbc.[date_ID],
		--	 dbb.[Brand_ID],
		--	 --'Featured' AS [KPI_Name],
		--	 COUNT([post_id]) AS Featured
	 -- FROM [ODS_BEA].[Beauty_Send_Timeline] obs WITH(NOLOCK) 
		--							   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obs.[create_time],23)), 112)=ddbc.[date_ID]
		--							   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obs.[user_id]=dbb.[Brand_Code]
	 -- WHERE obs.[elite]='true' and ddbc.[date_ID]<=@Date_ID_Cut_Off --AND Brand_User.[user_id]='2013983332'
	 -- GROUP BY ddbc.[date_ID],
		--	 dbb.[Brand_ID]
	 ----ORDER BY ddbc.[date_ID],obf.[user_id]
	 --)

	 WITH New_Featured AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 --'Featured' AS [KPI_Name],
			 COUNT([PostsId]) AS Featured
	  FROM [ODS_User].[Beauty_Event_History] obs WITH(NOLOCK) --2023-04-03切换为ODS_USER
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obs.[EventTime],23)), 112)=ddbc.[date_ID]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obs.[UserId]=dbb.[Brand_Code]
	  WHERE obs.[EventType]=N'ELITE' AND obs.[Status]=N'pass' and ddbc.[date_ID]<=@Date_ID_Cut_Off --AND Brand_User.[user_id]='2013983332'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 --ORDER BY ddbc.[date_ID],obf.[user_id]
	 )

	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			7 AS [KPI_ID],--'Featured'
			Featured AS [KPI_Value]
	 FROM New_Featured 
	 

	----2. Init KPI: Post(每日新增帖子数),Total_Post(累计总帖子数),Featured(每日加精数),Total_Featured(累计加精帖子数) End----

	----3. Init KPI: Like(每日点赞数),Total_Like(累计点赞数),Collection(每日收藏数),Total_Collection(累计收藏数) Start----


	--Like 每日点赞数,每日点赞用户数
	  ;
	  WITH Like_Count AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 --'Like' AS [KPI_Name],
			 COUNT([post_author_id]) AS Like_Count, --Like 每日点赞数
			 COUNT(DISTINCT(obbp.[user_id])) AS Like_Count_User --Engaged_User_Like 每日点赞用户数
	  FROM [ODS_BEA].[Beauty_Behavior_Post] obbp WITH(NOLOCK) 									   
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obbp.[behavior_time],23)), 112)=ddbc.[date_ID]
									   INNER JOIN [ODS_BEA].[Beauty_Send_Timeline] obs WITH(NOLOCK) ON obbp.[post_id]=obs.[post_id]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obs.[user_id]=dbb.[Brand_Code]
	  WHERE  obbp.[behavior] ='like' AND ddbc.[date_ID]<=@Date_ID_Cut_Off --AND Brand_User.[user_id]='2003778896'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 --ORDER BY ddbc.[date_ID],obf.[user_id]
	 )
	 
	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			12 AS [KPI_ID],--'Like'
			Like_Count AS [KPI_Value]
	 FROM Like_Count 
	 UNION
	 SELECT [date_ID],
			[Brand_ID],
			26 AS [KPI_ID],--'Engaged_User_Like'
			Like_Count_User AS [KPI_Value]
	 FROM Like_Count 

	  


	 --Collection 每日收藏数
	  ;
	  WITH Collection_Count AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 COUNT(obbp.[post_author_id]) AS Collect_Count,--Collection 每日收藏数
			 COUNT(DISTINCT(obbp.[user_id])) AS Collect_Count_User --Engaged_User_Collection 每日收藏用户数
	  FROM [ODS_BEA].[Beauty_Behavior_Post] obbp WITH(NOLOCK) 
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obbp.[behavior_time],23)), 112)=ddbc.[date_ID]
									   INNER JOIN [ODS_BEA].[Beauty_Send_Timeline] obs WITH(NOLOCK) ON obbp.[post_id]=obs.[post_id]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obs.[user_id]=dbb.[Brand_Code]
	  WHERE  obbp.[behavior] ='collect' AND ddbc.[date_ID]<= @Date_ID_Cut_Off --AND Brand_User.[user_id]='2003778896'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 --ORDER BY ddbc.[date_ID],obf.[user_id]
	 )

	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			10 AS [KPI_ID],--'Collection'
			Collect_Count AS [KPI_Value]
	 FROM Collection_Count 
	 UNION
	 SELECT [date_ID],
			[Brand_ID],
			24 AS [KPI_ID],--'Engaged_User_Collection'
			Collect_Count_User AS [KPI_Value]
	 FROM Collection_Count
	

	----3. Init KPI: Like(每日点赞数),Total_Like(累计点赞数),Collection(每日收藏数),Total_Collection(累计收藏数) End----


	----4. Init KPI: Follow(每日关注数),UnFollow(每日取关数) Start----

	;
	  WITH Follow AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 --'Follow' AS [KPI_Name],
			 COUNT([user_id]) AS Follow, --Follow 每日关注数
			 COUNT(DISTINCT([user_id])) AS Follow_User --Engaged_User_Follow 每日关注用户数
	  FROM [ODS_BEA].[Beauty_Follow] obf WITH(NOLOCK) 									   
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obf.[create_time],23)), 112)=ddbc.[date_ID]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obf.[follow_user_id]=dbb.[Brand_Code]
	  WHERE  ddbc.[date_ID] <= @Date_ID_Cut_Off --AND obf.[follow_user_id]='2010314534'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 --ORDER BY ddbc.[date_ID],obf.[user_id]
	 )

	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			13 AS [KPI_ID],--'Follow'
			Follow AS [KPI_Value]
	 FROM Follow 
	 UNION
	 SELECT [date_ID],
			[Brand_ID],
			27 AS [KPI_ID],--'Engaged_User_Follow'
			Follow_User AS [KPI_Value]
	 FROM Follow
	 
	 ;
	 WITH UnFollow AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 --'Follow' AS [KPI_Name],
			 COUNT([user_id]) AS UnFollow, --UnFollow 每日取关数
			 COUNT(DISTINCT([user_id])) AS UnFollow_User --Engaged_User_UnFollow 每日取关用户数
	  FROM [ODS_BEA].[Beauty_Follow] obf WITH(NOLOCK) 									   
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obf.[create_time],23)), 112)=ddbc.[date_ID]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obf.[follow_user_id]=dbb.[Brand_Code]
	  WHERE obf.[status]=N'UNFOLLOW' AND ddbc.[date_ID] <= @Date_ID_Cut_Off --AND obf.[follow_user_id]='2010314534'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 )

	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			31 AS [KPI_ID],--'UnFollow'
			UnFollow AS [KPI_Value]
	 FROM UnFollow 
	 UNION
	 SELECT [date_ID],
			[Brand_ID],
			32 AS [KPI_ID],--'Engaged_User_UnFollow'
			UnFollow_User AS [KPI_Value]
	 FROM UnFollow

	----4. Init KPI: Follow(每日关注数),Total_Follow(累计关注数) End----



	----5. Init KPI: Share(每日分享数),Total_Share(累计分享数) Start----

	--Share 每日分享数

	  ;
	  WITH Share AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 --'New_Post' AS [KPI_Name],
			 COUNT([share_id]) AS Share, --Share 每日分享数
			 COUNT(DISTINCT(obsp.[user_id])) AS Share_User -- Engaged_User_Share 每日分享用户数
	  FROM [ODS_BEA].[Beauty_Share_Process] obsp WITH(NOLOCK) 
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obsp.[create_time],23)), 112)=ddbc.[date_ID]
									   INNER JOIN [ODS_BEA].[Beauty_Send_Timeline] obs WITH(NOLOCK) ON obsp.[post_id]=obs.[post_id]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obs.[user_id]=dbb.[Brand_Code]
	  WHERE  ddbc.[date_ID] <= @Date_ID_Cut_Off --AND Brand_User.[user_id]='2013319111'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 --ORDER BY ddbc.[date_ID],obf.[user_id]
	 )

	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			14 AS [KPI_ID],--'Share'
			Share AS [KPI_Value]
	 FROM Share 
	 UNION
	 SELECT [date_ID],
			[Brand_ID],
			28 AS [KPI_ID],--'Engaged_User_Follow'
			Share_User AS [KPI_Value]
	 FROM Share
	 

	----5. Init KPI: Share(每日分享数),Total_Share(累计分享数) End----



	----6. Init KPI: Comment(每日评论数),Total_Comment(累计评论数) Start----


	--Comment 每日评论数
		  ;
		  WITH Comment AS(
		  SELECT ddbc.[date_ID],
				 dbb.[Brand_ID],
				 --'Comment' AS [KPI_Name],
				 COUNT([comment_id]) AS Comment,
				 COUNT(DISTINCT([author_id])) AS Comment_User
		  FROM [ODS_BEA].[Beauty_Comment] obc WITH(NOLOCK) 
										   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obc.[create_time],23)), 112)=ddbc.[date_ID]
										   INNER JOIN [ODS_BEA].[Beauty_Send_Timeline] obs WITH(NOLOCK) ON obc.[post_id]= obs.[post_id]
										   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obs.[user_id]=dbb.[Brand_Code]
		  WHERE  ddbc.[date_ID]<= @Date_ID_Cut_Off --AND Brand_User.[user_id]='2003778896'
		  GROUP BY ddbc.[date_ID],
				 dbb.[Brand_ID]
		 --ORDER BY ddbc.[date_ID],obf.[user_id]
		 ),
		 Comment_Reply AS(
		  SELECT ddbc.[date_ID],
				 dbb.[Brand_ID],
				 --'Comment' AS [KPI_Name],
				 COUNT(obcr.[reply_id]) AS Comment_Reply,
				 COUNT(DISTINCT(obcr.[author_id])) AS Comment_Reply_User
		  FROM [ODS_BEA].[Beauty_Comment_reply] obcr WITH(NOLOCK) 
										   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obcr.[create_time],23)), 112)=ddbc.[date_ID]
										   INNER JOIN [ODS_BEA].[Beauty_Send_Timeline] obs WITH(NOLOCK) ON obcr.[post_id]= obs.[post_id]
										   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obs.[user_id]=dbb.[Brand_Code]
		  WHERE  ddbc.[date_ID]<= @Date_ID_Cut_Off --AND Brand_User.[user_id]='2003778896'
		  GROUP BY ddbc.[date_ID],
				 dbb.[Brand_ID]
		 --ORDER BY ddbc.[date_ID],obf.[user_id]
		 )

		 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
		 SELECT a.[date_ID],
				a.[Brand_ID],
				11 AS [KPI_ID],--'Comment'
				(ISNULL(a.Comment,0)+ ISNULL(b.Comment_Reply,0)) AS [KPI_Value]
		 FROM Comment a LEFT JOIN Comment_Reply b ON a.[date_ID]=b.[date_ID] AND a.[Brand_ID]=b.[Brand_ID]
		 UNION
		 SELECT a.[date_ID],
				a.[Brand_ID],
				25 AS [KPI_ID],--'Comment'
				(ISNULL(a.Comment_User,0)+ ISNULL(b.Comment_Reply_User,0)) AS [KPI_Value]
		 FROM Comment a LEFT JOIN Comment_Reply b ON a.[date_ID]=b.[date_ID] AND a.[Brand_ID]=b.[Brand_ID]
		
	----6. Init KPI: Comment(每日评论数),Total_Comment(累计评论数) End----

	----7. Init KPI: Checkin(每日签到数) ； Engaged_User_Checkin(每日签到用户数) Start----

	;
	  WITH Checkin AS(
	  SELECT ddbc.[date_ID],
			 dbb.[Brand_ID],
			 --'Checkin' AS [KPI_Name],
			 COUNT(obc.[UserId]) AS Checkin,
			 COUNT(DISTINCT(obc.[UserId])) AS Checkin_User
	  FROM [ODS_User].[Beauty_User_Checkin] obc WITH(NOLOCK) --2023-04-03切换为ODS_USER
									   INNER JOIN [DW_BEA].[Dim_Beauty_Calendar] ddbc WITH(NOLOCK) ON CONVERT(NVARCHAR, CONVERT(DATETIME,LEFT(obc.[CheckInDate],23)), 112)=ddbc.[date_ID]
									   LEFT JOIN [DW_BEA].[Dim_Beauty_Brand] dbb WITH(NOLOCK) ON obc.[UserId]=dbb.[Brand_Code]
									   
	  WHERE ddbc.[date_ID]<=@Date_ID_Cut_Off --AND obf.[user_id]='2003778896'
	  GROUP BY ddbc.[date_ID],
			 dbb.[Brand_ID]
	 )

	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [date_ID],
			[Brand_ID],
			9 AS [KPI_ID],--'Share'
			Checkin AS [KPI_Value]
	 FROM Checkin 
	 UNION
	 SELECT [date_ID],
			[Brand_ID],
			30 AS [KPI_ID],--'Engaged_User_Checkin'
			Checkin_User AS [KPI_Value]
	 FROM Checkin

	----7. Init KPI: Checkin(每日签到数) ； Engaged_User_Checkin(每日签到用户数) End----

	----8. Init KPI: Engaged(每日总互动数) ； Engaged_User(美印互动用户) Start----

	 --Engaged(每日总互动数)
	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [Date_ID],
			[Brand_ID],
			15 AS [KPI_ID],
			SUM(ISNULL([KPI_Value],0)) AS [KPI_Value]
	 FROM [DW_BEA].[Fact_Beauty_KPI_Detail]
	 --WHERE [KPI_ID] IN (9,10,11,12,13,14)
	 WHERE [KPI_ID] IN (9,10,11,12,14)
	 GROUP BY [Date_ID],[Brand_ID]
	 

	 --Engaged_User(美印互动用户)
	 INSERT INTO [DW_BEA].[Fact_Beauty_KPI_Detail]
	 SELECT [Date_ID],
			[Brand_ID],
			16 AS [KPI_ID],
			SUM(ISNULL([KPI_Value],0)) AS [KPI_Value]
	 FROM [DW_BEA].[Fact_Beauty_KPI_Detail]
	 --WHERE [KPI_ID] IN (24,25,26,27,28,29,30)
	 WHERE [KPI_ID] IN (24,25,26,28,29,30)
	 GROUP BY [Date_ID],[Brand_ID]
	 

	----8. Init KPI: Engaged(每日总互动数) ； Engaged_User(美印互动用户) End----


END
GO
