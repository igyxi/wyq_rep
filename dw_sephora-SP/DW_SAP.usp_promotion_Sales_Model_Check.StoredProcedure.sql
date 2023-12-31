/****** Object:  StoredProcedure [DW_SAP].[usp_promotion_Sales_Model_Check]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SAP].[usp_promotion_Sales_Model_Check] AS
Begin
select case when convert(date,max(RefreshTime))=convert(date,dateadd(hour,8,getdate())) then 'True' else 
'False' end as Result from  LOG.Tabular_Refresh_log
where tabular_name='SAP_Model' and Status='Succeeded'
and convert(date,dateadd(hour,-16,getdate())) in (select date from manual_sap.Promotion_Calendar)
end


GO
