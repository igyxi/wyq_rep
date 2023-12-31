/****** Object:  StoredProcedure [dbo].[usp_Sync_Fact_Budget]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_Sync_Fact_Budget] AS
BEGIN

with orderNO_less0 as(
select  Ticket_Date,Store_Code,max(currency_code) as currency_code,'66' +  convert(nvarchar(100),Store_Code)
  +
  convert(nvarchar(100),right(Till_Number,3))
  +
  convert(nvarchar(100),right(Transaction_Number,18))
  +
  convert(nvarchar(100),Ticket_Date)
  +
  convert(nvarchar(100),Ticket_Hour) as num,sum(sales_vat) as value
  --,*
  --into #orderNO_less0
  from [ODS_SAP].[Sales_Ticket] A
  join ODS_SAP.Dim_Material b
on a.Material_Code=b.Material_Code
where isnull(market_code,'')+isnull(target_code,'')+isnull(category_code,'')+isnull(sales_nature_code,'')+isnull(range_code,'')+isnull(nature_code,'')
 not in  (select ZMARCHE+ZCIBLE+ZRAYON+ZCOD_NATCA+ZGAMME+ZNATURE from ODS_SAP.DimSKu_filter c)
 and A.Material_Code <>'TRP001' and B.Material_Description not like  '%Gift Card%'
 --and left(Currency_code,2) in ('AU','NZ','HK','MY','SG','TH','CN')
 --and Ticket_date=20210101 and store_code=6200
  group by Store_Code,'66' +  convert(nvarchar(100),Store_Code)
  +
  convert(nvarchar(100),right(Till_Number,3))
  +
  convert(nvarchar(100),right(Transaction_Number,18))
  +
  convert(nvarchar(100),Ticket_Date)
  +
  convert(nvarchar(100),Ticket_Hour),Ticket_Date
  having sum(convert(float,sales_vat))<0
  ),
orderNO_over0 as(
 select  Ticket_Date,Store_Code,max(currency_code) as currency_code,'66' +  convert(nvarchar(100),Store_Code)
  +
  convert(nvarchar(100),right(Till_Number,3))
  +
  convert(nvarchar(100),right(Transaction_Number,18))
  +
  convert(nvarchar(100),Ticket_Date)
  +
  convert(nvarchar(100),Ticket_Hour) num,sum(sales_vat) as value
  --,*
  --into #orderNO_over0
  from [ODS_SAP].[Sales_Ticket] A
  join ODS_SAP.Dim_Material b
  on a.Material_Code=b.Material_Code
  where isnull(market_code,'')+isnull(target_code,'')+isnull(category_code,'')+isnull(sales_nature_code,'')+isnull(range_code,'')+isnull(nature_code,'')
 not in  (select ZMARCHE+ZCIBLE+ZRAYON+ZCOD_NATCA+ZGAMME+ZNATURE from ODS_SAP.DimSKu_filter c)
 and A.Material_Code <>'TRP001' and B.Material_Description not like  '%Gift Card%'
  --and left(Currency_code,2) in ('AU','NZ','HK','MY','SG','TH','CN')
 --and Ticket_date=20210101 and store_code=6200
  group by Store_Code,'66' +  convert(nvarchar(100),Store_Code)
  +
  convert(nvarchar(100),right(Till_Number,3))
  +
  convert(nvarchar(100),right(Transaction_Number,18))
  +
  convert(nvarchar(100),Ticket_Date)
  +
  convert(nvarchar(100),Ticket_Hour),Ticket_Date
  having sum(convert(float,sales_vat))>0
  ),
   Transactions_less0 as
  (
  select Ticket_Date,store_code,max(currency_code) as currency_code,count(1) as value,sum(value) as sales from orderNO_less0 group by store_code,Ticket_Date
  ),
  Transactions_over0  as
  (
  select Ticket_Date,store_code,max(currency_code) as currency_code,count(1) as value,sum(value) as sales from orderNO_over0 group by store_code,Ticket_Date
  ),
  Transactions as(
  select isnull(a.Ticket_Date,b.Ticket_Date) as Date_key,isnull(a.store_code,b.store_code)as store_code,
  isnull(a.value,0)-isnull(b.value,0) as [Transactions],
  isnull(a.sales,0)+isnull(b.sales,0) as [Sales_With_Tax],
  isnull(a.currency_code,b.currency_code) as currency_code
  from Transactions_over0 a 
  full join Transactions_less0 b on a.store_code=b.store_code and a.Ticket_Date=b.Ticket_Date
  )
  select 
  isnull([Date],b.Date_key) as [Date_Key]
  ,null as [Store_ID]
  ,isnull([Division],b.store_code) as [Store_Code]
  ,null as [Currency_ID]
  ,isnull([Devise locale],currency_code) as [Currency_Name]
  ,[Sales_With_Tax]
  ,[Vol.aff. - PV + TVA] as [Sales_Target]
  ,[Transactions]
  ,[CreateTime]
  ,[UpdateTime] as [LastUpdateTime]
  ,convert(bigint,convert(nvarchar(10),dateadd(hh,8,getdate()),112))*1000000 + 
  datepart(hour,dateadd(hh,8,getdate())) * 10000 +
  datepart(minute,dateadd(hh,8,getdate())) * 100 +
  datepart(second,dateadd(hh,8,getdate())) as [BatchNo]
  ,convert(decimal(18,5),convert(decimal(18,5),[Vol.aff. - PV + TVA])/[Taux]) as [Sales_Target_EUR]
  ,null as [Sales_Target_Current]
  from (select * from [ODS_ESB].[ESB_Store_Target] where left([Devise locale] ,2) in ('AU','NZ','HK','MY','SG','TH','CN') and [Date]>=20210101)  a
  full join Transactions b on a.[Date]=b.Date_key and b.[Store_Code]=a.[Division]
 

END
GO
