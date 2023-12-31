/****** Object:  StoredProcedure [TEST].[SP_Fact_SmartBA_Scan_Record]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_Fact_SmartBA_Scan_Record] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-19       weichen        Initial Version
-- ========================================================================================
TRUNCATE TABLE TEST.Fact_SmartBA_Scan_Record
INSERT INTO TEST.Fact_SmartBA_Scan_Record

SELECT   
  id,
  unionid as union_id,
  barcode as bar_code,
  storecode as store_code,
  baaccount as ba_account,
  createtime as create_time,
  dt
FROM TEST.Wechat_BA_Sign_Info
;
END
GO
