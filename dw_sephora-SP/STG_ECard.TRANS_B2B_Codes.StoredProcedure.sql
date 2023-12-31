/****** Object:  StoredProcedure [STG_ECard].[TRANS_B2B_Codes]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_B2B_Codes] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-28       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_ECard.B2B_Codes;
insert into STG_ECard.B2B_Codes
select 
		id,
		case when trim(orderno) in ('','null') then null else trim(orderno) end as orderno,
		case when trim(pre_orderno) in ('','null') then null else trim(pre_orderno) end as pre_orderno,
		case when trim(card_id) in ('','null') then null else trim(card_id) end as card_id,
		case when trim(code) in ('','null') then null else trim(code) end as code,
		case when trim(code_no) in ('','null') then null else trim(code_no) end as code_no,
		case when trim(mobile) in ('','null') then null else trim(mobile) end as mobile,
		case when trim(openid) in ('','null') then null else trim(openid) end as openid,
		price,
		case when trim(fuiou_code_no) in ('','null') then null else trim(fuiou_code_no) end as fuiou_code_no,
		case when trim(fuiou_code_pwd) in ('','null') then null else trim(fuiou_code_pwd) end as fuiou_code_pwd,
		case when trim(fuiou_orderno) in ('','null') then null else trim(fuiou_orderno) end as fuiou_orderno,
        [type],
        [status],
		ticket_status,
		create_time,
		update_time,
		get_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_ECard.B2B_Codes
) t
where rownum = 1
END
GO
