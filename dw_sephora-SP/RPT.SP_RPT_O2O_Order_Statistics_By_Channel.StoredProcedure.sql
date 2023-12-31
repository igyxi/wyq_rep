/****** Object:  StoredProcedure [RPT].[SP_RPT_O2O_Order_Statistics_By_Channel]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_O2O_Order_Statistics_By_Channel] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-08       wangzhichun    Initial Version
-- 2022-12-13       wangzhichun    delete column
-- 2022-12-15       wangzhichun    change source table schema
-- 2023-01-13       wangzhichun    change delete
-- 2023-03-29       lizeyuan       update source table
-- ========================================================================================
delete from RPT.RPT_O2O_Order_Statistics_By_Channel where statistics_date in 
(
    select 
        distinct format(stats.complete_date,'yyyy-MM-dd')
    from 
        ODS_OMS_Order.omni_order_statistics stats 
    where     
        format(stats.create_time,'yyyy-MM-dd')>= @dt 
        or format(stats.modify_time,'yyyy-MM-dd')>= @dt
);

insert into RPT.RPT_O2O_Order_Statistics_By_Channel
select
    format(stats.complete_date,'yyyy-MM-dd') as statistics_date,
    case when upper(channel.code) = 'DAZHONGDIANPING' then 'DIANPING'
          when upper(channel.code) = 'JINGDONGDAOJIA' then 'JDDJ'
          else upper(channel.code)
    end as channel_code,
    channel.name as channel_name,
    stats.shop_code as store_code,
    store.nso_store_name as store_name,
    coalesce(sales_order_number,0) as sales_quantity,
    coalesce(sales_amount,0) as sales_amount,
    coalesce(refund_number,0) as refund_quantity,
    coalesce(refund_amount,0) as refund_amount,
    coalesce(return_number,0) as return_quantity,
    coalesce(return_amount,0) as return_amount,
    coalesce(stats.sales_order_number,0)+ coalesce(stats.refund_number,0)+ coalesce(stats.return_number,0) as total_quantity,
    coalesce(stats.sales_amount,0)-coalesce(stats.refund_amount,0)-coalesce(stats.return_amount,0) as total_amount,
    @dt as dt,
    CURRENT_TIMESTAMP as insert_timestamp
from
    ODS_OMS_Order.omni_order_statistics stats
left join 
    ODS_OIMS_System.SYS_Dict_Detail channel  
on stats.platform_id=channel.id
left join 
    DWD.DIM_Store store
on stats.shop_code = store.store_code
where 
    format(stats.complete_date,'yyyy-MM-dd') in
(
    select 
        distinct format(stats.complete_date,'yyyy-MM-dd')
    from 
        ODS_OMS_Order.omni_order_statistics stats 
    where     
        format(stats.create_time,'yyyy-MM-dd')>= @dt 
        or format(stats.modify_time,'yyyy-MM-dd')>= @dt
)
;
END 
GO
