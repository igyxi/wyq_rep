/****** Object:  StoredProcedure [TEMP].[SP_RPT_MNP_APP_Buyer_Monthly_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_MNP_APP_Buyer_Monthly_Bak_20230413] @dt [VARCHAR](10) AS 
begin
delete from [DW_OMS].[RPT_MNP_APP_Buyer_Monthly] where statics_month>=cast(cast(dateadd(month,-1,@dt) as date) as varchar(7));
--用户渠道卡别下单时间基础视图
with sales AS
(
    SELECT
        card_no,
        order_date,
        channel_cd,
        case 
            when monthly_card_level = 1 then 'PINK'
            when monthly_card_level in (2,3) then 'WHITE'
            when monthly_card_level = 4 then 'BLACK'
            when monthly_card_level = 5 then 'GOLD'
            else 'NULL'
        end as monthly_member_card_grade
    from
    (
        select
            member_card as card_no,
            case 
                when channel_cd in('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM') then 'MINIPROGRAM'
                when channel_cd in('APP(IOS)','APP(ANDROID)','APP') then 'APP'
                when channel_cd in('WCS','PC') then 'PC'
                else channel_cd 
            end as channel_cd,
            max(member_card_level) over (partition by member_card, year(order_date), month(order_date)) as monthly_card_level,
            order_date
        from
            [DW_OMS].[RPT_Sales_Order_Basic_Level]
        where 
            is_placed_flag=1
           and order_date between cast(DATEADD(mm, DATEDIFF(mm,0,@dt)-1, 0) as date) and @dt --example：2021-11-30
           and channel_cd in('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','APP(IOS)','APP(ANDROID)','APP')
           and member_card is not null
    )a
)
--用户在不同的渠道下是否有交叉下单基础表
insert into [DW_OMS].[RPT_MNP_APP_Buyer_Monthly]
select
    cast(coalesce(a.order_date,b.order_date) as varchar(7)) as statics_month,
    case when a.card_no = b.card_no then a.card_no else null end as cross_card_no,
    case when a.channel_cd = 'MINIPROGRAM' then a.card_no else null end as mnp_card_no,
    case when b.channel_cd = 'APP' then b.card_no else null end as app_card_no,
    coalesce(a.monthly_member_card_grade,b.monthly_member_card_grade) as cross_monthly_member_card_grade,
    current_timestamp as insert_timestamp
from
(
    select 
	    * 
	FROM 
	    sales 
	where 
	    channel_cd = 'MINIPROGRAM'
)a
full join
(
    select 
        * 
    FROM 
        sales 
    where 
        channel_cd = 'APP'
)b
on a.card_no = b.card_no and year(a.order_date)=year(b.order_date) and month(a.order_date)=month(b.order_date)
;
UPDATE STATISTICS [DW_OMS].[RPT_MNP_APP_Buyer_Monthly];
end

GO
