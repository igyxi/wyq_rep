/****** Object:  StoredProcedure [TEST].[SP_paid_media_POC_event]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_paid_media_POC_event] AS 
BEGIN

    -- TRUNCATE TABLE [TEMP].[paid_media_POC_td_click_new];

    -- INSERT INTO [TEMP].[paid_media_POC_td_click_new]
    -- SELECT
    --     remark as [click_device_id], -- 点击用户设备ID
    --     clicktime, -- 点击时间(到秒)
    --     'Android' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',spreadgroup) >= 1 then 'HeroAPP'
    --         when CHARINDEX(N'Keep',spreadgroup) >= 1 then 'Keep'
    --         when CHARINDEX(N'优酷视频',spreadgroup) >= 1 then N'优酷视频'
    --         when CHARINDEX(N'哔哩哔哩',spreadgroup) >= 1 then N'哔哩哔哩'
    --         when CHARINDEX(N'喜马拉雅',spreadgroup) >= 1 then N'喜马拉雅'
    --         when CHARINDEX(N'大姨妈',spreadgroup) >= 1 then N'大姨妈'
    --         when CHARINDEX(N'美妆相机',spreadgroup) >= 1 then N'美妆相机'
    --         when CHARINDEX(N'豆瓣',spreadgroup) >= 1 then N'豆瓣'
    --         when CHARINDEX(N'小黑珑',spreadgroup) >= 1 then N'小黑珑'
    --         when CHARINDEX(N'知乎',spreadgroup) >= 1 then N'知乎'
    --         when CHARINDEX(N'美柚',spreadgroup) >= 1 then N'美柚'
    --         when CHARINDEX(N'优酷',spreadgroup) >= 1 then N'优酷'
    --         when CHARINDEX(N'网易',spreadgroup) >= 1 then N'网易'
    --         when CHARINDEX(N'芒果TV',spreadgroup) >= 1 then N'芒果TV'
    --         when CHARINDEX(N'toutiao',spreadgroup) >= 1 then 'toutiao'
    --         when CHARINDEX(N'weibofst',spreadgroup) >= 1 then 'weibofst'
    --         when CHARINDEX(N'baidu',spreadgroup) >= 1 then 'baidu'
    --         else '' END as spreadgroup
    -- FROM [ODS_TD].[Tb_Android_Click] a
    -- where 1 = 1
    --     and a.clicktime BETWEEN '2021-10-01' and '2021-11-01'
    --     and ISNULL(remark,'') <> ''

    -- INSERT INTO [TEMP].[paid_media_POC_td_click_new]
    -- SELECT
    --     remark as [click_device_id], -- 点击用户设备ID
    --     clicktime, -- 点击时间(到秒)
    --     'Android' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',spreadgroup) >= 1 then 'HeroAPP'
    --         when CHARINDEX(N'Keep',spreadgroup) >= 1 then 'Keep'
    --         when CHARINDEX(N'优酷视频',spreadgroup) >= 1 then N'优酷视频'
    --         when CHARINDEX(N'哔哩哔哩',spreadgroup) >= 1 then N'哔哩哔哩'
    --         when CHARINDEX(N'喜马拉雅',spreadgroup) >= 1 then N'喜马拉雅'
    --         when CHARINDEX(N'大姨妈',spreadgroup) >= 1 then N'大姨妈'
    --         when CHARINDEX(N'美妆相机',spreadgroup) >= 1 then N'美妆相机'
    --         when CHARINDEX(N'豆瓣',spreadgroup) >= 1 then N'豆瓣'
    --         when CHARINDEX(N'小黑珑',spreadgroup) >= 1 then N'小黑珑'
    --         when CHARINDEX(N'知乎',spreadgroup) >= 1 then N'知乎'
    --         when CHARINDEX(N'美柚',spreadgroup) >= 1 then N'美柚'
    --         when CHARINDEX(N'优酷',spreadgroup) >= 1 then N'优酷'
    --         when CHARINDEX(N'网易',spreadgroup) >= 1 then N'网易'
    --         when CHARINDEX(N'芒果TV',spreadgroup) >= 1 then N'芒果TV'
    --         when CHARINDEX(N'toutiao',spreadgroup) >= 1 then 'toutiao'
    --         when CHARINDEX(N'weibofst',spreadgroup) >= 1 then 'weibofst'
    --         when CHARINDEX(N'baidu',spreadgroup) >= 1 then 'baidu'
    --         else '' END as spreadgroup
    -- FROM [ODS_TD].[Tb_Android_Click] a
    -- where 1 = 1
    --     and a.clicktime BETWEEN '2021-12-01' and '2021-12-28'
    --     and ISNULL(remark,'') <> ''

    -- INSERT INTO [TEMP].[paid_media_POC_td_click_new]
    -- SELECT
    --     remark as [click_device_id], -- 点击用户设备ID
    --     clicktime, -- 点击时间(到秒)
    --     'iOS' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',spreadgroup) >= 1 then 'HeroAPP'
    --         when CHARINDEX(N'Keep',spreadgroup) >= 1 then 'Keep'
    --         when CHARINDEX(N'优酷视频',spreadgroup) >= 1 then N'优酷视频'
    --         when CHARINDEX(N'哔哩哔哩',spreadgroup) >= 1 then N'哔哩哔哩'
    --         when CHARINDEX(N'喜马拉雅',spreadgroup) >= 1 then N'喜马拉雅'
    --         when CHARINDEX(N'大姨妈',spreadgroup) >= 1 then N'大姨妈'
    --         when CHARINDEX(N'美妆相机',spreadgroup) >= 1 then N'美妆相机'
    --         when CHARINDEX(N'豆瓣',spreadgroup) >= 1 then N'豆瓣'
    --         when CHARINDEX(N'小黑珑',spreadgroup) >= 1 then N'小黑珑'
    --         when CHARINDEX(N'知乎',spreadgroup) >= 1 then N'知乎'
    --         when CHARINDEX(N'美柚',spreadgroup) >= 1 then N'美柚'
    --         when CHARINDEX(N'优酷',spreadgroup) >= 1 then N'优酷'
    --         when CHARINDEX(N'网易',spreadgroup) >= 1 then N'网易'
    --         when CHARINDEX(N'芒果TV',spreadgroup) >= 1 then N'芒果TV'
    --         when CHARINDEX(N'toutiao',spreadgroup) >= 1 then 'toutiao'
    --         when CHARINDEX(N'weibofst',spreadgroup) >= 1 then 'weibofst'
    --         when CHARINDEX(N'baidu',spreadgroup) >= 1 then 'baidu'
    --         else '' END as spreadgroup
    -- FROM [ODS_TD].[Tb_ios_Click] a
    -- WHERE 1 = 1
    --     and a.clicktime BETWEEN '2021-10-01' and '2021-11-01'
    --     and ISNULL(remark,'') <> ''

    -- INSERT INTO [TEMP].[paid_media_POC_td_click_new]
    -- SELECT
    --     remark as [click_device_id], -- 点击用户设备ID
    --     clicktime, -- 点击时间(到秒)
    --     'iOS' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',spreadgroup) >= 1 then 'HeroAPP'
    --         when CHARINDEX(N'Keep',spreadgroup) >= 1 then 'Keep'
    --         when CHARINDEX(N'优酷视频',spreadgroup) >= 1 then N'优酷视频'
    --         when CHARINDEX(N'哔哩哔哩',spreadgroup) >= 1 then N'哔哩哔哩'
    --         when CHARINDEX(N'喜马拉雅',spreadgroup) >= 1 then N'喜马拉雅'
    --         when CHARINDEX(N'大姨妈',spreadgroup) >= 1 then N'大姨妈'
    --         when CHARINDEX(N'美妆相机',spreadgroup) >= 1 then N'美妆相机'
    --         when CHARINDEX(N'豆瓣',spreadgroup) >= 1 then N'豆瓣'
    --         when CHARINDEX(N'小黑珑',spreadgroup) >= 1 then N'小黑珑'
    --         when CHARINDEX(N'知乎',spreadgroup) >= 1 then N'知乎'
    --         when CHARINDEX(N'美柚',spreadgroup) >= 1 then N'美柚'
    --         when CHARINDEX(N'优酷',spreadgroup) >= 1 then N'优酷'
    --         when CHARINDEX(N'网易',spreadgroup) >= 1 then N'网易'
    --         when CHARINDEX(N'芒果TV',spreadgroup) >= 1 then N'芒果TV'
    --         when CHARINDEX(N'toutiao',spreadgroup) >= 1 then 'toutiao'
    --         when CHARINDEX(N'weibofst',spreadgroup) >= 1 then 'weibofst'
    --         when CHARINDEX(N'baidu',spreadgroup) >= 1 then 'baidu'
    --         else '' END as spreadgroup
    -- FROM [ODS_TD].[Tb_ios_Click] a
    -- WHERE 1 = 1
    --     and a.clicktime BETWEEN '2021-12-01' and '2021-12-28'
    --     and ISNULL(remark,'') <> ''

    -- INSERT INTO [TEMP].[paid_media_POC_td_click_new]
    -- SELECT
    --     isnull([Android ID],'') as [click_device_id], -- 点击用户设备ID
    --     [Date] as clicktime, -- 点击时间(到秒)
    --     'Android' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',[Campaign Name]) >= 1 then 'HeroAPP'
    --         when CHARINDEX(N'Keep',[Campaign Name]) >= 1 then 'Keep'
    --         when CHARINDEX(N'优酷视频',[Campaign Name]) >= 1 then N'优酷视频'
    --         when CHARINDEX(N'哔哩哔哩',[Campaign Name]) >= 1 then N'哔哩哔哩'
    --         when CHARINDEX(N'喜马拉雅',[Campaign Name]) >= 1 then N'喜马拉雅'
    --         when CHARINDEX(N'大姨妈',[Campaign Name]) >= 1 then N'大姨妈'
    --         when CHARINDEX(N'美妆相机',[Campaign Name]) >= 1 then N'美妆相机'
    --         when CHARINDEX(N'豆瓣',[Campaign Name]) >= 1 then N'豆瓣'
    --         when CHARINDEX(N'小黑珑',[Campaign Name]) >= 1 then N'小黑珑'
    --         when CHARINDEX(N'知乎',[Campaign Name]) >= 1 then N'知乎'
    --         when CHARINDEX(N'美柚',[Campaign Name]) >= 1 then N'美柚'
    --         when CHARINDEX(N'优酷',[Campaign Name]) >= 1 then N'优酷'
    --         when CHARINDEX(N'网易',[Campaign Name]) >= 1 then N'网易'
    --         when CHARINDEX(N'芒果TV',[Campaign Name]) >= 1 then N'芒果TV'
    --         when CHARINDEX(N'toutiao',[Campaign Name]) >= 1 then 'toutiao'
    --         when CHARINDEX(N'weibofst',[Campaign Name]) >= 1 then 'weibofst'
    --         when CHARINDEX(N'baidu',[Campaign Name]) >= 1 then 'baidu'
    --         else '' END as [Campaign Name]
    -- FROM [ODS_TD].[Tb_Android_AdditionalClick] a
    -- WHERE 1 = 1
    --     and [Date] >= '2021-10-01'
    --     and [Date] < '2021-11-01'
    --     and isnull([Android ID],'') <> ''


    -- INSERT INTO [TEMP].[paid_media_POC_td_click_new]
    -- SELECT
    --     isnull([Android ID],'') as [click_device_id], -- 点击用户设备ID
    --     [Date] as clicktime, -- 点击时间(到秒)
    --     'Android' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',[Campaign Name]) >= 1 then 'HeroAPP'
    --         when CHARINDEX(N'Keep',[Campaign Name]) >= 1 then 'Keep'
    --         when CHARINDEX(N'优酷视频',[Campaign Name]) >= 1 then N'优酷视频'
    --         when CHARINDEX(N'哔哩哔哩',[Campaign Name]) >= 1 then N'哔哩哔哩'
    --         when CHARINDEX(N'喜马拉雅',[Campaign Name]) >= 1 then N'喜马拉雅'
    --         when CHARINDEX(N'大姨妈',[Campaign Name]) >= 1 then N'大姨妈'
    --         when CHARINDEX(N'美妆相机',[Campaign Name]) >= 1 then N'美妆相机'
    --         when CHARINDEX(N'豆瓣',[Campaign Name]) >= 1 then N'豆瓣'
    --         when CHARINDEX(N'小黑珑',[Campaign Name]) >= 1 then N'小黑珑'
    --         when CHARINDEX(N'知乎',[Campaign Name]) >= 1 then N'知乎'
    --         when CHARINDEX(N'美柚',[Campaign Name]) >= 1 then N'美柚'
    --         when CHARINDEX(N'优酷',[Campaign Name]) >= 1 then N'优酷'
    --         when CHARINDEX(N'网易',[Campaign Name]) >= 1 then N'网易'
    --         when CHARINDEX(N'芒果TV',[Campaign Name]) >= 1 then N'芒果TV'
    --         when CHARINDEX(N'toutiao',[Campaign Name]) >= 1 then 'toutiao'
    --         when CHARINDEX(N'weibofst',[Campaign Name]) >= 1 then 'weibofst'
    --         when CHARINDEX(N'baidu',[Campaign Name]) >= 1 then 'baidu'
    --         else '' END as [Campaign Name]
    -- FROM [ODS_TD].[Tb_Android_AdditionalClick] a
    -- WHERE 1 = 1
    --     and [Date] >= '2021-12-01'
    --     and [Date] < '2021-12-28'
    --     and isnull([Android ID],'') <> ''

    -- TRUNCATE TABLE [TEMP].[paid_media_POC_td_install];

    -- INSERT INTO [TEMP].[paid_media_POC_td_install]
    -- SELECT
    --     ISNULL(android_id,'') as [install_device_id], -- 点击用户设备ID
    --     clicktime, -- 点击时间(到秒)
    --     'Android' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',campaign_name) >= 1 then N'HeroAPP'
    --     when CHARINDEX(N'Keep',campaign_name) >= 1 then N'Keep'
    --     when CHARINDEX(N'抖音',campaign_name) >= 1 then N'抖音'
    --     when CHARINDEX(N'DOUYIN',campaign_name) >= 1 then N'抖音'
    --     when CHARINDEX(N'头条',campaign_name) >= 1 then N'头条'
    --     when CHARINDEX(N'优酷视频',campaign_name) >= 1 then N'优酷视频'
    --     when CHARINDEX(N'哔哩哔哩',campaign_name) >= 1 then N'哔哩哔哩'
    --     when CHARINDEX(N'喜马拉雅',campaign_name) >= 1 then N'喜马拉雅'
    --     when CHARINDEX(N'大姨妈',campaign_name) >= 1 then N'大姨妈'
    --     when CHARINDEX(N'美妆相机',campaign_name) >= 1 then N'美妆相机'
    --     when CHARINDEX(N'豆瓣',campaign_name) >= 1 then N'豆瓣'
    --     when CHARINDEX(N'小黑珑',campaign_name) >= 1 then N'小黑珑'
    --     when CHARINDEX(N'知乎',campaign_name) >= 1 then N'知乎'
    --     when CHARINDEX(N'美柚',campaign_name) >= 1 then N'美柚'
    --     when CHARINDEX(N'优酷',campaign_name) >= 1 then N'优酷'
    --     when CHARINDEX(N'网易',campaign_name) >= 1 then N'网易'
    --     when CHARINDEX(N'MSEM',campaign_name) >= 1 then N'MSEM'
    --     when CHARINDEX(N'MBZ',campaign_name) >= 1 then N'MBZ'
    --     when CHARINDEX(N'芒果TV',campaign_name) >= 1 then N'芒果TV'
    --     when CHARINDEX(N'toutiao',campaign_name) >= 1 then N'toutiao'
    --     when CHARINDEX(N'weibofst',campaign_name) >= 1 then N'weibofst'
    --     when CHARINDEX(N'baidu',campaign_name) >= 1 then N'baidu'
    --     else '' END as campaign_name
    -- -- select distinct campaign_name
    -- FROM [ODS_TD].[Tb_Android_Install] a
    -- where 1 = 1
    --     and a.clicktime BETWEEN '2021-10-01' and '2021-11-01'
    --     and ISNULL(android_id,'') <> ''

    -- INSERT INTO [TEMP].[paid_media_POC_td_install]
    -- SELECT
    --     ISNULL(android_id,'') as [install_device_id], -- 点击用户设备ID
    --     clicktime, -- 点击时间(到秒)
    --     'Android' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',campaign_name) >= 1 then N'HeroAPP'
    --     when CHARINDEX(N'Keep',campaign_name) >= 1 then N'Keep'
    --     when CHARINDEX(N'抖音',campaign_name) >= 1 then N'抖音'
    --     when CHARINDEX(N'DOUYIN',campaign_name) >= 1 then N'抖音'
    --     when CHARINDEX(N'头条',campaign_name) >= 1 then N'头条'
    --     when CHARINDEX(N'优酷视频',campaign_name) >= 1 then N'优酷视频'
    --     when CHARINDEX(N'哔哩哔哩',campaign_name) >= 1 then N'哔哩哔哩'
    --     when CHARINDEX(N'喜马拉雅',campaign_name) >= 1 then N'喜马拉雅'
    --     when CHARINDEX(N'大姨妈',campaign_name) >= 1 then N'大姨妈'
    --     when CHARINDEX(N'美妆相机',campaign_name) >= 1 then N'美妆相机'
    --     when CHARINDEX(N'豆瓣',campaign_name) >= 1 then N'豆瓣'
    --     when CHARINDEX(N'小黑珑',campaign_name) >= 1 then N'小黑珑'
    --     when CHARINDEX(N'知乎',campaign_name) >= 1 then N'知乎'
    --     when CHARINDEX(N'美柚',campaign_name) >= 1 then N'美柚'
    --     when CHARINDEX(N'优酷',campaign_name) >= 1 then N'优酷'
    --     when CHARINDEX(N'网易',campaign_name) >= 1 then N'网易'
    --     when CHARINDEX(N'MSEM',campaign_name) >= 1 then N'MSEM'
    --     when CHARINDEX(N'MBZ',campaign_name) >= 1 then N'MBZ'
    --     when CHARINDEX(N'芒果TV',campaign_name) >= 1 then N'芒果TV'
    --     when CHARINDEX(N'toutiao',campaign_name) >= 1 then N'toutiao'
    --     when CHARINDEX(N'weibofst',campaign_name) >= 1 then N'weibofst'
    --     when CHARINDEX(N'baidu',campaign_name) >= 1 then N'baidu'
    --     else '' END as campaign_name
    -- -- select distinct campaign_name
    -- FROM [ODS_TD].[Tb_Android_Install] a
    -- where 1 = 1
    --     and a.clicktime BETWEEN '2021-12-01' and '2021-12-28'
    --     and ISNULL(android_id,'') <> ''

    -- INSERT INTO [TEMP].[paid_media_POC_td_install]
    -- SELECT
    --     ISNULL(idfa,'') as [install_device_id], -- 点击用户设备ID
    --     clicktime, -- 点击时间(到秒)
    --     'IOS' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',campaign_name) >= 1 then N'HeroAPP'
    --     when CHARINDEX(N'Keep',campaign_name) >= 1 then N'Keep'
    --     when CHARINDEX(N'抖音',campaign_name) >= 1 then N'抖音'
    --     when CHARINDEX(N'DOUYIN',campaign_name) >= 1 then N'抖音'
    --     when CHARINDEX(N'头条',campaign_name) >= 1 then N'头条'
    --     when CHARINDEX(N'优酷视频',campaign_name) >= 1 then N'优酷视频'
    --     when CHARINDEX(N'哔哩哔哩',campaign_name) >= 1 then N'哔哩哔哩'
    --     when CHARINDEX(N'喜马拉雅',campaign_name) >= 1 then N'喜马拉雅'
    --     when CHARINDEX(N'大姨妈',campaign_name) >= 1 then N'大姨妈'
    --     when CHARINDEX(N'美妆相机',campaign_name) >= 1 then N'美妆相机'
    --     when CHARINDEX(N'豆瓣',campaign_name) >= 1 then N'豆瓣'
    --     when CHARINDEX(N'小黑珑',campaign_name) >= 1 then N'小黑珑'
    --     when CHARINDEX(N'知乎',campaign_name) >= 1 then N'知乎'
    --     when CHARINDEX(N'美柚',campaign_name) >= 1 then N'美柚'
    --     when CHARINDEX(N'优酷',campaign_name) >= 1 then N'优酷'
    --     when CHARINDEX(N'网易',campaign_name) >= 1 then N'网易'
    --     when CHARINDEX(N'MSEM',campaign_name) >= 1 then N'MSEM'
    --     when CHARINDEX(N'MBZ',campaign_name) >= 1 then N'MBZ'
    --     when CHARINDEX(N'芒果TV',campaign_name) >= 1 then N'芒果TV'
    --     when CHARINDEX(N'toutiao',campaign_name) >= 1 then N'toutiao'
    --     when CHARINDEX(N'weibofst',campaign_name) >= 1 then N'weibofst'
    --     when CHARINDEX(N'baidu',campaign_name) >= 1 then N'baidu'
    --     else '' END as campaign_name
    -- -- select distinct campaign_name
    -- FROM [ODS_TD].[Tb_IOS_Install] a
    -- where 1 = 1
    --     and a.clicktime BETWEEN '2021-10-01' and '2021-11-01'
    --     and ISNULL(idfa,'') <> ''

    -- INSERT INTO [TEMP].[paid_media_POC_td_install]
    -- SELECT
    --     ISNULL(idfa,'') as [install_device_id], -- 点击用户设备ID
    --     clicktime, -- 点击时间(到秒)
    --     'IOS' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    --     case when CHARINDEX(N'HeroAPP',campaign_name) >= 1 then N'HeroAPP'
    --     when CHARINDEX(N'Keep',campaign_name) >= 1 then N'Keep'
    --     when CHARINDEX(N'抖音',campaign_name) >= 1 then N'抖音'
    --     when CHARINDEX(N'DOUYIN',campaign_name) >= 1 then N'抖音'
    --     when CHARINDEX(N'头条',campaign_name) >= 1 then N'头条'
    --     when CHARINDEX(N'优酷视频',campaign_name) >= 1 then N'优酷视频'
    --     when CHARINDEX(N'哔哩哔哩',campaign_name) >= 1 then N'哔哩哔哩'
    --     when CHARINDEX(N'喜马拉雅',campaign_name) >= 1 then N'喜马拉雅'
    --     when CHARINDEX(N'大姨妈',campaign_name) >= 1 then N'大姨妈'
    --     when CHARINDEX(N'美妆相机',campaign_name) >= 1 then N'美妆相机'
    --     when CHARINDEX(N'豆瓣',campaign_name) >= 1 then N'豆瓣'
    --     when CHARINDEX(N'小黑珑',campaign_name) >= 1 then N'小黑珑'
    --     when CHARINDEX(N'知乎',campaign_name) >= 1 then N'知乎'
    --     when CHARINDEX(N'美柚',campaign_name) >= 1 then N'美柚'
    --     when CHARINDEX(N'优酷',campaign_name) >= 1 then N'优酷'
    --     when CHARINDEX(N'网易',campaign_name) >= 1 then N'网易'
    --     when CHARINDEX(N'MSEM',campaign_name) >= 1 then N'MSEM'
    --     when CHARINDEX(N'MBZ',campaign_name) >= 1 then N'MBZ'
    --     when CHARINDEX(N'芒果TV',campaign_name) >= 1 then N'芒果TV'
    --     when CHARINDEX(N'toutiao',campaign_name) >= 1 then N'toutiao'
    --     when CHARINDEX(N'weibofst',campaign_name) >= 1 then N'weibofst'
    --     when CHARINDEX(N'baidu',campaign_name) >= 1 then N'baidu'
    --     else '' END as campaign_name
    -- -- select distinct campaign_name
    -- FROM [ODS_TD].[Tb_IOS_Install] a
    -- where 1 = 1
    --     and a.clicktime BETWEEN '2021-12-01' and '2021-12-28'
    --     and ISNULL(idfa,'') <> ''

INSERT INTO [TEMP].[paid_media_POC_td_click_new2]
SELECT
    isnull([IDFA],'') as [click_device_id], -- 点击用户设备ID
    [Date] as clicktime, -- 点击时间(到秒)
    'IOS' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    case when CHARINDEX('HeroAPP',[Campaign Name]) = 1 then 'HeroAPP'
        when CHARINDEX('Keep',[Campaign Name]) = 1 then 'Keep'
        when CHARINDEX(N'优酷视频',[Campaign Name]) = 1 then N'优酷视频'
        when CHARINDEX(N'哔哩哔哩',[Campaign Name]) = 1 then N'哔哩哔哩'
        when CHARINDEX(N'喜马拉雅',[Campaign Name]) = 1 then N'喜马拉雅'
        when CHARINDEX(N'大姨妈',[Campaign Name]) = 1 then N'大姨妈'
        when CHARINDEX(N'美妆相机',[Campaign Name]) = 1 then N'美妆相机'
        when CHARINDEX(N'豆瓣',[Campaign Name]) = 1 then N'豆瓣'
        when CHARINDEX(N'小黑珑',[Campaign Name]) = 1 then N'小黑珑'
        when CHARINDEX(N'知乎',[Campaign Name]) = 1 then N'知乎'
        when CHARINDEX(N'美柚',[Campaign Name]) = 1 then N'美柚'
        when CHARINDEX(N'优酷',[Campaign Name]) = 1 then N'优酷'
        when CHARINDEX(N'网易',[Campaign Name]) = 1 then N'网易'
        when CHARINDEX(N'芒果TV',[Campaign Name]) = 1 then N'芒果TV'
        else '' END as spreadgroup
FROM [ODS_TD].[Tb_IOS_AdditionalClick] a
WHERE 1 = 1
    and [Date] >= '2021-12-01'
    and [Date] < '2021-12-28'


INSERT INTO [TEMP].[paid_media_POC_td_click_new2]
SELECT
    isnull([IDFA],'') as [click_device_id], -- 点击用户设备ID
    [Date] as clicktime, -- 点击时间(到秒)
    'IOS' as [device_type], -- 用户设备ID类型(如iOS、安卓)
    case when CHARINDEX('HeroAPP',[Campaign Name]) = 1 then 'HeroAPP'
        when CHARINDEX('Keep',[Campaign Name]) = 1 then 'Keep'
        when CHARINDEX(N'优酷视频',[Campaign Name]) = 1 then N'优酷视频'
        when CHARINDEX(N'哔哩哔哩',[Campaign Name]) = 1 then N'哔哩哔哩'
        when CHARINDEX(N'喜马拉雅',[Campaign Name]) = 1 then N'喜马拉雅'
        when CHARINDEX(N'大姨妈',[Campaign Name]) = 1 then N'大姨妈'
        when CHARINDEX(N'美妆相机',[Campaign Name]) = 1 then N'美妆相机'
        when CHARINDEX(N'豆瓣',[Campaign Name]) = 1 then N'豆瓣'
        when CHARINDEX(N'小黑珑',[Campaign Name]) = 1 then N'小黑珑'
        when CHARINDEX(N'知乎',[Campaign Name]) = 1 then N'知乎'
        when CHARINDEX(N'美柚',[Campaign Name]) = 1 then N'美柚'
        when CHARINDEX(N'优酷',[Campaign Name]) = 1 then N'优酷'
        when CHARINDEX(N'网易',[Campaign Name]) = 1 then N'网易'
        when CHARINDEX(N'芒果TV',[Campaign Name]) = 1 then N'芒果TV'
        else '' END as spreadgroup
        -- select count(1)
FROM [ODS_TD].[Tb_IOS_AdditionalClick] a
WHERE 1 = 1
    and [Date] >= '2021-10-01'
    and [Date] < '2021-11-01'



END
GO
