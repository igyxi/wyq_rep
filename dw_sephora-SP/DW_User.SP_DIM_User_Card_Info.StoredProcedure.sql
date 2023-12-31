/****** Object:  StoredProcedure [DW_User].[SP_DIM_User_Card_Info]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_User].[SP_DIM_User_Card_Info] AS
BEGIN
truncate table DW_User.DIM_User_Card_Info;
insert into DW_User.DIM_User_Card_Info
select distinct
    a.user_id,
    a.card_no,
    current_timestamp as insert_timestamp
from
    [STG_User].[User_Profile] a
inner join 
    (
        select 
            distinct user_id
        from 
            ODS_VirtualArtist.Virtual_Artist
        where
            isnumeric(user_id)=1
     )b
on 
    a.user_id = b.user_id;
END
GO
