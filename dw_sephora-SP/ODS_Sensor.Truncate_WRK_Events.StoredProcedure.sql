/****** Object:  StoredProcedure [ODS_Sensor].[Truncate_WRK_Events]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Sensor].[Truncate_WRK_Events] AS 
BEGIN
    truncate table ODS_Sensor.WRK_Events
END
GO
