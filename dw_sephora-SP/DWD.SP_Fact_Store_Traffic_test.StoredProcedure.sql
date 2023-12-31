/****** Object:  StoredProcedure [DWD].[SP_Fact_Store_Traffic_test]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Store_Traffic_test] AS 
BEGIN
truncate table DWD.Fact_Store_Traffic ;
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

END
GO
