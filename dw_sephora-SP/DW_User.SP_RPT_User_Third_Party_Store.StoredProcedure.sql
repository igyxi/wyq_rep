/****** Object:  StoredProcedure [DW_User].[SP_RPT_User_Third_Party_Store]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_User].[SP_RPT_User_Third_Party_Store] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-06-20       tali           update the DWD.DIM_Member_Card_Grade_SCD
-- 2022-07-04       tali           change table to rpt
-- 2023-05-29       Leozhai        change user source to ODS
-- ========================================================================================
truncate table DW_User.RPT_User_Third_Party_Store;
insert into DW_User.RPT_User_Third_Party_Store
select 
    a.id,
    a.user_id,
    t.card_no as member_card,
    t.card_level as current_member_card_grade,
    t.card_type_name as bind_member_card_grade,
    a.type,
    a.union_id,
    a.channel,
    a.nick_name,
    a.photo,
    a.age,
    a.last_login_time,
    a.bind_time,
    a.update_time,
    a.status,
    a.create_time,
    a.create_user,
    a.update_user,
    current_timestamp as insert_timestamp
from
    ODS_User.User_Third_Party_Store a
left join
(
    select
        b.user_id, 
        b.card_no, 
        b.card_level, 
        c.card_type_name, 
        format(c.start_time, 'yyyy-MM-dd HH:mm:ss') as start_time, 
        format(c.end_time, 'yyyy-MM-dd HH:mm:ss') as end_time
    from
    (
        select * FROM DWD.DIM_Member_Card_Grade_SCD where end_time > start_time
    ) c
    join
    (
        select user_id, card_no, card_level from DW_User.DWS_User_Info where card_no is not null
    ) b
    on c.member_card = b.card_no
) t
on a.user_id = t.user_id
and a.bind_time between t.start_time and t.end_time
END


GO
