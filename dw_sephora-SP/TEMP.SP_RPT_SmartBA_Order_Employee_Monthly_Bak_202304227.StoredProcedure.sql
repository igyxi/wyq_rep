/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_Order_Employee_Monthly_Bak_202304227]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_Order_Employee_Monthly_Bak_202304227] @dt [varchar](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       mac                delete 'COLLATE Chinese_PRC_CS_AI_WS'
-- 2023-03-01       houshuangqiang     change  dw_oms.RPT_Sales_Order_Basic_Level to RPT.RPT_Sales_Order_Basic_Level
-- 2023-04-11       wangzhichun        change  table source
-- ========================================================================================
delete from [DW_SmartBA].[RPT_SmartBA_Order_Employee_Monthly] where statistic_month=cast(@dt as varchar(7));
insert into [DW_SmartBA].[RPT_SmartBA_Order_Employee_Monthly]
select distinct
    cast(@dt as varchar(7)) as statistic_month,
    b.member_card as member_card,
    b.monthly_member_card_grade as monthly_card_grade,
    b.member_monthly_new_status as monthly_new_to_eb_flag,
    case when b.member_channel_monthly_seq = 1 and b.channel_cd in ('BENEFITMINIPROGRAM','ANNYMINIPROGRAM','MINIPROGRAM') then 'NEW' else 'RETURN' end as monthly_new_to_mnp_flag,
    a.employee_code,
    c.store_code,
    c.store_name ,
    c.region  as store_great_region,
    c.subregion  as store_region,
    c.district  as store_district,
    c.city  as store_city,
    current_timestamp as insert_timestamp
from
    [DW_SmartBA].[RPT_SmartBA_Order_Detail] a
left join
(
    select
        sales_order_number,
        monthly_member_card_grade,
        member_card,
        member_monthly_new_status,
        place_month,
        min(channel_order_valid_seq) over (partition by super_id, is_placed, channel_cd, place_month) as member_channel_monthly_seq,
        channel_cd
    from
    (
        select 
                sales_order_number,
                member_monthly_card_grade as monthly_member_card_grade,
                member_card,
                member_monthly_new_status,
                super_id, 
                is_placed,
                format(place_time, 'yyyy-MM') as place_month,
                rank() over (partition by super_id,
                                case when (order_status like '%SIGNED%' or order_status like '%SHIPPED%') and is_placed=1 then 1 else 0 end, sub_channel_code order by place_time) as channel_order_valid_seq,                channel_code as channel_cd
        from
            RPT.[RPT_Sales_Order_Basic_Level]
    ) so
    where
            so.is_placed = 1
        and
            so.place_month = cast(@dt as varchar(7))
) b
on
    a.sales_order_number = b.sales_order_number
left join
    [ODS_CRM].[DimStore] c
on
    a.store_code = c.store_code
where
    b.member_card is not null
;
end
GO
