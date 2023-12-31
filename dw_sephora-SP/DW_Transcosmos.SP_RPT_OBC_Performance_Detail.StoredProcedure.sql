/****** Object:  StoredProcedure [DW_Transcosmos].[SP_RPT_OBC_Performance_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Transcosmos].[SP_RPT_OBC_Performance_Detail] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-09-29       wubin              update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2023-02-22       wangzhichun        update RPT_Sales_Order_SKU_Level -> Fact_Sales_Order
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
    c.item_brand_name,
    c.item_brand_type,
    c.item_category,
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
       fso.sales_order_number,
       fso.place_time,
       cast(fso.place_time as date) as place_date,
       case when fso.sub_channel_code='TMALL006' then 'TMALL_WEI'
            when fso.sub_channel_code='TMALL004' then 'TMALL_CHALING'
            when fso.sub_channel_code='TMALL005' then 'TMALL_PTR'
            when fso.sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
            when fso.sub_channel_code='DOUYIN001' then 'DOUYIN'
            when fso.sub_channel_code='REDBOOK001' then 'REDBOOK'
            when fso.sub_channel_code='JD003' then 'JD_FCS'
            when fso.sub_channel_code in ('JD001','JD002') then 'JD'
            when fso.sub_channel_code='GWP001' then 'OFF_LINE'
            else fso.sub_channel_code 
            end as channel_cd,
       item_sku_code as item_sku_cd,
       item_sku_name as item_name,
       item_apportion_amount,
       so.sephora_user_id,
       fso.member_card_grade
    -- item_category,
    -- item_brand_type,
    -- item_brand_name
    from
        [DWD].[Fact_Sales_Order] fso
    left join 
        [RPT].[RPT_Sales_Order_Basic_Level] so 
    on fso.sales_order_number=so.sales_order_number
    where
    --     isnull(split_type_cd,'')<>'SPLIT_ORIGIN'
    -- and 
        isnull(type_code,0)<>2 
        and coalesce(fso.item_sku_code,'') <>'TRP001'

)b 
on 
    a.sales_order_number = b.sales_order_number
left join 
(
    select distinct
        sku_code as item_sku_cd,
        eb_main_sku_code as item_main_cd,
        eb_brand_name as item_brand_name,
        eb_brand_type as item_brand_type,
        eb_category as item_category
    from
        dwd.DIM_SKU_Info
) c
on b.item_sku_cd = c.item_sku_cd;
END

GO
