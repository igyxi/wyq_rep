/****** Object:  StoredProcedure [DW_SAP].[SP_Fact_Budget_Fin_Sales]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SAP].[SP_Fact_Budget_Fin_Sales] AS
truncate table DW_SAP.Fact_Budget_Fin_Sales;
insert into DW_SAP.Fact_Budget_Fin_Sales(
Date_key,
Store_code,
Local_currency,
BDGT_Budget,
R1_Budget,
R2_Budget,
Sales_Budget,
Batchno
)
select
Date_key,
Store_code,
Local_currency,
[BDGT] as BDGT_Budget,
[R1] as R1_Budget,
[R2] as R2_Budget,
[Sales] as Sales_Budget,
format(dateadd(hour,8,Getutcdate()),'yyyyMMddHHmmss') as Batchno
from (select 
Date_key,
store_code,
Local_currency,
Budget_version,
max(Sales_at_rtl) as Sales_at_rtl
--max(Created_by) as Created_by,
--Convert(date,max(Created_Time)) as Created_Time,
 from  ODS_SAP.Budget_Fin_Sales
group by 
Date_key,
store_code,
Local_currency,
Budget_version
) p
pivot  (sum(Sales_at_rtl) for Budget_version
IN
(
[BDGT],
[R1],
[R2],
[Sales]
)) as a
where not exists(
select 1 from DW_SAP.Fact_Budget_Fin_Sales  f where a.date_key=f.date_key and a.store_code=F.store_code
)
GO
