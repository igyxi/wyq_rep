/****** Object:  StoredProcedure [STG_Transcosmos].[TRANS_Seat_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Transcosmos].[TRANS_Seat_Info] @dt [VARCHAR](10) AS
BEGIN
truncate table [STG_TRANSCOSMOS].[seat_info];
insert into [STG_TRANSCOSMOS].[seat_info]
select 
    case when trim(lower(seat_account)) in ('','null') then null else trim(seat_account) end as seat_account,
    case when trim(lower(seat_name)) in ('','null') then null else trim(seat_name) end as seat_name,
    case when trim(lower(seat_vendors)) in ('','null') then null else trim(seat_vendors) end as seat_vendors,
    current_timestamp as insert_timestamp
from 
    ods_transcosmos.seat_info
where 
    dt = @dt;
END
GO
