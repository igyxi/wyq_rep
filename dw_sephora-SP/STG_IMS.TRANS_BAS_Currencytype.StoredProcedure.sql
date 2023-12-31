/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Currencytype]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Currencytype] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By            Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-16       wangzhichun           Initial Version
-- 2022-09-28       wubin                 update data_create_time/data_update_time
-- 2022-12-15       wangzhichun           change schema
-- ========================================================================================
truncate table STG_IMS.BAS_Currencytype;
insert into STG_IMS.BAS_Currencytype
select 
		id,
		case when trim(code) in ('','null') then null else trim(code) end as code,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(disable_by) in ('','null') then null else trim(disable_by) end as disable_by,
		local_currency,
		case when trim(modify_by) in ('','null') then null else trim(modify_by) end as modify_by,
		amount_precision,
		case when trim(coincode) in ('','null') then null else trim(coincode) end as coincode,
		case when trim(currency_name) in ('','null') then null else trim(currency_name) end as currency_name,
		modify_time,
		case when trim(currency_code) in ('','null') then null else trim(currency_code) end as currency_code,
		case when trim(round_type) in ('','null') then null else trim(round_type) end as round_type,
		discount_precision,
		disable_date,
		case when trim(status) in ('','null') then null else trim(status) end as status,
		create_channel_id,
		case when trim(create_by) in ('','null') then null else trim(create_by) end as create_by,
		unitprice_precision,
		enable_date,
		create_time,
		case when trim(enable_by) in ('','null') then null else trim(enable_by) end as enable_by,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from    
    ODS_IMS.BAS_Currencytype
where 
    dt = @dt
END
GO
