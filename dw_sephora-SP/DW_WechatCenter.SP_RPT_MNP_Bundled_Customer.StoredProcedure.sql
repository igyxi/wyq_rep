/****** Object:  StoredProcedure [DW_WechatCenter].[SP_RPT_MNP_Bundled_Customer]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_WechatCenter].[SP_RPT_MNP_Bundled_Customer] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-04       wangzhichun        Initial Version
-- 2023-06-19       Leozhai            change WechatCenter source to ODS
-- ========================================================================================
truncate table DW_WechatCenter.RPT_MNP_Bundled_Customer;
insert into DW_WechatCenter.RPT_MNP_Bundled_Customer
select
    t0.statistic_date,
    t0.mnp_bindled_users,
    t1.mnp_registered_users,
    t0.store_bindled_users,
    t1.store_registered_users,
    current_timestamp as insert_timestamp
from
    (
        select
             b.binddate as statistic_date,
             sum(case when a.registerstore in ('6997','6820','6830') then 1 else 0 end) as mnp_bindled_users,
             sum(case when a.registerstore not in ('6997','6820','6830') then 1 else 0 end) as store_bindled_users
        from
            (
                select 
                    openid,registerstore
                from 
				    [ODS_WechatCenter].[Wechat_Register_Info]
            ) a
        inner join
            (
                select 
                    openid,
                    convert(varchar(10),bindtime,120) as binddate

                from 
				    [ODS_WechatCenter].[Wechat_Bind_Mobile_List]
            ) b
        on 
            a.openid = b.openid
        group by 
            b.binddate
    )t0
    left join
    (
        select
            a.registerdate as statistic_date,
            count(distinct case when a.registerstore in ('6997','6820','6830') then b.openid else null end) as mnp_registered_users,
            count(distinct case when a.registerstore not in ('6997','6820','6830') then b.openid else null end) as store_registered_users
        from
            (
                select 
                    openid,registerstore,
                    convert(varchar(10),registertime,120) as registerdate
                from 
				    [ODS_WechatCenter].[Wechat_Register_Info]
            ) a
        inner join
            (
                select 
                    openid
                from 
				    [ODS_WechatCenter].[Wechat_Bind_Mobile_History]
                where
                    isnewregister=1
            ) b
        on 
            a.openid = b.openid
        group by 
            a.registerdate
    )t1
on
    t0.statistic_date = t1.statistic_date;
END
GO
