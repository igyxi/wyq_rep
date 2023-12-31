/****** Object:  StoredProcedure [DW_Transcosmos].[SP_DWS_IM_Service_Sales_Order_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Transcosmos].[SP_DWS_IM_Service_Sales_Order_Detail] @dt [VARCHAR](10) AS--2023-02-17
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-07-05       tali           add 美容顾问
-- 2022-08-25       houshuangqiang add HomeChat
-- 2023-02-17       houshuangqiang update source_table [DW_OMS].[DWS_Sales_Order] to DWD.Fact_OMS_Sales_Order
-- ========================================================================================
delete from DW_Transcosmos.DWS_IM_Service_Sales_Order_Detail where dt = @dt;
insert into DW_Transcosmos.DWS_IM_Service_Sales_Order_Detail
select 
    seat_account,
    seat_name,
    seat_vendors,
    member_id,
    session_start_time,
    session_end_time,
    sales_order_number,
    payed_amount,
    place_time,
    row_number() over(partition by seat_account,member_id,place_date order by place_time desc) place_daily_seq,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        a.sales_order_number,
        member.eb_user_id as member_id,
        a.payed_amount,
        a.place_time,
        format(a.place_time, 'yyyy-MM-dd')  as place_date,
        c.seat_account,
        c.seat_name,
        c.seat_vendors,
        c.session_start_time,
        c.session_end_time,
        row_number() over(partition by a.sales_order_number order by c.session_start_time desc) as rn
    from
    (
        select sales_order_number,
                member_card,
                payment_amount as payed_amount,
                place_time   --2023-04-04修改
--                max(format(place_time, 'yyyy-MM-dd')) as place_date
        from    DWD.Fact_Sales_Order
        where   is_placed = 1
        and     source = 'OMS'
        and     channel_code = 'SOA'
        and     format(place_time, 'yyyy-MM-dd') = @dt
        group   by sales_order_number,member_card,payment_amount,place_time
    ) a
    left    join DWD.DIM_Member_info member 
    on      a.member_card = member.member_card
    left    join 
    (
        select 
            b.seat_account,
            a.agent_name as seat_name,
            b.seat_vendors,
            a.visitor_name as user_id,
            a.begin_time as session_start_time,
            a.end_time as session_end_time
        from
            [STG_Transcosmos].[CS_IM_Service] a
        left join
            [STG_Transcosmos].[Seat_Info] b
        on a.agent_name = b.seat_name
        where
            dt > cast(DATEADD(day,-5, cast(@dt as date)) as varchar)
        and PATINDEX('%[^0-9]%',a.visitor_name) = 0
        and group_name in (N'售前咨询',N'商品相关', N'美容顾问', 'HomeChat')
    ) c
    on member.eb_user_id = c.user_id
    where
        a.place_time > c.session_start_time
    and c.user_id is not null
    and datediff(day, c.session_start_time, a.place_time) >= 0
    and datediff(day, c.session_start_time, a.place_time) < 5
) t
where rn = 1;
END

GO
