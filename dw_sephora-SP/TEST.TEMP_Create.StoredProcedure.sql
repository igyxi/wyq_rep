/****** Object:  StoredProcedure [TEST].[TEMP_Create]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[TEMP_Create] AS
BEGIN

CREATE TABLE [DA_Tagging].[v_events_session_test]
WITH
(
	DISTRIBUTION = HASH([user_id]),
	CLUSTERED COLUMNSTORE INDEX ORDER([dt])
)
as
select 
		[event]
      ,[user_id]
      ,[hour_name]
      ,[week_name]
      ,[time]
      ,[ss_city]
      ,[ss_province]
      ,[ss_title]
      ,[ss_element_content]
      ,[ss_url]
      ,[ss_app_version]
      ,[banner_type]
      ,[banner_content]
      ,[banner_current_url]
      ,[banner_current_page_type]
      ,[banner_belong_area]
      ,[banner_to_url]
      ,[banner_to_page_type]
      ,[banner_ranking]
      ,[banner_coding]
      ,[behavior_type_coding]
      ,[campaign_code]
      ,[op_code]
      ,[platform_type]
      ,[orderid]
      ,[beauty_article_title]
      ,[page_type_detail]
      ,[page_type]
      ,[key_words]
      ,[key_word_type]
      ,[key_word_type_details]
      ,[product_id]
      ,[brand]
      ,[category]
      ,[subcategory]
      ,[thirdcategory]
      ,[segment]
      ,[productline]
      ,[productfunction]
      ,[sephora_user_id]
      ,[open_id]
      ,convert(datetime, [dt]) as [dt]
      ,[sessionid]
      ,[seqid]
      ,[sessiontime]
      ,[ss_utm_medium]
      ,[ss_utm_source]
      ,[ss_os]
      ,[ss_device_id]
from [DA_Tagging].[v_events_session]


END

GO
