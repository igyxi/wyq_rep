/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Userinfo]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Userinfo] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_Ecard.GiftCard_Userinfo;
insert into STG_Ecard.GiftCard_Userinfo
select 
		id,
		case when trim(open_id) in ('', 'null', 'None') then null else trim(open_id) end as open_id,
		case when trim(passwd) in ('', 'null', 'None') then null else trim(passwd) end as passwd,
		create_time,
		update_time,
        [status],
		case when trim(phone) in ('','null', 'None') then null else trim(phone) end as phone,
		case when trim(member_id) in ('','null', 'None') then null else trim(member_id) end as member_id,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.GiftCard_Userinfo
) t
where rownum = 1
END
GO
