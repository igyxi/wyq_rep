/****** Object:  StoredProcedure [STG_PIMHub].[Update_Statistics_STG_PIMHub]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_PIMHub].[Update_Statistics_STG_PIMHub] AS 
begin
update statistics [STG_PIMHub].[MeiTuan_Store_Mapping];
end
GO
