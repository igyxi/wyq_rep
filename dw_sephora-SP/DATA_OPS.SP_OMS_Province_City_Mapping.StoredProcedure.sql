/****** Object:  StoredProcedure [DATA_OPS].[SP_OMS_Province_City_Mapping]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_OMS_Province_City_Mapping] AS

INSERT INTO [DATA_OPS].[OMS_Province_City_Mapping](oms_province,oms_city)
SELECT DISTINCT
	soa.province,
	soa.city
FROM STG_OMS.Sales_Order_Address soa
WHERE
	NOT EXISTS (
		SELECT 1
		FROM [DATA_OPS].[OMS_Province_City_Mapping] pcm
		WHERE soa.province = pcm.oms_province
			AND ISNULL(soa.city, '') = ISNULL(pcm.oms_city, '')
	)
	AND (soa.province IS NOT NULL OR soa.city IS NOT NULL)

GO
