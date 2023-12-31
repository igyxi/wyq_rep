/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_SmartBA_Store_Tracking_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_SmartBA_Store_Tracking_Monthly] @dt [varchar](10) AS
begin
delete from [DW_SmartBA].[RPT_SmartBA_Store_Tracking_Monthly] where dt = @dt;
insert into [DW_SmartBA].[RPT_SmartBA_Store_Tracking_Monthly]
select
    statistics_month,
    store_code,
    vaild_customers,
    increased_vaild_customers,
	mp_bundle_target,
	target_customers,
    traffic,
    increased_vaild_customers_ratio,
    meet_target,
    current_timestamp as insert_timestamp,
	@dt as dt
from
    [DW_SmartBA].[RPT_SmartBA_Store_Tracking_Daily]
where 
    dt = @dt
;
end
GO
