/****** Object:  StoredProcedure [ODS_SAP].[usp_Stock_DAY_ADW_WH_Transit]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SAP].[usp_Stock_DAY_ADW_WH_Transit] AS
BEGIN
declare @CreateDate int;
select @CreateDate=max(Create_Date) from ODS_SAP.Stock_Day_ADW_Warehouse where Storage_Location!='TRAN';

with Transit as(
select 
Storage
,Material
,max(Order_Unit) as Unit
,Max(Country) as Country
,abs(sum(Transit_Quantity)) as Transit_Quantity
, abs(sum(Transit_value)) as Transit_Value
--,abs(sum(Transit_Value)) as Transit_Value
from
(select 
-- a.Order_Number
-- ,a.[Storage_Location]
a.Storage
,a.material
,b.Order_Unit
,Left(a.Company_Code,2) as Country
-- ,a.[Creation_Date]
,(case when b.[History_Category]='U' then abs(b.Quantity)
  when b.[History_Category]='E' then abs(b.Quantity)*-1 
  end)*
abs(case when a.Order_Quantity is null or a.Order_Quantity=0 then null 
else a.Order_Amount/a.Order_Quantity end) as Transit_Value
--E收货 U发货
--发货绝对值减收货绝对值
,case when b.[History_Category]='U' then abs(b.Quantity)
  when b.[History_Category]='E' then abs(b.Quantity)*-1 
  end as Transit_Quantity
from [ODS_SAP].[PO_Transfer_Order] a
inner join [ODS_SAP].PO_Order_History b
on a.[Order_Number] = b.[Order_Number]
and convert(int,a.[Item])=convert(int, b.[Item])
where --a.[Creation_Date] >=20191101-->='2020-11-20' and a.[Creation_Date]<'2020-11-21' -- 如果数据量大可以限制到比如一年内
 a.[Final_Delivery] is null
 and b.[History_Category] in ('U','E')
 and (isnumeric(a.Storage)=0  
  or (isnumeric(a.Storage)=1 and a.Storage<'1000'))
 and b.Accounting_date<=(select Max(create_Date) FROM ODS_SAP.Stock_Day_ADW_Warehouse)
 -- and exists (select 1 from [ODS_SAP].[Stock_Day_ADW] stock where
 -- a.Storage=stock.[Store_Code] and a.Material=stock.Material_Code and stock.Create_Date
 -- >(select Max(create_Date) FROM ODS_SAP.Stock_Day_ADW_Warehouse where Storage_Location='TRAN')
 -- )
--and left(a.Order_Type,3) not in ('ZFR','ZXR')
--and Storage='6116'
union
select 
-- a.Order_Number
-- ,a.[Storage_Location]
a.Storage
,a.material
,b.Order_Unit
,Left(a.[Company Code],2) as Country
-- ,a.[Creation_Date]
,(case when b.[History_Category]='U' then abs(b.Quantity)
  when b.[History_Category]='E' then abs(b.Quantity)*-1 
  end)*
abs(case when a.Order_Quantity is null or a.Order_Quantity=0 then null 
else a.Order_Amount/a.Order_Quantity end) as Transit_Value
--E收货 U发货
--发货绝对值减收货绝对值
,case when b.[History_Category]='U' then abs(b.Quantity)
  when b.[History_Category]='E' then abs(b.Quantity)*-1 
  end as Transit_Quantity
from [ODS_SAP].[PO_header_post] a
inner join [ODS_SAP].PO_Order_History b
on a.[Order_Number] = b.[Order_Number]
and convert(int,a.[Item]) =convert(int, b.[Item])
where --a.[Creation_Date] >=20191101-->='2020-11-20' and a.[Creation_Date]<'2020-11-21' -- 如果数据量大可以限制到比如一年内
 a.[Final_Delivery] is null
 and b.[History_Category] in ('U','E')
 and (isnumeric(a.Storage)=0  
  or (isnumeric(a.Storage)=1 and a.Storage<'1000'))
 and b.Accounting_date<=(select Max(create_Date) FROM ODS_SAP.Stock_Day_ADW_Warehouse)
 -- and exists (select 1 from [ODS_SAP].[Stock_Day_ADW] stock where
 -- a.Storage=stock.[Store_Code] and a.Material=stock.Material_Code and stock.Create_Date
 -- >(select Max(create_Date) FROM ODS_SAP.Stock_Day_ADW_Warehouse where Storage_Location='TRAN')
 -- )
--and left(a.Order_Type,3) not in ('ZFR','ZXR')
--and Storage='6116'
)
 T
group by 
Storage
,Material
having abs(sum(Transit_Quantity))<>0
)

insert ODS_SAP.Stock_Day_ADW_Warehouse
(
[Country]
      ,[Distribution_Center_Code]
      ,[Storage_Location]
      ,[Material_Code]
      ,[Unit]
      ,[Stock_Qty]
      ,[Stock_Value]
      ,[Create_Date]
      ,[Moving_Price]
)
SELECT 
Transit.[Country]
      ,Transit.Storage
      ,'TRAN' as Storage_Location
      ,Transit.Material
      ,Transit.[Unit]
      ,Transit.[Transit_Quantity] as Stock_Qty
      ,Transit.[Transit_Value] as Stock_Value
      ,Create_Date=@CreateDate
      ,case when Transit.[Transit_Quantity] is null or Transit.[Transit_Quantity]=0 then null else Transit.[Transit_Value]*1.0/Transit.[Transit_Quantity] end
  FROM Transit 
  where not exists (select 1 FROM ODS_SAP.Stock_Day_ADW_Warehouse where Storage_Location='TRAN' having max(Create_Date)=@CreateDate) 

END
GO
