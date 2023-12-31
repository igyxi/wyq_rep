/****** Object:  StoredProcedure [ODS_SAP].[usp_Fact_DepreciationData_Upt]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SAP].[usp_Fact_DepreciationData_Upt] AS

---修改逻辑:以前是通过FileName做关联，现在修改成Month+Calc  perimeter+Material   作为联合主健进行增量
DELETE FROM ODS_SAP.[Fact_DepreciationData]
       FROM ODS_SAP.[Fact_DepreciationData] AS FCT_DepreciationData
	   INNER JOIN STG_SAP.DepreciationData AS  STG_DepreciationData 
	   ON STG_DepreciationData.Month=FCT_DepreciationData.Month
	   AND cast(STG_DepreciationData.Material as int) = FCT_DepreciationData.Material --AND STG_DepreciationData.Material=FCT_DepreciationData.Material
	   AND STG_DepreciationData.[Calc  perimeter]=FCT_DepreciationData.[Calc  perimeter]
INSERT  INTO  ODS_SAP.[Fact_DepreciationData]
           ([Month]
           ,[Calc  perimeter]
           ,[Material]
           ,[Description]
           ,[Market]
           ,[Department]
           ,[Categ]
           ,[Brand]
           ,[Brand name]
           ,[Sub-brand]
           ,[Sub brand name]
           ,[Vendor]
           ,[Supplier name]
           ,[Company S L nb]
           ,[P-S matl status]
           ,[Valid_from]
           ,[DChain-spec ]
           ,[Valid from]
           ,[First entry date]
           ,[End life date]
           ,[New material]
           ,[None Recent noveltie]
           ,[X]
           ,[ProvSc]
           ,[Currency]
           ,[SaleWeight Factor]
           ,[YED rate]
           ,[Quantity]
           ,[Gross value]
           ,[Net value]
           ,[Stock Plant + 1 year]
           ,[Sales Plant + 1year]
           ,[Qty (new stores)]
           ,[Gr  val  new stores]
           ,[Net val (new stores)]
           ,[Breakage qty]
           ,[Breakage gross val ]
           ,[Breakage net value]
           ,[Sold quantity]
           ,[Sold qty stores]
           ,[Pltf exit qty]
           ,[Consumption qty]
           ,[Prov  amount ex bk ]
           ,[Break prov amount]
           ,[Residual stock qty]
           ,[Gross val  residual]
           ,[Residual rate]
           ,[Exit mth of new m ]
           ,[New mat  exit qty]
           ,[Rng  term  dep ]
           ,[St  Category Scale]
           ,[Dep  Category Scale]
           ,[Tx Deprec Moyen%]
           ,[Dep  Non  Rec  Novel]
           ,[Company10]
           ,[Company11]
           ,[Company12]
           ,[BatchNo]
           ,[Filename]
           ,[Month_Calc_perimeter]
           ,[CreatedUser]
           ,[CreatedTime]
           ,[UpdatedUser]
           ,[UpdatedTime]
           ,[ActionType]
           ,[ActionTime]
		   )
SELECT [Month]
      ,[Calc  perimeter]
      ,convert(NVARCHAR,convert(int,[Material])) AS [Material]
      ,[Description]
      ,[Market]
      ,[Department]
      ,[Categ]
      ,[Brand]
      ,[Brand name]
      ,[Sub-brand]
      ,[Sub brand name]
      ,[Vendor]
      ,[Supplier name]
      ,[Company S L nb]
      ,[P-S matl status]
      ,right([Valid_from],4)+'/'+LEFT(RIGHT([Valid_from],7),2)+'/'+LEFT([Valid_from],2) AS  [Valid_from]
      ,[DChain-spec ]
      ,right([Valid from],4)+'/'+LEFT(RIGHT([Valid from],7),2)+'/'+LEFT([Valid from],2)  AS  [Valid from]
      ,right([First entry date],4)+'/'+LEFT(RIGHT([First entry date],7),2)+'/'+LEFT([First entry date],2)  AS  [First entry date]
      ,right([End life date],4)+'/'+LEFT(RIGHT([End life date],7),2)+'/'+LEFT([End life date],2) AS  [End life date]
      ,[New material]
      ,[None Recent noveltie]
      ,[X]
      ,[ProvSc]
      ,[Currency]
      ,CONVERT(float, REPLACE(isnull([SaleWeight Factor],0),',','.')) AS [SaleWeight Factor]
      ,CONVERT(float,REPLACE(isnull([YED rate],0),',','.')) AS [YED rate]
      ,CONVERT(float,REPLACE(isnull([Quantity],0),',','.')) AS  [Quantity]
      ,CONVERT(float,REPLACE(isnull([Gross value],0),',','.')) AS  [Gross value]
      ,CONVERT(float,REPLACE(isnull([Net value],0),',','.')) AS  [Net value]
      ,CONVERT(float,REPLACE(isnull([Stock Plant + 1 year],0),',','.')) AS  [Stock Plant + 1 year]
      ,CONVERT(float,REPLACE(isnull([Sales Plant + 1year],0),',','.')) AS  [Sales Plant + 1year]
      ,CONVERT(float,REPLACE(isnull([Qty (new stores)],0),',','.')) AS [Qty (new stores)]
      ,CONVERT(float,REPLACE(isnull([Gr  val  new stores],0),',','.')) AS [Gr  val  new stores]
      ,CONVERT(float,REPLACE(isnull([Net val (new stores)],0),',','.')) AS  [Net val (new stores)]
      ,CONVERT(float,REPLACE(isnull([Breakage qty],0),',','.')) AS  [Breakage qty]
      ,CONVERT(float,REPLACE(isnull([Breakage gross val ],0),',','.')) AS  [Breakage gross val ]
      ,CONVERT(float,REPLACE(isnull([Breakage net value],0),',','.')) AS  [Breakage net value]
      ,CONVERT(float,REPLACE(isnull([Sold quantity],0),',','.')) AS  [Sold quantity]
      ,CONVERT(float,REPLACE(isnull([Sold qty stores],0),',','.')) AS  [Sold qty stores]
      ,CONVERT(float,REPLACE(isnull([Pltf exit qty],0),',','.')) AS [Pltf exit qty]
      ,CONVERT(float,REPLACE(isnull([Consumption qty],0),',','.')) AS  [Consumption qty]
      ,CONVERT(float,REPLACE(isnull([Prov  amount ex bk ],0),',','.')) AS  [Prov  amount ex bk ]
      ,CONVERT(float,REPLACE(isnull([Break prov amount],0),',','.')) AS  [Break prov amount]
      ,CONVERT(float,REPLACE(isnull([Residual stock qty],0),',','.')) AS  [Residual stock qty]
      ,CONVERT(float,REPLACE(isnull([Gross val  residual],0),',','.')) AS  [Gross val  residual]
      ,CONVERT(float,REPLACE(isnull([Residual rate],0),',','.')) AS  [Residual rate]
      ,CONVERT(float,REPLACE(isnull([Exit mth of new m ],0),',','.')) AS  [Exit mth of new m ]
      ,CONVERT(float,REPLACE(isnull([New mat  exit qty],0),',','.')) AS  [New mat  exit qty]
      ,CONVERT(float,REPLACE(isnull([Rng  term  dep ],0),',','.')) AS  [Rng  term  dep ]
      ,CONVERT(float,REPLACE(isnull([St  Category Scale],0),',','.')) AS  [St  Category Scale]
      ,CONVERT(float,REPLACE(isnull([Dep  Category Scale],0),',','.')) AS  [Dep  Category Scale]
      ,CONVERT(float,REPLACE(isnull([Tx Dépréc  Moyen %],0),',','.')) AS  [Tx Deprec Moyen%]
      ,CONVERT(float,REPLACE(isnull([Dep  Non  Rec  Novel],0),',','.')) AS  [Dep  Non  Rec  Novel]
      ,CONVERT(float,case when charindex(Nchar(9),[Company10])>0 then left(REPLACE(isnull([Company10],0),',','.'),charindex(Nchar(9),[Company10])-1) 
else REPLACE(isnull([Company10],0),',','.') end) AS  [Company10]
      ,CONVERT(float,REPLACE(isnull([Company11],0),',','.')) AS  [Company11]
      ,CONVERT(float,REPLACE(isnull([Company12],0),',','.')) AS  [Company12]
      ,[BatchNo]
      ,[Filename]
      ,[Month_Calc_perimeter]
	  ,N'Fisksoft BI' AS [CreatedUser]
	  ,GETDATE() AS [CreatedTime]
	  ,N'Fisksoft BI' AS [UpdatedUser]
	  ,GETDATE() AS [UpdatedTime]
	  ,N'I' AS [ActionType]
	  ,GETDATE() AS [ActionTime]
  FROM STG_SAP.[DepreciationData]



 SELECT  MONTH, Material,[Calc  perimeter] ,MAX(ID)  AS Max_ID
 INTO #CCC
  FROM    ODS_SAP.[Fact_DepreciationData] 
  where Month >= (select MIN(Month)from STG_SAP.[DepreciationData]) 
 GROUP BY  MONTH, Material,[Calc  perimeter]
 having count(1)>1


  delete from ODS_SAP.[Fact_DepreciationData] 
  where exists(select 1 from #CCC where ODS_SAP.[Fact_DepreciationData].MONTH = #CCC.Month and 
	ODS_SAP.[Fact_DepreciationData].Material =#CCC.Material and 
	ODS_SAP.[Fact_DepreciationData].[Calc  perimeter] = #CCC.[Calc  perimeter] and 
	ODS_SAP.[Fact_DepreciationData].ID <> #CCC.Max_ID)

	 drop table #CCC




GO
