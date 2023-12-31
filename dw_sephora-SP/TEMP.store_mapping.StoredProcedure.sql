/****** Object:  StoredProcedure [TEMP].[store_mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[store_mapping] AS
begin

select A.Storage,A.Material,DC
into #Store_MC_Mapping 
from
(
 select distinct A.Storage,A.Material,IsNull(A.Supply_Plant,A.Supplier) as DC,row_number() over (partition by A.Storage,A.Material order by A.Storage) as r
 from ODS_SAP.PO_Transfer_Order A 
 inner join
 (
  select Storage,Material,max(Creation_Date) as Creation_Date
  from ODS_SAP.PO_Transfer_Order 
  where Storage like '6%'  and filedatekey>= convert(nvarchar(255),dateadd(day,-3,getdate()),112)
  group by Storage,Material
 ) B on A.Storage = B.Storage and A.Material = B.Material and A.Creation_Date = B.Creation_Date
 where A.Storage like '6%'  and filedatekey>= convert(nvarchar(255),dateadd(day,-3,getdate()),112)
) A 
where r = 1

update a set a.DC=b.DC from temp.Store_Material_DC_Mapping  a join #Store_MC_Mapping b  on a.Storage=b.Storage and a.Material=b.Material
insert into temp.Store_Material_DC_Mapping select * from #Store_MC_Mapping a where not exists(select 1 from temp.Store_Material_DC_Mapping b where a.Storage=b.Storage and a.Material=b.Material)
drop table #Store_MC_Mapping




select A.Storage,DC
into #Store_C_Mapping
from
(
 select distinct A.Storage,IsNull(A.Supply_Plant,A.Supplier) as DC,row_number() over (partition by A.Storage order by A.Storage) as r
 from ODS_SAP.PO_Transfer_Order A 
 inner join
 (
  select Storage,max(Creation_Date) as Creation_Date
  from ODS_SAP.PO_Transfer_Order
  where Storage like '6%'  and filedatekey>= convert(nvarchar(255),dateadd(day,-3,getdate()),112)
  group by Storage
 ) B on A.Storage = B.Storage and A.Creation_Date = B.Creation_Date
 where A.Storage like '6%'  and filedatekey>= convert(nvarchar(255),dateadd(day,-3,getdate()),112)
) A 
where r = 1  

update a set a.DC=b.DC from temp.Store_DC_Mapping  a join #Store_C_Mapping b  on a.Storage=b.Storage
insert into temp.Store_DC_Mapping  select * from #Store_C_Mapping a where not exists(select 1 from temp.Store_DC_Mapping  b where  a.Storage=b.Storage)
drop table #Store_C_Mapping

end
GO
