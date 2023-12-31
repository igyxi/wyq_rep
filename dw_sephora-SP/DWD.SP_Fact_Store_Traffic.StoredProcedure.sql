/****** Object:  StoredProcedure [DWD].[SP_Fact_Store_Traffic]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Store_Traffic] @dt [varchar](512) AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-11       weichen         update [Date]&[Date_Key] >=dt -29 day
-- ========================================================================================
delete from DWD.Fact_Store_Traffic where [Date] >= dateadd(Day,-29,cast(@dt as date));
insert into DWD.Fact_Store_Traffic
select 
    Store_Code,
    convert(date, cast(Date_Key as nvarchar), 112) as [date],
    Hour_Key,
    Currency_Name,
    Visitors,
    CreateTime,
    LastUpdateTime,
    convert(bigint,convert(nvarchar(10),dateadd(hour,8,getUTCdate()),112))*1000000 + datepart(hour,dateadd(hour,8,getUTCdate())) * 10000 + datepart(minute,dateadd(hour,8,getUTCdate())) * 100 + datepart(second,dateadd(hour,8,getUTCdate())) as [Batch_No],
    'Traffic' as source,
    CURRENT_TIMESTAMP
from
    DW_Traffic.Fact_Traffic_ByHour
where
    Date_Key >= format(dateadd(Day,-29,cast(@dt as date)), 'yyyyMMdd')
;
END
GO
