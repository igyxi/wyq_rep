/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_Order_Employee_Monthly_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_Order_Employee_Monthly_Bak_20230413] @dt [varchar](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       mac             delete 'COLLATE Chinese_PRC_CS_AI_WS'
-- ========================================================================================
delete from [DW_SmartBA].[RPT_SmartBA_Order_Employee_Monthly] where statistic_month=cast(@dt as varchar(7));
insert into [DW_SmartBA].[RPT_SmartBA_Order_Employee_Monthly]
select
    cast(@dt as varchar(7)) as statistic_month,
    b.member_card as member_card,
    b.monthly_member_card_grade as monthly_card_grade,
    b.member_monthly_new_status as monthly_new_to_eb_flag,
    case when b.member_channel_monthly_seq = 1 and channel_cd in ('BENEFITMINIPROGRAM','ANNYMINIPROGRAM','MINIPROGRAM') then 'NEW' else 'RETURN' end as monthly_new_to_mnp_flag,
    a.utm_term as employee_code,
    c.store_code as store_code,
    c.store_name ,
    c.region  as store_great_region,
    c.subregion  as store_region,
    c.district  as store_district,
    c.city  as store_city,
    current_timestamp as insert_timestamp
from
(
    select
        *
    from
        [STG_Order].[Order_Source]
    where 
        utm_campaign = 'BA' 
    and 
        utm_medium ='seco'
)a
left join 
(
    select
        sales_order_number,
        monthly_member_card_grade,
        member_card,
        member_monthly_new_status,
        format(place_time, 'yyyy-MM') as place_month,
        min(channel_order_valid_seq) over (partition by super_id, is_placed_flag, channel_cd, format(place_time, 'yyyy-MM')) as member_channel_monthly_seq,
        channel_cd
    from
        [DW_OMS].[RPT_Sales_Order_Basic_Level]
    where
        is_placed_flag = 1
    and
        format(place_time, 'yyyy-MM') = cast(@dt as varchar(7))
) b
on 
    a.order_id = b.sales_order_number
left join
    [ODS_CRM].[DimStore] c
on 
    a.utm_content = c.store_code 
where
    b.member_card is not null
;
end
GO
