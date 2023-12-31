/****** Object:  StoredProcedure [TEMP].[SP_RPT_O2O_Order_Statistics_By_Channel_Bak]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_O2O_Order_Statistics_By_Channel_Bak] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-15       wangzhichun    Initial Version
-- ========================================================================================
delete from RPT.RPT_O2O_Order_Statistics_By_Channel_Bak where dt=@dt;
insert into RPT.RPT_O2O_Order_Statistics_By_Channel_Bak
select
    format(stats.complete_date,'yyyy-MM-dd') as statistics_date,
    case when upper(channel.code) = 'DAZHONGDIANPING' then 'DIANPING'
          when upper(channel.code) = 'JINGDONGDAOJIA' then 'JDDJ'
          else upper(channel.code)
    end as channel_code,
    channel.name as channel_name,
    stats.shop_code as store_code,
    store.storenamecn as store_name,
    sum(coalesce(stats.sales_order_number,0)) as sales_quantity,
    sum(coalesce(stats.sales_amount,0)) as sales_amount,
    sum(coalesce(stats.refund_number,0)) as refund_quantity,
    sum(coalesce(stats.refund_amount,0)) as refund_amount,
    sum(coalesce(stats.return_number,0)) as return_quantity,
    sum(coalesce(stats.return_amount,0)) as return_amount,
    sum(coalesce(stats.sales_order_number,0))+ sum(coalesce(stats.refund_number,0))+ sum(coalesce(stats.return_number,0)) as total_quantity,
    sum(coalesce(stats.sales_amount,0))-sum(coalesce(stats.refund_amount,0))-sum(coalesce(stats.return_amount,0)) as total_amount,
    is_synt as is_sys,
    @dt as dt,
    CURRENT_TIMESTAMP as insert_timestamp
from
    stg_new_oms.omni_order_statistics stats
left join 
    STG_IMS.SYS_Dict_Detail channel  
on stats.platform_id=channel.id
left join 
    stg_nso.storeinfo store
on stats.shop_code = store.storeno
where 
    format(stats.complete_date,'yyyy-MM-dd')= @dt
group by
    format(stats.complete_date,'yyyy-MM-dd'),
    case when upper(channel.code) = 'DAZHONGDIANPING' then 'DIANPING'
          when upper(channel.code) = 'JINGDONGDAOJIA' then 'JDDJ'
          else upper(channel.code)
    end,
    channel.name,
    stats.shop_code,
    store.storenamecn,
    is_synt
;
END 
GO
