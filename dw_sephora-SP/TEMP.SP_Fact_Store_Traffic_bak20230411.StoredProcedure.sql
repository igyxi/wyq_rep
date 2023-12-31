/****** Object:  StoredProcedure [TEMP].[SP_Fact_Store_Traffic_bak20230411]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Store_Traffic_bak20230411] @dt [varchar](512) AS 
BEGIN
delete from DWD.Fact_Store_Traffic where [Date] = @dt;
insert into DWD.Fact_Store_Traffic
select 
    Store_Code,
    convert(date, cast(Date_Key as nvarchar), 112) as [date],
    Hour_Key,
    Currency_Name,
    Visitors,
    CreateTime,
    LastUpdateTime,
    BatchNo,
    'Traffic' as source,
    CURRENT_TIMESTAMP
from
    DW_Traffic.Fact_Traffic_ByHour
where
    Date_Key = format(cast(@dt as date), 'yyyyMMdd')
;
END
GO
