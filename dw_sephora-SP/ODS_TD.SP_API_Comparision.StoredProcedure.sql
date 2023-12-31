/****** Object:  StoredProcedure [ODS_TD].[SP_API_Comparision]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_API_Comparision] @StartDate [datetime],@EndDate [datetime] AS

    delete from ODS_TD.Tb_API_Comparision
    where [Date] >= @StartDate and [Date] < @EndDate

    insert into ODS_TD.Tb_API_Comparision
    select
        a.[Date],
        a.appkey,
        a.TDEvent,
        a.TDCountRow,
        b.TDCountRow,
        convert(numeric(10,4),case when isnull(a.TDCountRow,0)=0 then 0 else (b.TDCountRow-a.TDCountRow)*100.0000/a.TDCountRow end) CompPercnt
    from (
        select *
        from STG_TD.Tb_API_Comparision
        where [Date] >= @StartDate and [Date] < @EndDate and Flag=0
    ) a
    ,(
        select *
        from STG_TD.Tb_API_Comparision
        where [Date] >= @StartDate and [Date] < @EndDate and Flag=1
    )b
    where a.[Date]=b.[Date]
        and a.appkey=b.appkey
        and a.TDEvent=b.TDEvent
GO
