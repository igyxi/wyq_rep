/****** Object:  StoredProcedure [RPT].[SP_RPT_Order_Statistics_YTD_New_Column]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Order_Statistics_YTD_New_Column] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-30       wangzhichun        Initial Version
-- 2023-02-02       wangzhichun        update
-- 2023-02-09       wangzhichun        add brand_type&item_quantiy
-- 2023-02-28       litao              update& add LY_buyer_Retention
-- ========================================================================================
delete from RPT.RPT_Order_Statistics_YTD_New_Column where statistics_month=FORMAT(@dt,'yyyy-MM');
insert into RPT.RPT_Order_Statistics_YTD_New_Column
-- channel_YTD
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    null as sub_channel_code,
    null as brand_type,
    null as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
    'channel_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed =1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- channel_status_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    null as sub_channel_code,
    null as brand_type,
    member_yearly_new_status as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'channel_status_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    member_yearly_new_status
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- channel_membership_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    null as sub_channel_code,
    null as brand_type,
    null as member_yearly_new_status,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'channel_membership_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- sub_channel_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end as sub_channel_code,
    null as brand_type,
    null as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- sub_channel_status_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end as sub_channel_code,
    null as brand_type,
    member_yearly_new_status as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_status_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end,
    member_yearly_new_status
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- sub_channel_membership_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end as sub_channel_code,
    null as brand_type,
    null as member_yearly_new_status,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_membership_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- Smart_BA sub_channel_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    'SMART_BA' as sub_channel_code,
    null as brand_type,
    null as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount  else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
    and sub_channel_code = 'MINIPROGRAM'
    and smartba_flag = 1
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- Smart_BA sub_channel_status_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    'SMART_BA' as sub_channel_code,
    null as brand_type,
    member_yearly_new_status as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_status_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
    and sub_channel_code = 'MINIPROGRAM'
    and smartba_flag = 1
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    member_yearly_new_status
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- Smart_BA sub_channel_membership_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    'SMART_BA' as sub_channel_code,
    null as brand_type,
    null as member_yearly_new_status,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_membership_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
    and sub_channel_code = 'MINIPROGRAM'
    and smartba_flag = 1
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- channel_brand_type_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    null as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type 
        end as brand_type,
    null as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'channel_brand_type_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type 
        end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- channel_brand_type_status_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    null as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end as brand_type,
    member_yearly_new_status as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'channel_brand_type_status_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type 
        end,
    member_yearly_new_status
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
-- channel_brand_type_membership_YTD
union all 
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    null as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end as brand_type,
    null as member_yearly_new_status,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'channel_brand_type_membership_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
---------------------------------20230228新增-------------------------------------------------------
--sub_channel_brand_YTD
union all
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end as brand_type,
    null as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_brand_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
--sub_channel_brand_status_YTD
union all
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end as brand_type,
    member_yearly_new_status as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity  else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_brand_status_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    member_yearly_new_status,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
--sub_channel_brand_membership_YTD
union all
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end as brand_type,
    null as member_yearly_new_status,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_brand_membership_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end,
    case when sub_channel_code in ('APP','APP(IOS)','APP(ANDROID)') then 'APP'
        when sub_channel_code in ('MINIPROGRAM','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT') then 'MNP'
        when sub_channel_code in ('PC','WCS') then 'PC'
        when sub_channel_code in ('MOBILE') then 'MOBILE'
        when sub_channel_code in ('JD001','JD002') then 'JD SEPHORA'
        when sub_channel_code ='JD003' then 'JD FCS'
        when sub_channel_code = 'TMALL001' then 'TMALL SEPHORA'
        when sub_channel_code = 'TMALL006' then 'TMALL WEI'
        when sub_channel_code = 'TMALL004' then 'TMALL CHALING'
        when sub_channel_code = 'TMALL005' then 'TMALL PTR'
        when sub_channel_code = 'DOUYIN001' then 'TIK TOK'
        when sub_channel_code = 'O2O' then 'O2O'
        when sub_channel_code = 'REDBOOK001' then 'RED BOOK'
        end,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
--Smart_BA sub_channel_brand_YTD
union all
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    'Smart_BA' as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end as brand_type,
    null as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_brand_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
    and sub_channel_code = 'MINIPROGRAM'
    and smartba_flag = 1
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
--Smart_BA sub_channel_brand_status_YTD
union all
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    'Smart_BA' as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end as brand_type,
    member_yearly_new_status as member_yearly_new_status,
    null as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_brand_status_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
    and sub_channel_code = 'MINIPROGRAM'
    and smartba_flag = 1
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    member_yearly_new_status, 
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
--Smart_BA sub_channel_brand_membership_YTD
union all
select
    format(@dt,'yyyy-MM') as statistics_month,
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end as channel_code,
    'Smart_BA' as sub_channel_code,
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end as brand_type,
    null as member_yearly_new_status,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end as member_card_grade,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  super_id end) as  buyers_number,
    count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end) as orders_number,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_apportion_amount else 0 end) as sales_amount,
    sum(case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then item_quantity else 0 end) as item_quantity,
    case
        when count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end)= 0 then 0
        else 
           round(cast(count(distinct case when year(place_date)= year(@dt) and month(place_date) between 1 and month(@dt) then super_id end) as float)/ count(distinct case when year(place_date)= FORMAT(DATEADD(year,-1, @dt), 'yyyy') then super_id end), 2)
    end as ly_buyer_retention,
	'sub_channel_brand_membership_YTD' as metric_flag,
    @dt as dt,
    current_timestamp as insert_timestamp
from    
    [RPT].[RPT_Sales_Order_VB_Level]
where is_placed = 1
    and sub_channel_code not in ('TMALL002','GWP001')
    and sub_channel_code = 'MINIPROGRAM'
    and smartba_flag = 1
	--and year(place_date)=year(@dt)
	--and month(place_date) between 1 and month(@dt)
	and place_date>=cast(concat(FORMAT(DATEADD(year,-1,@dt),'yyyy'),'-01-01') as date)  --取去年以来的数据
group by 
    case when channel_code = 'SOA' then 'DRAGON'
        when channel_code = 'DOUYIN' then 'TIK TOK'
        when channel_code = 'REDBOOK' then 'RED BOOK'
        else channel_code
        end,
    case when member_card_grade in ('WHITE','NEW') THEN 'WHITE'
        when member_card_grade = 'PINK' THEN 'PINK'
        when member_card_grade = 'BLACK' THEN 'BLACK'
        when member_card_grade = 'GOLD' THEN 'GOLD'
        else null end, 
    case when item_brand_type= 'OTHERS' then null 
        when item_brand_type = 'MASS MARKET' then 'EXCLUSIVE'
        else item_brand_type end
having count(distinct case when year(place_date)=year(@dt) and month(place_date) between 1 and month(@dt) then  sales_order_number end)>0
;

END
GO
