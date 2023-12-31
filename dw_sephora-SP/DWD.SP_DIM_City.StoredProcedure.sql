/****** Object:  StoredProcedure [DWD].[SP_DIM_City]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_City] AS 
begin
truncate table DWD.DIM_City;
insert into DWD.DIM_City
select 
    city_id,
    city_name_en,
    city_name,
    province_id,
    place_area_id,
    CURRENT_TIMESTAMP
from 
    ODS_CRM.City
end
GO
