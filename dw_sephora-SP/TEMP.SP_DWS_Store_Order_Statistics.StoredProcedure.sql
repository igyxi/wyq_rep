/****** Object:  StoredProcedure [TEMP].[SP_DWS_Store_Order_Statistics]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Store_Order_Statistics] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-27       houshuangqiang     New_OMS数据往老的OrderHub.Store_Order_Statistics，供下游使用。
-- ========================================================================================
truncate table DW_New_OMS.DWS_Store_Order_Statistics;
insert into DW_New_OMS.DWS_Store_Order_Statistics
select  o.id as order_statistics_id
        ,format(o.complete_date,'yyyy-MM-dd') as statistics_date    -- New_OMS增加的complete_date, 这个作为统计日期
        ,o.shop_code as store_code
        ,o.original_sales_amount
        ,o.sales_amount
        ,o.sales_order_number
        ,coalesce(o.refund_amount,0) + coalesce(o.return_amount, 0) as refund_amount
        ,coalesce(o.refund_number,0) + coalesce(o.return_number, 0) as refund_number
		,case when upper(channel.code) = 'DAZHONGDIANPING' then 'DIANPING'
		      when upper(channel.code) = 'JINGDONGDAOJIA' then 'JDDJ'
		      else upper(channel.code)
		end as channel_id
		,0 as is_delete
		,o.create_user
		,o.create_time
		,'' as update_user
		,null as update_time
		,o.is_synt as is_sync  -- is_sync = 1 为OrderHub 同步至New_OMS的标识
		,current_timestamp as insert_timestamp
from    STG_New_OMS.OMNI_Order_Statistics o
left    join  STG_IMS.SYS_Dict_Detail channel
on      o.platform_id=channel.id
END
GO
