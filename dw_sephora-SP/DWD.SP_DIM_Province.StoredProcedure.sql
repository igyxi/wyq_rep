/****** Object:  StoredProcedure [DWD].[SP_DIM_Province]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Province] AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-03-31       houshuangqiang     add province_full_name column
-- ========================================================================================
truncate table DWD.DIM_Province;
insert into DWD.DIM_Province
select 
    province_id,
    province_name_en,
    province_name,
    case when province_name in (N'上海', N'北京', N'天津', N'重庆') then concat(province_name, N'市')
         when province_name in (N'西藏',N'内蒙古') then concat(province_name, N'自治区')
         when province_name = N'宁夏' then N'宁夏回族自治区'
         when province_name = N'广西' then N'广西壮族自治区'
         when province_name = N'新疆' then N'新疆维吾尔自治区'
         when province_name in (N'香港', N'澳门') then concat(province_name, N'特别行政区')
         else concat(province_name, N'省')
	end province_full_name,
    country_id,
    CURRENT_TIMESTAMP
from 
    ODS_CRM.province
end;
GO
