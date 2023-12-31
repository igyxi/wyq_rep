/****** Object:  StoredProcedure [DWD].[SP_DIM_Promotion_Universe]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Promotion_Universe] AS
BEGIN

TRUNCATE TABLE DWD.Dim_Promotion_Universe;

INSERT INTO DWD.Dim_Promotion_Universe
SELECT 
	DISTINCT
	promotion_id_unique,
	promotion_id,offer_name,
	offer_type,
	campaign_id_unique,
	campaign_id,
	campaign_name,
	campaign_type,
	campaign_start_date,
	campaign_end_date
	,dateadd(hour,8,getdate())  insert_time
from ODS_Promotion.ods_allocation_all_channels_non_clearance
where campaign_start_date is not null

END;

GO
