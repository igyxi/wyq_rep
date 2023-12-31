/****** Object:  StoredProcedure [TEMP].[SP_DWS_Wechat_User_Info_Bak_20230620]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Wechat_User_Info_Bak_20230620] AS 
BEGIN
truncate table DW_WechatCenter.DWS_Wechat_User_Info;
insert into DW_WechatCenter.DWS_Wechat_User_Info
select 
    a.openid,
    a.unionid,
    a.registertime as register_time,
    a.registerchannel,
    a.registersubchannel,
    a.registerstore,
    a.lastaccesstime,
    null mobile,
    t.bindtime as mobile_bind_time,
    t.isactive,
    t.userid,
    t.register_time as user_register_time,
    t.card_no,
    t.card_level,
    null as card_register_time,
    d.employeecode as first_ba_account,
    d.bindingtime as first_ba_bind_time,
    d.storecode as first_ba_store_cd,
    d.region as first_ba_region,
    d.district as first_ba_district,
    d.city as first_ba_city,
    current_timestamp as insert_timestamp
from
(
    select 
        unionid,openid,registertime,registerchannel,registersubchannel,registerstore,lastaccesstime
    from 
        STG_WechatCenter.wechat_register_info
    where 
        registerchannel = 'SEPHORA'
    and openid is not null
) a
left join
(
    select 
        b.openid,
        b.isactive,
        b.userid,
        b.bindtime,
        c.register_time,
        c.card_no,
        c.card_level
    from 
    (
        select 
            openid,mobile,userid,isactive,bindtime
        from 
            STG_WechatCenter.wechat_bind_mobile_list
    ) b
    left join
    (
        select user_id, register_time, card_no, card_level from DW_User.DWS_User_Info
    ) c
    on b.userid = c.user_id
) t
on a.openid = t.openid
left join
(
    select *, row_number() over(partition by unionid order by bindingtime) rn from DW_SmartBA.DWS_BA_Customer_REL
) d
on a.unionid = d.unionid
and d.rn = 1
end


GO
