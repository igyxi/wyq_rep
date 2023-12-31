/****** Object:  StoredProcedure [ODS_POS].[ups_TLOG_Operation_Delete]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_POS].[ups_TLOG_Operation_Delete] AS
	IF Object_id('tempdb..#DELETE_CANDIDATES') IS NOT NULL
	DROP TABLE #delete_candidates

	select 'delete a from '+sch.name+'.'+tb.name +' a where exists (select 1 from ODS_POS.TLOG_Operation_Delete b where b.szBarcodeComplete=a.szBarcodeComplete)
	' as delete_sql into #delete_candidates
	from sys.tables tb 
	join sys.schemas sch on tb.schema_Id=sch.Schema_id
	join sys.columns col on col.object_id=tb.Object_id
	where col.name='szBarcodeComplete' and sch.name='ODS_POS'
	and tb.name<>'TLOG_Operation_Delete'
	

	DECLARE @total int = (select count(1) from #delete_candidates)
	DECLARE @i int = 1
	DECLARE @Concat_sql NVARCHAR(max)= ''
	DECLARE @delete_sql NVARCHAR(max);
	WHILE (@i <= @total)  
	BEGIN
		select @delete_sql=delete_sql from #delete_candidates
		--exec (@delete_sql)
		delete  from #delete_candidates where delete_sql=@delete_sql
		set @Concat_sql+=@delete_sql
		SET @i+=1
	END
	print @Concat_sql
	exec (@Concat_sql)
GO
