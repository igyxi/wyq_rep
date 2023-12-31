/****** Object:  StoredProcedure [DWD].[SP_Fact_Store_Traffic_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Store_Traffic_Detail] @dt [varchar](10) AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-18       weichen        Initial Version
-- ========================================================================================
DELETE FROM DWD.Fact_Store_Traffic_Detail WHERE date_key >= format(dateadd(Day,-11,cast(@dt as date)), 'yyyyMMdd');
INSERT INTO DWD.Fact_Store_Traffic_Detail
SELECT 
	a.Store_Code as store_code,
	a.Date_Key as date_key,
	a.Hour_Key as hour_key,
	case
		when b.sap_country_code= 'TH' then 'THB'
		when b.sap_country_code= 'CN' then 'CNY'
		when b.sap_country_code= 'AU' then 'AUD'
		when b.sap_country_code= 'MY' then 'MYR'
		when b.sap_country_code= 'SG' then 'SGD'
        when b.sap_country_code= 'NZ' then 'NZD'
		when b.sap_country_code= 'KR' then 'KRW'
		else 'CNY'
	end AS currency_name,
	a.Traffic as traffic,
	a.START_TIME as start_time,
	a.Update_Time as update_time,
	convert(bigint,convert(nvarchar(10),dateadd(hour,8,getUTCdate()),112))*1000000 + datepart(hour,dateadd(hour,8,getUTCdate())) * 10000 + datepart(minute,dateadd(hour,8,getUTCdate())) * 100 + datepart(second,dateadd(hour,8,getUTCdate())) as [Batch_No],
	'Traffic' as source,
	CURRENT_TIMESTAMP as insert_timestamp
FROM DW_Traffic.Fact_Traffic_ByMinute a
left join DWD.DIM_STORE b on a.Store_Code=b.store_code
WHERE a.Date_Key >= format(dateadd(Day,-11,cast(@dt as date)), 'yyyyMMdd')
	  AND  b.source='SAP'
;
END



GO
