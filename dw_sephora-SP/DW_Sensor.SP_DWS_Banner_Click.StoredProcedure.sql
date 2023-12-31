/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Banner_Click]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Banner_Click] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-23       wangzhichun    Initial Version
-- 2022-11-09       wangzhichun    update PLATFORM_TYPE & PAGE_ID
-- ========================================================================================
delete from DW_Sensor.DWS_Banner_Click where [date] = @dt;
insert into DW_Sensor.DWS_Banner_Click
--创建运营位表
select
    a.date,  --日期
    case when upper(a.platform_type) = 'APP' then 'APP'
        when upper(a.platform_type) = 'MINIPROGRAM' then 'MNP'
        else upper(a.platform_type) end as PLATFORM_TYPE,                   --平台类型
    a.vip_card_type,  --会员卡类型
    case when a.page_id in ('APP_1000001','MP_1000001') then '1000001' 
        end as PAGE_ID,  --页面编号
    a.action_id,  --操作编号
    case when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'精选' then concat('select',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'护肤' then concat('SK',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'彩妆' then concat('MU',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'香水' then concat('FR',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'小众' then concat('EX',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'个护' then concat('PC',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'男士' then concat('ME',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area = 'Select_ Board' then 'Select_Board'
        when a.banner_belong_area = 'ME_AdBanner1' then 'ME_Ad Banner1'
        when a.banner_belong_area = 'Select_Guess U Like_Guess U Like' then 'Select_Guess U Like'
        when a.banner_belong_area = 'PC_AdBanner1' then 'PC_Ad Banner1'
        when a.banner_belong_area = 'Select_ Beauty Channel' then 'Select_Beauty Channel'
        when a.banner_belong_area = 'EX_AdBanner1' then 'EX_Ad Banner1'
        when a.banner_belong_area = 'Select_ Icon' then 'Select_Icon'
        when a.banner_belong_area = 'SK_AdBanner1' then 'SK_Ad Banner1'
        when a.banner_belong_area = 'MU_AdBanner1' then 'MU_Ad Banner1'
        when a.banner_belong_area = 'FR_AdBanner1' then 'FR_Ad Banner1'
        when a.banner_belong_area = 'Select_ Sephora Picks - Products' then 'Select_Sephora Picks_Products'
        when a.banner_belong_area = 'Select_ All Brand' then 'Select_All Brand'
        when a.banner_belong_area = 'Select_ Sephora Picks - Banner' then 'Select_Sephora Picks_Banner'
        when a.banner_belong_area = '''Top Navigation' then 'Top Navigation'
        when a.banner_belong_area = 'Select_ Sephora Picks_ Title' then 'Select_Sephora Picks_Title'
        else a.banner_belong_area
        end as banner_belong_area,  --运营位所在版区
    a.banner_content,  --运营位内容
    a.ss_element_position,  --元素位置
    a.banner_current_url,  --运营位所在页面地址
    a.banner_to_url,  --运营位跳转url地址
    a.banner_ranking,  --排序
    a.campaign_code,  --运营活动编号
    a.op_code,  --产品id
    a.commodity_sku,  --货号
    count(1) as Click, --点击数
    current_timestamp,
    dt
from 
    STG_Sensor.Events a
where 
    a.date = @dt 
and 
    a.page_id IN ('APP_1000001','MP_1000001')
and  
    a.action_id != '1000001_000'
and  
    a.platform_type in ('app','App','MiniProgram')
group by 
    a.date,  --日期
    case when upper(a.platform_type) = 'APP' then 'APP'
        when upper(a.platform_type) = 'MINIPROGRAM' then 'MNP'
        else upper(a.platform_type) end,                   --平台类型
    a.vip_card_type,  --会员卡类型
    case when a.page_id in ('APP_1000001','MP_1000001') then '1000001' 
        end,  --页面编号
    a.action_id,  --操作编号
    case when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'精选' then concat('select',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'护肤' then concat('SK',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'彩妆' then concat('MU',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'香水' then concat('FR',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'小众' then concat('EX',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'个护' then concat('PC',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area in ('_Ranking','_Hero','_Guess U Like','_Brand Wall','_All Brand','_Ad Banner1') and a.ss_element_position = N'男士' then concat('ME',a.banner_belong_area COLLATE SQL_Latin1_General_CP1_CI_AS)
        when a.banner_belong_area = 'Select_ Board' then 'Select_Board'
        when a.banner_belong_area = 'ME_AdBanner1' then 'ME_Ad Banner1'
        when a.banner_belong_area = 'Select_Guess U Like_Guess U Like' then 'Select_Guess U Like'
        when a.banner_belong_area = 'PC_AdBanner1' then 'PC_Ad Banner1'
        when a.banner_belong_area = 'Select_ Beauty Channel' then 'Select_Beauty Channel'
        when a.banner_belong_area = 'EX_AdBanner1' then 'EX_Ad Banner1'
        when a.banner_belong_area = 'Select_ Icon' then 'Select_Icon'
        when a.banner_belong_area = 'SK_AdBanner1' then 'SK_Ad Banner1'
        when a.banner_belong_area = 'MU_AdBanner1' then 'MU_Ad Banner1'
        when a.banner_belong_area = 'FR_AdBanner1' then 'FR_Ad Banner1'
        when a.banner_belong_area = 'Select_ Sephora Picks - Products' then 'Select_Sephora Picks_Products'
        when a.banner_belong_area = 'Select_ All Brand' then 'Select_All Brand'
        when a.banner_belong_area = 'Select_ Sephora Picks - Banner' then 'Select_Sephora Picks_Banner'
        when a.banner_belong_area = '''Top Navigation' then 'Top Navigation'
        when a.banner_belong_area = 'Select_ Sephora Picks_ Title' then 'Select_Sephora Picks_Title'
        else a.banner_belong_area
        end,  --运营位所在版区
    a.banner_content,  --运营位内容
    a.ss_element_position,  --元素位置
    a.banner_current_url,  --运营位所在页面地址
    a.banner_to_url,  --运营位跳转url地址
    a.banner_ranking,  --排序
    a.campaign_code,  --运营活动编号
    a.op_code,  --产品id
    a.commodity_sku,  --货号
    a.dt;
END
GO
