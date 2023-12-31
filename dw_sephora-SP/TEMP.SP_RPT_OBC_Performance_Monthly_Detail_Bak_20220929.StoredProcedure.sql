/****** Object:  StoredProcedure [TEMP].[SP_RPT_OBC_Performance_Monthly_Detail_Bak_20220929]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OBC_Performance_Monthly_Detail_Bak_20220929] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Transcosmos.RPT_OBC_Performance_Monthly_Detail where dt = @dt;
insert into DW_Transcosmos.RPT_OBC_Performance_Monthly_Detail
select 
	format(a.session_end_time,'yyyy-MM') as statistic_month,
	a.seat_name,
	a.seat_account,
	b.order_date,
	b.place_date,
	b.place_time,
    cast(a.session_end_time as date) as session_end_date,
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
            dt between dateadd(dd,1,eomonth(@dt,-2)) and dateadd(dd,5,eomonth(@dt,-1))
        and 
            seat_account is not null
        and 
            format(session_end_time,'yyyy-MM') = format(eomonth(@dt,-1),'yyyy-MM')
    )a
   left join
    (
        select distinct
            sales_order_number,
            order_time,
            order_date,
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
on a.sales_order_number = b.sales_order_number
left join
    (
        select distinct
            sku_cd as item_sku_cd,
            main_cd as item_main_cd
        from
            [DW_Product].[DWS_SKU_Profile]
    )c
on 
    b.item_sku_cd = c.item_sku_cd
-- where 
--     b.place_date between dateadd(dd,1,eomonth(@dt,-2)) and dateadd(dd,5,eomonth(@dt,-1));
END



-- [DW_Transcosmos].[SP_RPT_OBC_Performance_Monthly_Detail] '2021-12-07'
GO
