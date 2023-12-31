/****** Object:  StoredProcedure [DWD].[SP_Fact_Member_Third_Party_Bind]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Member_Third_Party_Bind] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-13       wangziming    Initial Version
-- ========================================================================================
truncate table DWD.Fact_Member_Third_Party_Bind;
with user_bind_store as (
select 
  *
from 
(
    select 
    *,
	row_number() over(partition by user_id,channel,store_name,store_id order by create_time desc,id desc) as rn
	from 
	ODS_User.User_Third_Party_Bind_Store
)a
where rn=1
)
insert into DWD.Fact_Member_Third_Party_Bind
select 
    a.id,
	a.store_name,
	a.store_id,
	a.ouid,
	a.omid,
	a.user_id,
	b.member_card,
	a.mobile,
	a.encrypt_mobile,
	a.channel,
	a.status,
	a.create_time,
	a.update_time,
	a.create_user,
	a.update_user,
	a.is_delete,
	current_timestamp as insert_timestamp
from 
user_bind_store a 
left join
(
    select 
	eb_user_id,
	member_card 
	from 
	DWD.DIM_Member_Info
	where eb_user_id is not null
) b on a.user_id=b.eb_user_id
END
GO
