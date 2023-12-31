/****** Object:  StoredProcedure [DWD].[SP_DIM_SKU_Info_EXT]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_SKU_Info_EXT] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       litao           Initial Version
-- ========================================================================================

truncate table [DWD].[DIM_SKU_Info_EXT];
insert  into [DWD].[DIM_SKU_Info_EXT]
select 	[Mat.] as sap_sku_code
		,[Eyeshadow Format] as sap_eyeshadow_format
		,[Eyeshadow Effect] as sap_eyeshadow_effect
		,[Eyeshadow Color] as sap_eyeshadow_color
		,[Eyeshadow No. of Color Multi-Shade] as sap_eyeshadow_multi_shade
		,current_timestamp as insert_timestamp
from 	[MANUAL_SAP].[Makeup_Classification]
where 	[mat.] is not null 
and 	([Eyeshadow Format] is not null 
or 		[Eyeshadow Effect] is not null 
or 		[Eyeshadow Color] is not null 
or 		[Eyeshadow No. of Color Multi-Shade] is not null)
END
GO
