/****** Object:  StoredProcedure [ODS_Traffic].[usp_update_Fact_Traffic_Byhour]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Traffic].[usp_update_Fact_Traffic_Byhour] AS
begin
Declare @End_DateKey int
set @End_DateKey = Year(DATEADD(d,-11,DATEADD(HH,8,getdate()))) * 10000 + Month(DATEADD(d,-11,DATEADD(HH,8,getdate())))*100 + Day(DATEADD(d,-11,DATEADD(HH,8,getdate())))


delete from DW_Traffic.Fact_Traffic_ByHour
where Date_Key  >= @End_DateKey

insert into DW_Traffic.Fact_Traffic_ByHour(
    [Date_Key]
      ,[Hour_Key]
      ,[Store_ID]
      ,[Store_Code]
      ,[Currency_ID]
      ,[Currency_Name]
      ,[Visitors]
      ,[CreateTime]
      ,[LastUpdateTime]
      ,[BatchNo]
)
select [Date_Key]
      ,[Hour_Key]
      ,[Store_ID]
      ,[Store_Code]
      ,[Currency_ID]
      ,[Currency_Name]
      ,[Visitors]
      ,[CreateTime]
      ,[LastUpdateTime]
      ,[BatchNo]
from ODS_Traffic.Traffic_ByHour with(nolock)
where Date_Key >= @End_DateKey
end
GO
