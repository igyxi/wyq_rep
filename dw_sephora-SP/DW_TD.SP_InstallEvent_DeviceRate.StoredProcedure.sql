/****** Object:  StoredProcedure [DW_TD].[SP_InstallEvent_DeviceRate]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_InstallEvent_DeviceRate] AS

  TRUNCATE TABLE DW_TD.Tb_InstallEvent_DeviceRate
  
  INSERT INTO DW_TD.Tb_InstallEvent_DeviceRate
  SELECT 
  FORMAT([active_time],'yyyy') as [Year],
  FORMAT([active_time],'MM') as [Month],
  [channel_name],
  'Android' as [OS],
  COUNT(1) AS [Install],
  SUM(CASE WHEN ISNULL([android_id],'') <> '' THEN 1 ELSE 0 END) as [Install_with_Device]
  --INTO DW_TD.Tb_InstallEvent_DeviceRate
  FROM [ODS_TD].[Tb_Android_Install]
  --WHERE [active_time] >= '2021-08-23'
  GROUP BY FORMAT([active_time],'yyyy'),
  FORMAT([active_time],'MM'),
  [channel_name]
  UNION ALL
  SELECT 
  FORMAT([active_time],'yyyy') as [Year],
  FORMAT([active_time],'MM') as [Month],
  [channel_name],
  'IOS' as [OS],
  COUNT(1) AS [Install],
  SUM(CASE WHEN ISNULL([idfa],'') <> '' THEN 1 ELSE 0 END) as [Install_with_Device]
  FROM [ODS_TD].[Tb_IOS_Install]
  WHERE [active_time] >= '2021-08-20'
  GROUP BY FORMAT([active_time],'yyyy'),
  FORMAT([active_time],'MM'),
  [channel_name]

GO
