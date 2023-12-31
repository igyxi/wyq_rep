/****** Object:  StoredProcedure [DWD].[SP_Fact_Promo_allocation_all_channels_non_clearance_vf]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Promo_allocation_all_channels_non_clearance_vf] AS
BEGIN

TRUNCATE TABLE [DWD].[Fact_Promo_allocation_all_channels_non_clearance_vf];

INSERT INTO [DWD].[Fact_Promo_allocation_all_channels_non_clearance_vf]
SELECT 
    [campaign_type],
	[campaign_channel_code],
	[campaign_member_card_grade_cn],
	[campaign_brand_type],
	[campaign_category],
	[campaign_segment],
	[campaign_offer_type],
	[campaign_id],
	[campaign_name],
	[is_campaign],
	[start_date],
	[end_date],
	[offer_type],
	[channel_code],
	[geo],
	[store_region_name],
	[city],
	[member_card_grade_cn],
	[brand_type],
	[sap_category],
	[segment],
	[sales],
	[cogs],
	[original_sales],
	DATEADD(HOUR,8,GETDATE()) AS [insert_time]
FROM [ODS_Promotion].[ods_allocation_all_channels_non_clearance_vf]
;

END
GO
