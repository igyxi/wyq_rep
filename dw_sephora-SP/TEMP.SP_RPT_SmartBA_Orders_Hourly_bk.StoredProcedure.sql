/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_Orders_Hourly_bk]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_Orders_Hourly_bk] AS
BEGIN
truncate table [DW_SmartBA].[RPT_SmartBA_Orders_Hourly_bk];
insert into [DW_SmartBA].[RPT_SmartBA_Orders_Hourly_bk] select * from [DW_SmartBA].[RPT_SmartBA_Orders_Hourly]
end
GO
