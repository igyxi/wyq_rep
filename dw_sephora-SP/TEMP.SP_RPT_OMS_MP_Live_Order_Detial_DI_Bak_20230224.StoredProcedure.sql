/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_MP_Live_Order_Detial_DI_Bak_20230224]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_MP_Live_Order_Detial_DI_Bak_20230224] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-26       tali           add collate
-- ========================================================================================
delete from DW_OMS.RPT_OMS_MP_Live_Order_Detial_DI where dt = @dt;
insert into DW_OMS.RPT_OMS_MP_Live_Order_Detial_DI
select
    vb.statistic_date,
    vb.statistic_hour,
    vb.member_card,
    vb.payment_time, 
    vb.channel_cd,
    vb.sales_order_number,
    vb.item_brand,
    vb.item_category,
    vb.item_sku_cd,
    vb.item_main_cd,
    vb.item_name,
    vb.item_apportion_amount,
    vb.item_quantity,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(    
    select
        format(place_time,'yyyy-MM-dd') as statistic_date,
        datepart(hh,place_time) as statistic_hour,
        sales_order_number,
        member_card,
        place_time as payment_time,
        channel_cd,
        item_brand_name as item_brand,
        item_sku_cd,
        item_main_cd,
        item_name,
        item_category,
        round(sum(item_apportion_amount),2) as item_apportion_amount,
        sum(item_quantity) as item_quantity
    from 
         DW_OMS.RPT_Sales_Order_VB_Level
    where 
        is_placed_flag = 1
        and format(place_time,'yyyy-MM-dd') = @dt
        and channel_cd in ('MINIPROGRAM','BENEFITMINIPROGRAM','ANNYMINIPROGRAM')
    group by 
        sales_order_number,
        member_card,
        place_time,
        channel_cd,
        item_brand_name,
        item_sku_cd,
        item_main_cd,
        item_name,
        item_category
) vb
inner join
(
    select distinct
        vip_card
    from 
        STG_Sensor.Events
    where 
        dt = @dt
        and event = '$MPViewScreen' 
        and ss_url_path = 'live/redirect'
) et
on vb.member_card =  et.vip_card collate SQL_Latin1_General_CP1_CI_AS;
END

GO
