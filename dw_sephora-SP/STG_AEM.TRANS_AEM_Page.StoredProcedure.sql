/****** Object:  StoredProcedure [STG_AEM].[TRANS_AEM_Page]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_AEM].[TRANS_AEM_Page] @dt [VARCHAR](10) AS
BEGIN

delete from STG_AEM.AEM_Page WHERE dt = @dt;
insert into STG_AEM.AEM_Page
--DECLARE @dt VARCHAR(10) = '2022-02-18'
SELECT 
	  [timeStamp]
      ,[content]
	  ,page_path
	  ,[insert_timestamp]
	  ,@dt AS dt
FROM (
SELECT 
	   [timeStamp]
      ,[content]
      ,REPLACE(SUBSTRING([file_name], 15, LEN([file_name]) - 13), '_', '/') AS page_path
	  ,ROW_NUMBER() OVER(PARTITION BY content, REPLACE(SUBSTRING([file_name], 15, LEN([file_name]) - 13), '_', '/') ORDER BY [insert_timestamp] DESC) AS rownum
      ,current_timestamp AS [insert_timestamp]
  FROM [ODS_AEM].[AEM_Page_Detail]
  WHERE status = 200
  ) t
  WHERE rownum = 1;

update statistics  STG_AEM.AEM_Page;

END
GO
