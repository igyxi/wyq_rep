/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_Order_Overall_Tracking_Pending]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_Order_Overall_Tracking_Pending] @dt [varchar](10) AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       tali     Initial Version
-- ========================================================================================
delete from [DW_OMS].[RPT_Order_Overall_Tracking_Pending] where statistic_date = @dt;
insert into [DW_OMS].[RPT_Order_Overall_Tracking_Pending]
select
    @dt as statistic_date,
    case when store_cd ='S001' then store_cd else channel_cd end as store_cd,
    sum(case when format(place_time,'yyyy-MM-dd') = @dt then payed_amount else 0 end) as pending_daily,
    sum(payed_amount) as pending_mtd,
    current_timestamp as insert_timestamp
from
    [DW_OMS].[RPT_Pending_Orders]
where 
    dt = @dt
and place_time > dateadd(day,1,EOMONTH(@dt,-1))
and format(place_time,'yyyy-MM-dd') <= @dt
GROUP by case when store_cd ='S001' then store_cd else channel_cd end
END
GO
