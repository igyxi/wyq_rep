/****** Object:  StoredProcedure [ODS_PIMHub].[Update_Statistics_ODS_PIMHub]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_PIMHub].[Update_Statistics_ODS_PIMHub] AS 
begin
update statistics [ODS_PIMHub].[MeiTuan_Store_Mapping];
end

GO
