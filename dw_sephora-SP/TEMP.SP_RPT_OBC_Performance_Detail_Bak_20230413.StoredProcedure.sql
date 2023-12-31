/****** Object:  StoredProcedure [TEMP].[SP_RPT_OBC_Performance_Detail_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OBC_Performance_Detail_Bak_20230413] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-09-29       wubin              update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- ========================================================================================
delete from DW_Transcosmos.RPT_OBC_Performance_Detail where dt = @dt;
insert into DW_Transcosmos.RPT_OBC_Performance_Detail
select
    a.seat_name,
    a.seat_account,
    b.place_date,
    b.place_time,
    a.session_end_time,
    a.sales_order_number,
    b.channel_cd,
    b.item_sku_cd,
    c.item_main_cd,
    b.item_name,
    b.item_brand_name,
    b.item_brand_type,
    b.item_category,
    b.sephora_user_id,
    b.member_card_grade,
    b.item_apportion_amount,
    current_timestamp as insert_timestamp,
    @dt as dt
from
( 
 select distinct 
        sales_order_number,
        session_end_time,
        seat_name,
        seat_account
 from 
     [DW_Transcosmos].[DWS_IM_Service_Sales_Order_Detail] 
 where 
    dt = @dt
 and 
    seat_account is not null
)a
left join 
(
    select distinct
       sales_order_number,
       place_time,
       place_date,
       channel_cd,
       item_sku_cd,
       item_name,
       item_apportion_amount,
       sephora_user_id,
       member_card_grade,
       item_category,
       item_brand_type,
       item_brand_name
    from
        [DW_OMS].[RPT_Sales_Order_SKU_Level]
    where 
        isnull(split_type_cd,'')<>'SPLIT_ORIGIN'
    and 
        isnull(type_cd,0)<>2 
    )b 
on 
    a.sales_order_number = b.sales_order_number
left join 
(
select distinct
    sku_code as item_sku_cd,
    eb_main_sku_code as item_main_cd
from
    dwd.DIM_SKU_Info
) c
on b.item_sku_cd = c.item_sku_cd;
END
GO
