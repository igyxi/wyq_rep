/****** Object:  StoredProcedure [TEMP].[SP_DIM_Province_Bak_20221128]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Province_Bak_20221128] AS 
begin
truncate table DWD.DIM_Province;
insert into DWD.DIM_Province
select 
    province_id,
    province_name_en,
    province_name,
    country_id,
    CURRENT_TIMESTAMP
from 
    ODS_CRM.province
end

GO
