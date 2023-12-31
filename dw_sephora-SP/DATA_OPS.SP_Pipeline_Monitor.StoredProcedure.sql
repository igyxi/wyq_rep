/****** Object:  StoredProcedure [DATA_OPS].[SP_Pipeline_Monitor]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_Pipeline_Monitor] @EndTime [DATETIME] AS
BEGIN

   -- DECLARE @EndTime DATETIME=DATEADD(HOUR,8,GETDATE())

    DECLARE @StartTime DATETIME

    SELECT @StartTime=MAX(Process_Time)
    FROM DATA_OPS.Fact_MonitorLog

    -------------------超时任务监控-------------------
    IF OBJECT_ID('tempdb..#DIM_ALL_DATE') IS NOT NULL
    BEGIN
        DROP TABLE #DIM_ALL_DATE
    END

    CREATE TABLE #DIM_ALL_DATE(StartTime DATETIME,EndTime DATETIME)

    --生成所有区间，防止跨天
    ;WITH DIM_NUMBERS AS (
        --数字辅助表
        SELECT 1 AS Num UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7
    )
    INSERT INTO #DIM_ALL_DATE
    SELECT
        StartTime=CASE WHEN CONVERT(DATE,DATEADD(D,Num-1,@StartTime))=CONVERT(DATE,@StartTime) THEN @StartTime ELSE CONVERT(VARCHAR(10),DATEADD(D,Num-1,@StartTime),120)+' 00:00:00.000' END
        ,EndTime=CASE WHEN CONVERT(DATE,DATEADD(D,Num-1,@StartTime))=CONVERT(DATE,@EndTime) THEN @EndTime ELSE CONVERT(VARCHAR(10),DATEADD(D,Num-1,@StartTime),120)+' 23:59:59.999' END
    FROM DIM_NUMBERS
    WHERE Num-1 BETWEEN 0 AND DATEDIFF(D,@StartTime,@EndTime)

    IF OBJECT_ID('tempdb..#FACT_Deadline') IS NOT NULL
    BEGIN
        DROP TABLE #FACT_Deadline
    END

    --生成本次监控时间段内所有定时任务列表
    SELECT
        facts.Pipeline_ID,
        facts.Pipeline_Name,
        facts.Pipeline_Subject,
        facts.Log_TB,
        facts.Log_Identity_Value,
        facts.Notification_Level,
		facts.Pipeline_Description,
        facts.Config_ID,
        facts.Schedule_Hour,
        facts.Schedule_Minute,
        facts.BizDate,
        facts.Schedule_Time
    INTO #FACT_Deadline
    FROM (
        SELECT
            dp.Pipeline_ID,
            dp.Pipeline_Name,
            dp.Pipeline_Subject,
            dp.Log_TB,
            dp.Log_Identity_Value,
            dp.Notification_Level,
			dp.Pipeline_Description,
            ddpdc.Config_ID,
            ddpdc.Schedule_Hour,
            ddpdc.Schedule_Minute,
            cd.BizDate,
            CONVERT(DATETIME,CONVERT(VARCHAR(20),cd.BizDate,20)+' '+RIGHT('00'+LTRIM(ddpdc.Schedule_Hour),2)+':'+RIGHT('00'+LTRIM(ddpdc.Schedule_Minute),2)+':00.000') AS Schedule_Time
        FROM DATA_OPS.Dim_Pipeline AS dp
        JOIN DATA_OPS.Dim_Pipeline_Deadline_Config AS ddpdc ON dp.Pipeline_ID=ddpdc.Pipeline_ID
        CROSS JOIN (SELECT DISTINCT CONVERT(DATE,StartTime) AS BizDate FROM #DIM_ALL_DATE) AS cd
        WHERE dp.[Status]=1 AND dp.Pipeline_Type=1 AND ddpdc.[Status]=1
            AND (ddpdc.Schedule_Type=2 OR (ddpdc.Schedule_Type=3 AND DATEPART(WEEKDAY,cd.BizDate)=ddpdc.Schedule_DayOfWeek) OR (ddpdc.Schedule_Type=4 AND DATEPART(DAY,cd.BizDate)=ddpdc.Schedule_Day))
    ) AS facts
    JOIN #DIM_ALL_DATE AS dad ON facts.Schedule_Time>dad.StartTime AND facts.Schedule_Time<=dad.EndTime

    --根据各个超时监控任务的日志表，筛选出未报警的超时任务
    IF OBJECT_ID('tempdb..#Fact_Notification_Deadline') IS NOT NULL
    BEGIN
        DROP TABLE #Fact_Notification_Deadline
    END

    ;WITH Fact_Notification_Deadline AS (
        SELECT
            fd.Pipeline_ID,
            fd.Pipeline_Name,
            fd.Pipeline_Subject,
            fd.Config_ID,
            fd.Schedule_Hour,
            fd.Schedule_Minute,
            fd.Notification_Level,
			fd.Pipeline_Description,
            fd.BizDate,
            CONVERT(VARCHAR(100),fpp.Process_ID) AS Process_ID
        FROM #FACT_Deadline AS fd
        LEFT JOIN DATA_OPS.Fact_NotificationLog AS fn ON fd.Config_ID=fn.Config_ID AND fd.BizDate=fn.BizDate	--只筛选出未报警
        LEFT JOIN DATA_OPS.Fact_Pipeline_ProcessLog AS fpp ON UPPER(fd.Log_Identity_Value)=UPPER(CONVERT(VARCHAR(50),fpp.Pipeline_ID)) AND fd.BizDate=fpp.BizDate AND fpp.Process_Status=2 AND fpp.Monitor_Flag=0
        WHERE fd.Log_TB='DATA_OPS.Fact_Pipeline_ProcessLog'
            AND fn.ID IS NULL	--只筛选出未报警
            AND (
                (fpp.Pipeline_ID IS NULL) --处理失败、处理中
                OR (fpp.Pipeline_ID IS NOT NULL AND FORMAT(fpp.Process_EndTime,'yyyyMMddHHmm')>FORMAT(fd.Schedule_Time,'yyyyMMddHHmm'))	--处理成功但已超时
            )

        UNION ALL
        SELECT
            fd.Pipeline_ID,
            fd.Pipeline_Name,
            fd.Pipeline_Subject,
            fd.Config_ID,
            fd.Schedule_Hour,
            fd.Schedule_Minute,
            fd.Notification_Level,
			fd.Pipeline_Description,
            fd.BizDate,
            NULL AS Process_ID
        FROM #FACT_Deadline AS fd
        LEFT JOIN DATA_OPS.Fact_NotificationLog AS fn ON fd.Config_ID=fn.Config_ID AND fd.BizDate=fn.BizDate	--只筛选出未报警
        LEFT JOIN [LOG].Tabular_Refresh_log AS fpp ON UPPER(fd.Log_Identity_Value)=UPPER(CONVERT(VARCHAR(50),fpp.Tabular_Name)) AND fd.BizDate=CONVERT(DATE,fpp.RefreshTime) AND fpp.[Status]='succeeded'
        WHERE fd.Log_TB='LOG.Tabular_Refresh_log'
            AND fn.ID IS NULL	--只筛选出未报警
            AND (
                (fpp.Tabular_Name IS NULL) --处理失败、处理中
                OR (fpp.Tabular_Name IS NOT NULL AND FORMAT(fpp.RefreshTime,'yyyyMMddHHmm')>FORMAT(fd.Schedule_Time,'yyyyMMddHHmm'))	--处理成功但已超时(精确到分钟)
            )
        UNION ALL
        SELECT
            fd.Pipeline_ID,
            fd.Pipeline_Name,
            fd.Pipeline_Subject,
            fd.Config_ID,
            fd.Schedule_Hour,
            fd.Schedule_Minute,
            fd.Notification_Level,
			fd.Pipeline_Description,
            fd.BizDate,
            CONVERT(VARCHAR(100),fpp.JobID) AS Process_ID
        FROM #FACT_Deadline AS fd
        LEFT JOIN DATA_OPS.Fact_NotificationLog AS fn ON fd.Config_ID=fn.Config_ID AND fd.BizDate=fn.BizDate	--只筛选出未报警
        LEFT JOIN [LOG].ADF_Transaction_log AS fpp ON UPPER(fd.Log_Identity_Value)=UPPER(CONVERT(VARCHAR(50),fpp.JobName)) AND fd.BizDate=CONVERT(DATE,fpp.EndTime) AND fpp.[JobStatus]='Succeeded'
        WHERE fd.Log_TB='LOG.ADF_Transaction_log'
            AND fn.ID IS NULL	--只筛选出未报警
            AND (
                (fpp.JobName IS NULL) --处理失败、处理中
                OR (fpp.JobName IS NOT NULL AND FORMAT(DATEADD(HOUR,8,fpp.EndTime),'yyyyMMddHHmm')>FORMAT(fd.Schedule_Time,'yyyyMMddHHmm'))	--处理成功但已超时(精确到分钟)
            )

        UNION ALL
        SELECT
            fd.Pipeline_ID,
            fd.Pipeline_Name,
            fd.Pipeline_Subject,
            fd.Config_ID,
            fd.Schedule_Hour,
            fd.Schedule_Minute,
            fd.Notification_Level,
			fd.Pipeline_Description,
            fd.BizDate,
            MAX(CONVERT(VARCHAR(100),fpp.id)) AS Process_ID
        FROM #FACT_Deadline AS fd
        CROSS APPLY STRING_SPLIT(fd.Log_Identity_Value,',') AS iv
        LEFT JOIN DATA_OPS.UDP_Table_Last_Update_Logging AS fpp ON UPPER(iv.[value])=fpp.[schema]+'.'+fpp.[table] AND fd.BizDate=CONVERT(DATE,fpp.last_update_time)
        WHERE fd.Log_TB='DATA_OPS.UDP_Table_Last_Update_Logging'
            AND (fpp.id IS NULL OR FORMAT(fpp.last_update_time,'yyyyMMddHHmm')>FORMAT(fd.Schedule_Time,'yyyyMMddHHmm'))
        GROUP BY fd.Pipeline_ID,fd.Pipeline_Name,fd.Pipeline_Subject,fd.Config_ID,fd.Schedule_Hour,fd.Schedule_Minute,fd.Notification_Level,fd.Pipeline_Description,fd.BizDate
    )
    SELECT *
    INTO #Fact_Notification_Deadline
    FROM Fact_Notification_Deadline

    -------------------错误任务监控-------------------
    IF OBJECT_ID('tempdb..#FACT_PipelineError_List') IS NOT NULL
    BEGIN
        DROP TABLE #FACT_PipelineError_List
    END

    --生成所有监控错误的任务
    SELECT
        facts.Pipeline_ID,
        facts.Pipeline_Name,
        facts.Pipeline_Subject,
        facts.Log_TB,
        facts.Log_Identity_Value,
        facts.Notification_Level,
		facts.Pipeline_Description
    INTO #FACT_PipelineError_List
    FROM (
        SELECT
            dp.Pipeline_ID,
            dp.Pipeline_Name,
            dp.Pipeline_Subject,
            dp.Log_TB,
            dp.Log_Identity_Value,
            dp.Notification_Level,
			dp.Pipeline_Description
        FROM DATA_OPS.Dim_Pipeline AS dp
        WHERE dp.[Status]=1 AND dp.Pipeline_Type=3
    ) AS facts

    --根据各个监控任务的日志表，筛选出未报警的错误任务
    IF OBJECT_ID('tempdb..#Fact_Notification_Error') IS NOT NULL
    BEGIN
        DROP TABLE #Fact_Notification_Error
    END

    ;WITH Fact_Notification_Error AS (
        SELECT
            fnd.Pipeline_ID,
            fnd.Pipeline_Name,
            fnd.Pipeline_Subject,
            fnd.Notification_Level,
		    fnd.Pipeline_Description,
            CONVERT(DATE,DATEADD(HOUR,8,fpp.Process_StartTime)) AS BizDate,
            fpp.Process_ID AS Process_ID
        FROM #FACT_PipelineError_List AS fnd
        CROSS APPLY STRING_SPLIT(fnd.Log_Identity_Value,',') AS iv
        JOIN DATA_OPS.Fact_Pipeline_ProcessLog AS fpp ON UPPER(iv.[value])=UPPER(CONVERT(VARCHAR(50),fpp.Pipeline_ID))
        WHERE fnd.Log_TB='DATA_OPS.Fact_Pipeline_ProcessLog'
            AND fpp.Process_Status=3
            AND (DATEADD(HOUR,8,fpp.Process_EndTime)>@StartTime AND DATEADD(HOUR,8,fpp.Process_EndTime)<=@EndTime
                OR DATEADD(HOUR,8,fpp.Process_StartTime)>@StartTime AND DATEADD(HOUR,8,fpp.Process_StartTime)<=@EndTime)
        UNION ALL
        SELECT
            fnd.Pipeline_ID,
            fnd.Pipeline_Name,
            fnd.Pipeline_Subject,
            fnd.Notification_Level,
			fnd.Pipeline_Description,
            CONVERT(DATE,DATEADD(HOUR,8,fpp.StartTime)) AS BizDate,
            fpp.JobID AS Process_ID
        FROM #FACT_PipelineError_List AS fnd
        CROSS APPLY STRING_SPLIT(fnd.Log_Identity_Value,',') AS iv
        JOIN [LOG].ADF_Transaction_log AS fpp ON UPPER(iv.[value])=UPPER(CONVERT(VARCHAR(50),fpp.JobName))
        WHERE fnd.Log_TB='LOG.ADF_Transaction_log'
            AND fpp.[JobStatus]='Falied'
            AND (DATEADD(HOUR,8,fpp.EndTime)>@StartTime AND DATEADD(HOUR,8,fpp.EndTime)<=@EndTime
                OR DATEADD(HOUR,8,fpp.StartTime)>@StartTime AND DATEADD(HOUR,8,fpp.StartTime)<=@EndTime)
    )
    SELECT *
    INTO #Fact_Notification_Error
    FROM Fact_Notification_Error

    INSERT INTO DATA_OPS.Fact_NotificationLog
    (
        Config_ID,
        Process_ID,
        BizDate,
        Notification_Type,
        Notification_EmailSubject,
        Notification_EmailBody,
        Notification_EmailToAddress,
        Notification_EmailCCAddress,
        Notification_Status,
        Notification_Time,
        Create_Time
    )
    SELECT
        Config_ID,
        CONVERT(NVARCHAR(100),Process_ID) AS Process_ID,
        BizDate,
        Notification_Level,
        'Data OPS Automatic Monitoring Error Warning - '+Pipeline_Subject AS Notification_EmailSubject,
        'Dear,'+char(13)+char(10)
        +N'Data OPS自动监测任务检测到异常！！！'+char(13)+char(10)
		+N'异常项：'+Pipeline_Description+char(13)+char(10)+
        Pipeline_Subject+' '+Pipeline_Name+' timed out' +char(13)+char(10)
		+char(13)+char(10)
		+N'请及时联系Data OPS团队进行处理！'+char(13)+char(10)
        +N'第一联系人:'+ (select ISNULL(Contacts_First,Contacts_Third) From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select ISNULL(Contacts_First_Phone,Contacts_Third_Phone) From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))+char(13)+char(10)
	    +N'第二联系人:'+ (select Contacts_Second From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select Contacts_Second_Phone From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))+char(13)+char(10)
		+N'第三联系人:'+ (select Contacts_Third From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select Contacts_Third_Phone From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 AS Notification_EmailBody,
        CASE WHEN Notification_Level=1 THEN 'IO.China.OC@accenture.com' ELSE 'sephorama@yechtech.com' END AS Notification_EmailToAddress,
        'cn_data_team@sephora.cn;sephorama@yechtech.com' AS Notification_EmailCCAddress,
        1 AS Notification_Status,
        NULL AS Notification_Time,
        DATEADD(HOUR,8,GETDATE()) AS Create_Time
    FROM #Fact_Notification_Deadline
    UNION ALL
    SELECT
        NULL AS Config_ID,
        CONVERT(NVARCHAR(100),Process_ID) AS Process_ID,
        BizDate,
        Notification_Level,
        'Data OPS Automatic Monitoring Error Warning - '+Pipeline_Subject AS Notification_EmailSubject,
       'Dear,'+char(13)+char(10)
        +N'Data OPS自动监测任务检测到异常！！！'+char(13)+char(10)
		+N'异常项：'+ Pipeline_Description +char(13)+char(10)+
        Pipeline_Subject+' '+Pipeline_Name+' ' +char(13)+char(10)
		+char(13)+char(10)
		+N'请及时联系Data OPS团队进行处理！'+char(13)+char(10)
        +N'第一联系人:'+ (select ISNULL(Contacts_First,Contacts_Third) From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select ISNULL(Contacts_First_Phone,Contacts_Third_Phone) From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))+char(13)+char(10)
	    +N'第二联系人:'+ (select Contacts_Second From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select Contacts_Second_Phone From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))+char(13)+char(10)
		+N'第三联系人:'+ (select Contacts_Third From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select Contacts_Third_Phone From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 AS Notification_EmailBody,
        CASE WHEN Notification_Level=1 THEN 'IO.China.OC@accenture.com' ELSE 'sephorama@yechtech.com' END AS Notification_EmailToAddress,
        'cn_data_team@sephora.cn;sephorama@yechtech.com' AS Notification_EmailCCAddress,
        1 AS Notification_Status,
        NULL AS Notification_Time,
        DATEADD(HOUR,8,GETDATE()) AS Create_Time
    FROM #Fact_Notification_Error
    UNION ALL
    SELECT
        fdr.Config_ID AS Config_ID,
        LTRIM(fdr.Result_ID) AS Process_ID,
        fdr.BizDate,
        dp.Notification_Level,
        'Data OPS Automatic Monitoring Error Warning - '+dp.Pipeline_Subject AS Notification_EmailSubject,
        'Dear,'+char(13)+char(10)
        +N'Data OPS自动监测任务检测到异常！！！'+char(13)+char(10)
		+N'异常项：'+ dp.Pipeline_Description +char(13)+char(10)+
        Pipeline_Subject+' '+Pipeline_Name+' ' +char(13)+char(10)
		+char(13)+char(10)
		+N'请及时联系Data OPS团队进行处理！'+char(13)+char(10)
        +N'第一联系人:'+ (select ISNULL(Contacts_First,Contacts_Third) From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select ISNULL(Contacts_First_Phone,Contacts_Third_Phone) From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))+char(13)+char(10)
	    +N'第二联系人:'+ (select Contacts_Second From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select Contacts_Second_Phone From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))+char(13)+char(10)
		+N'第三联系人:'+ (select Contacts_Third From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 +'  '+(select Contacts_Third_Phone From [DATA_OPS].[DIM_Work_Schedule_Config] 
		             where date=FORMAT(DATEADD(hh,8,GETDATE()),'yyyy-MM-dd'))
					 AS Notification_EmailBody,
        CASE WHEN Notification_Level=1 THEN 'IO.China.OC@accenture.com' ELSE 'sephorama@yechtech.com' END AS Notification_EmailToAddress,
        'cn_data_team@sephora.cn;sephorama@yechtech.com' AS Notification_EmailCCAddress,
        1 AS Notification_Status,
        NULL AS Notification_Time,
        DATEADD(HOUR,8,GETDATE()) AS Create_Time
    FROM DATA_OPS.Fact_DataMonitor_Result AS fdr
    JOIN DATA_OPS.Dim_DataMonitor_Config AS ddc ON fdr.Config_ID=ddc.Config_ID
    JOIN DATA_OPS.Dim_Pipeline AS dp ON dp.Pipeline_ID=ddc.Pipeline_ID
    WHERE fdr.Monitor_Flag=0 AND fdr.Monitor_Result=2 --AND fdr.Create_Time>@StartTime AND fdr.Create_Time<=@EndTime

    UPDATE DATA_OPS.Fact_DataMonitor_Result SET
        Monitor_Flag=1,
        Update_Time=DATEADD(HOUR,8,GETDATE())
    WHERE Monitor_Flag=0 --AND Create_Time>@StartTime AND Create_Time<=@EndTime


END
GO
