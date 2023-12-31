/****** Object:  StoredProcedure [TEMP].[SP_RPT_Douyin_Order_Overview_BAK20230428]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Douyin_Order_Overview_BAK20230428] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-24       litao           Initial Version
-- ========================================================================================


truncate table RPT.RPT_Douyin_Order_Overview; 
insert into RPT.RPT_Douyin_Order_Overview
select
    author_name as store_name,
    order_date as dt,
    sum(apportion_amount) as order_amt,
    sum(case when related_id is not null then refund_amount else 0 end) as refund_order_amt,
    sum(case when order_source = N'直播间' then apportion_amount else 0 end) as live_order_amt,
    sum(case when order_source = N'短视频' then apportion_amount else 0 end) as video_order_amt,
    sum(case when order_source not in (N'短视频', N'直播间') then apportion_amount else 0 end) as showcase_order_amt,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DW_OMS.DWS_Douyin_Sales_Order_With_VB
where
    is_placed = 1
group by 
    author_name,
    order_date
;
END
GO
