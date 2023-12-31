/****** Object:  StoredProcedure [TEMP].[TRANS_Page_Type_mapping_Bak20220704]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_Page_Type_mapping_Bak20220704] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-30       aan            Initial Version
-- ========================================================================================
truncate table [STG_Sensor].Sensor_Page_Type_Mapping;
insert into [STG_Sensor].Sensor_Page_Type_Mapping
select [page_id]
      ,[description]
      ,[page_type]
	  ,'Manual Upload' as source
      ,[insert_timestamp]
  FROM [STG_Sensor].[Sensor_PageType_Categorization]
union all
select  distinct sephora_page_id
  ,pageTitle
  ,'Campaign'
  ,'AEM'
  ,insert_timestamp from  [DW_AEM].[RPT_AEM_Page_SKU_Detail] ;
END

GO
