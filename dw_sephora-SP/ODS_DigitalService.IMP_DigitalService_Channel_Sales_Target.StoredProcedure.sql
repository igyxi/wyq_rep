/****** Object:  StoredProcedure [ODS_DigitalService].[IMP_DigitalService_Channel_Sales_Target]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_DigitalService].[IMP_DigitalService_Channel_Sales_Target] AS
BEGIN
	
	TRUNCATE TABLE [STG_DigitalService].[Channel_Sales_Target];
	INSERT INTO [STG_DigitalService].[Channel_Sales_Target]
	SELECT [id]
      ,[rule_id]
      ,[dt]
      ,[channel_id]
      ,[target]
      ,[is_promotion]
      ,[del_flag]
      ,[create_time]
      ,[update_time]
  FROM [ODS_DigitalService].[Channel_Sales_Target]

END
GO
