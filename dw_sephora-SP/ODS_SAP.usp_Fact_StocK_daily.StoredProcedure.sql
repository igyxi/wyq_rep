/****** Object:  StoredProcedure [ODS_SAP].[usp_Fact_StocK_daily]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SAP].[usp_Fact_StocK_daily] AS
BEGIN
declare @maxCreateDate int;
select @maxCreateDate=max(date_key) from  [DW_SAP].[Fact_Stock_Daily] ;
if not exists(
select top 1 1 from [DW_SAP].[Fact_Stock_Daily] where Date_Key=(select max(create_date) from  [ODS_SAP].[Stock_Day_ADW] ) 
 )

with 
-- stock_mvt as(
    -- select  Material,
    -- Creation_Date,
    -- Plant,
    -- sum(case when Movement_Type in('102','304','306','642','644') then 0-Quantity else Quantity end ) as Transit_Stock,
    -- sum(case when Movement_Type in ('102','304','306','642','644') then 0-Amount else Amount end) as Transit_Value
    -- from [ODS_SAP].[Fact_Stock_Mvt]
    -- where Movement_Type in ('101','102','303','304','305','306','641','642','643','644')
    -- group by Material,Creation_Date,Plant
-- ),
Transit as(
select 
Storage
,Material
,abs(sum(Transit_Quantity)) as Transit_Quantity
, abs(sum(Transit_value)) as Transit_Value
--,abs(sum(Transit_Value)) as Transit_Value
from
(
select 
-- a.Order_Number
-- ,a.[Storage_Location]
a.Storage
,a.material
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
and a.[Item] = b.[Item]
where --a.[Creation_Date] >=20191101-->='2020-11-20' and a.[Creation_Date]<'2020-11-21' -- 如果数据量大可以限制到比如一年内
 a.[Final_Delivery] is null
 and b.[History_Category] in ('U','E')
 and exists (select 1 from [ODS_SAP].[Stock_Day_ADW] stock where
 a.Storage=stock.Store_Code and a.Material=stock.Material_Code and stock.Create_Date>@maxCreateDate)
--and left(a.Order_Type,3) not in ('ZFR','ZXR')
--and Storage='6116'
) T
group by 
Storage
,Material),
PTO as
( select 
 [Material],Storage,[Creation_Date],
 sum([Order_Quantity]) as [Order_Quantity],
 sum([Order_Amount]) as [Order_Amount] 
 from [ODS_SAP].[PO_Transfer_Order]
 group by [Material],Storage,[Creation_Date]
 ),
 matstu as (
 select  max(Purchase_Status) as Purchase_Status,
 max(Sales_Status) as Sales_Status,
 Country_Key,
 Material,
 max(Vendor) as Vendor
 from
 [ODS_SAP].[Material_Status]
 group by Country_Key,Material
 )
insert into [DW_SAP].[Fact_Stock_Daily]
(
[Country]
      ,[Store_Code]
      ,[Storage_Location]
      ,[Material_Code]
      ,[Unit]
      ,[Stock_Qty]
      ,[Min_Target_Stock_Qty]
      ,[Min_Target_Stock_Value]
      ,[Max_Target_Stock_Qty]
      ,[Max_Target_Stock_Value]
      ,[Stock_Value]
      ,[Date_Key]
      ,[Create_Hour]
      ,[Category_Short_Desc]
      ,[Material_Description]
      ,[Material_Vendor]
      ,[Material_Purchase_Status]
      ,[Material_Sales_Status]
      ,[Transit_Stock]
      ,[Transit_Value]
      ,[PO_Order_Quantity]
      ,[PO_Order_Value]
      ,[Create_TIme]
      )
  SELECT
      [Country]
      ,[Store_Code]
      ,stock.[Storage_Location]
      ,stock.[Material_Code]
      ,[Unit]
      ,[Stock_Qty]
      ,[Min_Target_Stock_Qty]
	    ,case when [Stock_Qty]=0 or [Stock_Qty] is null
		then null else  ([Stock_Value]/[Stock_Qty])*[Min_Target_Stock_Qty]*1.0 end
		as Min_Target_Stock_Value
      ,[Max_Target_Stock_Qty]
	    ,case when [Stock_Qty]=0 or [Stock_Qty] is null
		then null else ([Stock_Value]/[Stock_Qty])*[Max_Target_Stock_Qty]*1.0 end as
		Max_Target_Stock_Value
      ,[Stock_Value]
      ,[Date_Key]=[Create_Date]
      ,[Create_Hour]
	    ,[Category_Description] as [Category_Short_Desc]
	    ,Material.[Material_Description]
	    ,matstu.[Vendor] as [Material_Vendor]
	    ,matstu.[Purchase_Status] as [Material_Purchase_Status]
	  ,matstu.[Sales_Status] as [Material_Sales_Status]
      ,Transit.[Transit_Quantity] as [Transit_Stock]
      ,Transit.[Transit_Value] as [Transit_Value]
      ,pto.[Order_Quantity] as [PO_Order_Quantity]
      ,pto.[Order_Amount] as [PO_Order_Value]
      ,getdate() as [Create_TIme]
  FROM [ODS_SAP].[Stock_Day_ADW] stock
  left join [ODS_SAP].[Dim_Material] Material on stock.[Material_Code]=Material.[Material_Code]
  left join   matstu on matstu.[Country_Key]=stock.[Country] and matstu.[Material]=stock.[Material_Code]
  left join  Transit on Transit.Storage=stock.Store_Code and Transit.Material=stock.Material_Code
  -- left join  stock_mvt on stock.[Material_Code]=stock_mvt.[Material] and stock.[Create_Date]=stock_mvt.[Creation_Date] and stock.[Store_Code]=stock_mvt.[Plant]
  left join  PTO on stock.[Material_Code]=PTO.[Material] and stock.[Store_Code]=pto.Storage and stock.Create_Date=pto.[Creation_Date]
 where isnumeric(stock.store_Code)=1 and stock.store_Code>='1000'  and stock.Create_Date>@maxCreateDate

END
GO
