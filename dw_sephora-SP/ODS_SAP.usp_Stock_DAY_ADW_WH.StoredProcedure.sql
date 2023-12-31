/****** Object:  StoredProcedure [ODS_SAP].[usp_Stock_DAY_ADW_WH]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SAP].[usp_Stock_DAY_ADW_WH] AS
BEGIN
   delete from ODS_SAP.Stock_Day_ADW_Warehouse
where convert(nvarchar(100),[Create_Date])+[Distribution_Center_Code]
in
(
select convert(nvarchar(100),stock.[Create_Date])+Stock.[Store_Code]
FROM ODS_SAP.Stock_Day_ADW stock
  where stock.create_Date>isnull((select Max(create_Date) FROM ODS_SAP.Stock_Day_ADW_Warehouse),0)
)

insert ODS_SAP.Stock_Day_ADW_Warehouse
(
[Country]
      ,[Distribution_Center_Code]
      ,[Storage_Location]
      ,[Material_Code]
      ,[Unit]
      ,[Stock_Qty]
      ,[Min_Target_Stock_Qty]
      ,[Max_Target_Stock_Qty]
      ,[Stock_Value]
      ,[Create_Date]
      ,[Create_Hour]
      ,[Moving_Price]
,[Path]
,[FileDatekey]
,[BatchNo]
)
SELECT 
stock.[Country]
      ,Stock.[Store_Code]
      ,stock.[Storage_Location]
      ,stock.[Material_Code]
      ,stock.[Unit]
      ,stock.[Stock_Qty]
      ,stock.[Min_Target_Stock_Qty]
      ,stock.[Max_Target_Stock_Qty]
      ,stock.[Stock_Value]
      ,stock.[Create_Date]
      ,stock.[Create_Hour]
      ,case when stock.[Stock_Qty] is null or stock.[Stock_Qty]=0 then null else stock.[Stock_Value]*1.0/stock.[Stock_Qty] end
,stock.[Path]
,stock.[FileDatekey]
,stock.[BatchNo]
  FROM ODS_SAP.Stock_Day_ADW stock
  where (isnumeric(stock.store_Code)=0  
  or (isnumeric(stock.store_Code)=1 and stock.store_Code<'1000'))
  and stock.create_Date>isnull((select Max(create_Date) FROM ODS_SAP.Stock_Day_ADW_Warehouse),0)
END
GO
