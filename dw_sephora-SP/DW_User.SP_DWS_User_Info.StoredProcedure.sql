/****** Object:  StoredProcedure [DW_User].[SP_DWS_User_Info]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_User].[SP_DWS_User_Info] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-29       Leozhai        change user source to ODS
-- ========================================================================================
truncate table DW_User.DWS_User_Info ;
insert into DW_User.DWS_User_Info
select 
    a.user_id,
    b.registration as reigster_time,
    null as register_mobile,
    b.email as register_email, 
    c.card_no as card_no,
    --c.source as card_source,
    case 
        when trim(lower(c.source)) in ('null', '') then null 
        when c.source in ('Offline','offline') then 'Offline'
        else c.source
    end as card_source,
    c.join_time as card_join_time,
    c.bind_time as card_bind_time,
    b.last_login_time as last_login_time,
    a.gender as gender,
    a.dateofbirth as birthday,
    a.name as name,
    null as mobile,
    a.email as email,
    a.province as province,
    a.city as city,
    c.level as card_level,
    current_timestamp as insert_timestamp
from
    (select * from ODS_User.user_profile where user_id is not null) a
left join
    ODS_User.[user] b
on
    a.user_id = b.id
left join
    ODS_User.[card] c
on
    a.card_no=c.card_no;
update statistics DW_User.DWS_User_Info;
END


GO
