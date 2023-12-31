/****** Object:  StoredProcedure [ODS_TD].[SP_RowCount]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_RowCount] @Start [datetime],@End [datetime] AS
    INSERT INTO STG_TD.Tb_API_Comparision
    SELECT
        convert(date,[clicktime]) [Date]
        , [appkey]
        ,'click' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_Android_Click]
    where [clicktime]>=@Start
        and [clicktime]<@End
        and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（即将下线）',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    group by  convert(date,[clicktime]),[appkey]
    union all
    SELECT
        convert(date,[active_time]) [Date]
        ,'A85FD453F75846BC8A8CA5046537EB5C' [appkey]
        ,'install' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_Android_Install]
    where [active_time]>=@Start
        and [active_time]<@End
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    group by  convert(date,[active_time])
    union all
    SELECT
        convert(date,[order_time]) [Date]
        ,'A85FD453F75846BC8A8CA5046537EB5C' [appkey]
        ,'order_count' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_Android_Order]
    where [order_time]>=@Start
        and [order_time]<@End
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    group by  convert(date,[order_time])
    union all
    SELECT
        convert(date,[pay_time]) [Date]
        ,'A85FD453F75846BC8A8CA5046537EB5C' [appkey]
        ,'pay_count' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_Android_PayOrder]
    where [pay_time]>=@Start
        and [pay_time]<@End
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    group by  convert(date,[pay_time])
    union all
    SELECT
        convert(date,[deeplink_time]) [Date]
        ,'A85FD453F75846BC8A8CA5046537EB5C' [appkey]
        ,'deeplink_count' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_Android_Wakeup]
    where [deeplink_time]>=@Start
        and [deeplink_time]<@End
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    group by convert(date,[deeplink_time])
    union all
    SELECT
        convert(date,[clicktime]) [Date]
        , [appkey]
        ,'click' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_IOS_Click]
    where [clicktime]>=@Start
        and [clicktime]<@End
        and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'超级粉丝通（即将下线）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
    group by  convert(date,[clicktime]),[appkey]
    union all
    SELECT
        convert(date,[active_time]) [Date]
        ,'8DD42261C4214813A642A9796F8AD664' [appkey]
        ,'install' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_IOS_Install]
    where [active_time]>=@Start
        and [active_time]<@End
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
    group by convert(date,[active_time])
    union all
    SELECT
        convert(date,[order_time]) [Date]
        ,'8DD42261C4214813A642A9796F8AD664' [appkey]
        ,'order_count' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_IOS_Order]
    where [order_time]>=@Start
        and [order_time]<@End
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
    group by convert(date,[order_time])
    union all
    SELECT
        convert(date,[pay_time]) [Date]
        ,'8DD42261C4214813A642A9796F8AD664' [appkey]
        ,'pay_count' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_IOS_PayOrder]
    where [pay_time]>=@Start
        and [pay_time]<@End
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
    group by convert(date,[pay_time])
    union all
    SELECT
        convert(date,[deeplink_time]) [Date]
        ,'8DD42261C4214813A642A9796F8AD664' [appkey]
        ,'deeplink_count' TDEvent
        ,count(*) [RowCount]
        ,1 Flag
    FROM [ODS_TD].[Tb_IOS_Wakeup]
    where [deeplink_time]>=@Start
        and [deeplink_time]<@End
        --and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
    group by convert(date,[deeplink_time])


    --    union all
    --  SELECT convert(date,[active_time]) [Date]
    --      ,'8DD42261C4214813A642A9796F8AD664' [appkey]
    --	  ,'PKGInstall' TDEvent
    --      ,count(*) [RowCount]
    --  FROM [ODS_TD].[Tb_PKG_Install]
    --  where [active_time]>=@Start
    --  and [active_time]<@End
    --  group by  convert(date,[active_time])
    --  union all
    --  SELECT convert(date,[order_time]) [Date]
    --      ,'PKG' [appkey]
    --	  ,'PKGOrder' TDEvent
    --      ,count(*) [RowCount]
    --  FROM [ODS_TD].[Tb_PKG_Order]
    --  where [order_time]>=@Start
    --  and [order_time]<@End
    --  group by  convert(date,[order_time])
    --  union all
    --  SELECT convert(date,[pay_time]) [Date]
    --      ,'PKG' [appkey]
    --	  ,'PKGPayOrder' TDEvent
    --      ,count(*) [RowCount]
    --  FROM [ODS_TD].[Tb_PKG_PayOrder]
    --  where [pay_time]>=@Start
    --  and [pay_time]<@End
    --  group by  convert(date,[pay_time])

    --  select * from #a
    --drop table #a


GO
