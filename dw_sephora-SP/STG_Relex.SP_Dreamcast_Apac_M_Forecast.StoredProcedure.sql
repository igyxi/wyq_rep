/****** Object:  StoredProcedure [STG_Relex].[SP_Dreamcast_Apac_M_Forecast]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Relex].[SP_Dreamcast_Apac_M_Forecast] @dt [nvarchar](10) AS

DELETE FROM [STG_Relex].[Dreamcast_Apac_M_Forecast] WHERE dt= @dt;
INSERT INTO [STG_Relex].[Dreamcast_Apac_M_Forecast]
SELECT 
    Forecast_Date,
    Time_id,
    Division,
    Material_Code,
    Baseline_Forecast_Qty,
    Animation_Forecast_Qty,
    [FileName],
    [BatchNo],
    Insert_timestamp,
    dt
FROM 
    [ODS_Relex].[Dreamcast_Apac_M_Forecast]
WHERE 
    dt= @dt

GO
