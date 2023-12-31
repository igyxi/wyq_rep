/****** Object:  StoredProcedure [DW_Transcosmos].[SP_RPT_OBC_Performance_Monthly_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Transcosmos].[SP_RPT_OBC_Performance_Monthly_Detail] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-09-29       wangzhichun        update sku
-- 2023-03-01       houshuangqiang     change  dw_oms.RPT_Sales_Order_SKU_Level to DWD.Fact_Sales_Order
-- ========================================================================================
delete from DW_Transcosmos.RPT_OBC_Performance_Monthly_Detail where dt = @dt;
insert into DW_Transcosmos.RPT_OBC_Performance_Monthly_Detail
select
	format(a.session_end_time,'yyyy-MM') as statistic_month,
	a.seat_name,
	a.seat_account,
	format(o.order_time, 'yyyy-MM-dd') as order_date,
	format(o.place_time, 'yyyy-MM-dd') as place_date,
	o.place_time,
    cast(a.session_end_time as date) as session_end_date,
    a.session_end_time,
	a.sales_order_number,
	o.channel_code as channel_cd,
	o.item_sku_code as item_sku_cd,
	sku.item_main_cd,
	o.item_sku_name as item_name,
	sku.item_brand_name,
	sku.item_brand_type,
	sku.item_category,
	member.eb_user_id as sephora_user_id,
	o.member_card_grade,
	o.item_apportion_amount,
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
) a
left join
(
	select 	sales_order_number
			,order_time
			,place_time
            ,case when sub_channel_code='TMALL006' then 'TMALL_WEI'
                when sub_channel_code='TMALL004' then 'TMALL_CHALING'
                when sub_channel_code='TMALL005' then 'TMALL_PTR'
                when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
                when sub_channel_code='DOUYIN001' then 'DOUYIN'
                when sub_channel_code='REDBOOK001' then 'REDBOOK'
                when sub_channel_code='JD003' then 'JD_FCS'
                when sub_channel_code in ('JD001','JD002') then 'JD'
                when sub_channel_code='GWP001' then 'OFF_LINE'
                else sub_channel_code 
                end as channel_code
			,member_card
			,member_card_grade
			,item_sku_code
			,item_sku_name
			,item_apportion_amount
	from 	DWD.Fact_Sales_Order
	where 	source = 'OMS'
    and     coalesce(item_sku_code,'') <>'TRP001'
	and 	coalesce(type_code, 0) <> 2
	--and 	format(order_time, 'yyyy-MM-dd') between dateadd(dd,1,eomonth(@dt,-2)) and dateadd(dd,5,eomonth(@dt,-1))
	group 	by sales_order_number,order_time,place_time,channel_code,member_card,member_card_grade,item_sku_code,item_sku_name,item_apportion_amount,
            case when sub_channel_code='TMALL006' then 'TMALL_WEI'
                        when sub_channel_code='TMALL004' then 'TMALL_CHALING'
                        when sub_channel_code='TMALL005' then 'TMALL_PTR'
                        when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
                        when sub_channel_code='DOUYIN001' then 'DOUYIN'
                        when sub_channel_code='REDBOOK001' then 'REDBOOK'
                        when sub_channel_code='JD003' then 'JD_FCS'
                        when sub_channel_code in ('JD001','JD002') then 'JD'
                        when sub_channel_code='GWP001' then 'OFF_LINE'
                        else sub_channel_code
                        end
) o
on      a.sales_order_number = o.sales_order_number
left join
(
    select 	sku_code
            ,eb_main_sku_code as item_main_cd
			,eb_category as item_category
            ,eb_brand_type as item_brand_type
            ,eb_brand_name as item_brand_name
    from	DWD.DIM_SKU_Info
	group 	by sku_code,eb_main_sku_code,eb_category,eb_brand_type,eb_brand_name
) sku
on 	    o.item_sku_code = sku.sku_code
left    join DWD.DIM_Member_Info member
on      o.member_card = member.member_card
END

GO
