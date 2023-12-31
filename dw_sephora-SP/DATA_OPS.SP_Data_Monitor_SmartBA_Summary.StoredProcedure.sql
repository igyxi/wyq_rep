/****** Object:  StoredProcedure [DATA_OPS].[SP_Data_Monitor_SmartBA_Summary]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_Data_Monitor_SmartBA_Summary] @dt [VARCHAR](10) AS
BEGIN

-- exec [DATA_OPS].[SP_Data_Monitor_SmartBA_Summary] '2022-01-01'
-- select * from [DATA_OPS].[Data_Monitor_SmartBA_Summary]

declare @month nvarchar(6)
set @month = left(replace(@dt, '-', ''), 6)

delete from [DATA_OPS].[Data_Monitor_SmartBA_Summary]
-- where dt = @dt
where left(month, 6) = @month

-- DECLARE @dt NVARCHAR(10) = '2022-04-03'

insert into [DATA_OPS].[Data_Monitor_SmartBA_Summary]
select 
	-- concat(left(date_id, 6), '01') as month
	date_id
	,case when source like 'EB%' then 'DOMO'
	        else substring(source, 1, charindex('_', source, 1) - 1) 
    end as layer
	,substring(kpi, 1, charindex(' ', kpi, 1) - 1) as platform
	,right(kpi, len(kpi) - charindex(' ', kpi, 1)) as sales_type
	,count(distinct sales_order_number) as so_count
	,count(distinct purchase_order_number) as po_count
	,cast(sum(sales_amount) as decimal(18,2)) as sales_amount
    ,CURRENT_TIMESTAMP AS [insert_timestamp]
	,@dt as dt
from [DATA_OPS].[Data_Monitor_SmartBA_Detail]
where dt = @dt
-- left(date_id, 6) = @month
-- format(dateadd(month, -1, dateadd(hour,8, GETUTCDATE())), 'yyyyMM')
group by 
	-- concat(left(date_id, 6), '01')
    date_id
	,case when source like 'EB%' then 'DOMO'
	else substring(source, 1, charindex('_', source, 1) - 1) end
	,substring(kpi, 1, charindex(' ', kpi, 1) - 1)
	,right(kpi, len(kpi) - charindex(' ', kpi, 1))
END
GO
