/****** Object:  StoredProcedure [dbo].[usp_New_SAP_sales]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_New_SAP_sales] AS
begin
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW_SAP].[FACT_Sales]') AND type in (N'U'))
DROP TABLE [DW_SAP].[FACT_Sales];

with cte_sales_ticket as(
select 
a.ticket_date as Date_Key,
a.store_code,
a.Material_Code,
SUM(convert(float,Sales_VAT)) AS Sales_VAT,
SUM(convert(float,Sales_Ex_VAT)) AS Sales_Excl_VAT,
SUM(convert(float,isnull(Discount,0))) AS Discount,
sum(convert(float,Advised_Price_Sales)) AS Advised_Price_Sales,
SUM(convert(float,case when COGS=0 then [Receipts at cost] else COGS end)) AS COGS,
SUM(Quantity) AS Quantity,
sum(convert(float,[Sales_Ex_VAT])-convert(float,case when COGS=0 then [Receipts at cost] else COGS end)) AS [Gross_Profit],
max(Currency_Code) AS  Currency_Name,
substring(convert(nvarchar(50),ticket_date),1,4)+
'-'+substring(convert(nvarchar(50),ticket_date),5,2)+
'-'+substring(convert(nvarchar(50),ticket_date),7,2) 
AS CreateTime,
substring(convert(nvarchar(50),max(Date_modif)),1,4)+
'-'+substring(convert(nvarchar(50),max(Date_modif)),5,2)+
'-'+substring(convert(nvarchar(50),max(Date_modif)),7,2) 
AS LastUpdateTime
from ODS_SAP.sales_Ticket a
join ODS_SAP.Dim_Material b
on a.Material_Code=b.Material_Code
where isnull(market_code,'')+isnull(target_code,'')+isnull(category_code,'')+isnull(sales_nature_code,'')+
isnull(range_code,'')+isnull(nature_code,'')
 not in  (select ZMARCHE+ZCIBLE+ZRAYON+ZCOD_NATCA+ZGAMME+ZNATURE from ODS_SAP.DimSKu_filter c)
 and A.Material_Code <>'TRP001' and B.Material_Description not like  '%Gift Card%'
group by 
a.ticket_date,
a.store_code,
a.Material_Code
)
select 
[Date_Key]
,null as [Store_ID]
,a.[Store_Code]
,null as [Material_ID]
,a.[Material_Code]
,[Sales_VAT]
,[Sales_Excl_VAT]
,[Discount]
,[Advised_Price_Sales]
,[COGS]
,[Quantity]
,[Gross_Profit]
,null as [Currency_ID]
,a.[Currency_Name]
,null as [Animation_ID]
,'' as [Animation_Name]
,convert(date, a.[CreateTime]) as [CreateTime]
,convert(Date,a.[LastUpdateTime]) as [LastUpdateTime]
,convert(bigint,convert(nvarchar(10),dateadd(hh,8,getdate()),112))*1000000 + 
datepart(hour,dateadd(hh,8,getdate())) * 10000 +
datepart(minute,dateadd(hh,8,getdate())) * 100 +
datepart(second,dateadd(hh,8,getdate())) as [BatchNo]
,null as [Material_Country_ID]
,null as [Sales_VAT_USD]
,null as [Sales_Excl_VAT_USD]
,null as [CRM_Flag]
,null as [OrderNo]
,null as [Sales_Partition_ID]
,null as [Sales_VAT_Current]
into [DW_SAP].[FACT_Sales]
from cte_sales_ticket a
end

GO
