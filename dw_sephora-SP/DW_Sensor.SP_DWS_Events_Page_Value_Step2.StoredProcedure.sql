/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Events_Page_Value_Step2]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Events_Page_Value_Step2] @dt [VARCHAR](10) AS
begin
delete from [DW_Sensor].[DWS_Events_Page_Value_Step2] where [DATE]=@dt
INSERT INTO [DW_Sensor].[DWS_Events_Page_Value_Step2]
SELECT DISTINCT 
     temp_events.ORDERID
    ,temp_events.EVENT
    ,temp_events.USER_ID
    ,temp_events.BUY_OP_CODE
    ,temp_events.OP_CODE
    ,temp_events.PAGE_ID
    ,temp_events.sessionid
    ,temp_events.DATE
    ,temp_events.PLATFORM_TYPE
    ,temp_events.apportion_amount
    ,CASE 
       WHEN temp_events.TIME > isnull(b.start_time, '')
        AND temp_events.TIME <= b.end_time
         THEN b.row_num
       ELSE 0
     END AS ROW_NUM
    ,current_timestamp AS insert_timestamp
FROM 
    [DW_Sensor].[DWS_Events_Page_value_step1] temp_events
LEFT JOIN 
   (
    SELECT 
         S.orderid
        ,DET.event
        ,DET.user_id
        ,S.buy_op_code
        ,DET.op_code
        ,DET.PAGE_ID
        ,DET.sessionid
        ,DET.DATE
        ,lag(det.TIME, 1) OVER (PARTITION BY S.orderid,DET.event,DET.user_id,S.buy_op_code,DET.PLATFORM_TYPE,sessionid ORDER BY det.TIME) AS start_time
        ,DET.TIME AS end_time
        ,DET.PLATFORM_TYPE
        ,row_number() OVER (PARTITION BY S.orderid,DET.event,DET.user_id,S.buy_op_code,DET.PLATFORM_TYPE,sessionid ORDER BY det.TIME) AS row_num
    FROM [DW_Sensor].[DWS_Events_Session_Cutby30m] AS DET
    LEFT JOIN 
       (
        SELECT 
               EVENT
              ,USER_ID
              ,ORDERID
              ,DATE
              ,MAX(TIME) AS TIME
              ,OP_CODE AS BUY_OP_CODE
              ,PLATFORM_TYPE --,SYSTEM_TYPE
          FROM [STG_Sensor].[Events]
         WHERE DATE = @dt
           AND EVENT = 'submitOrderBySku'
         GROUP BY 
                EVENT
               ,USER_ID
               ,ORDERID
               ,DATE
               ,OP_CODE
               ,PLATFORM_TYPE
       ) S
      ON 
         DET.USER_ID = S.USER_ID
     AND 
         DET.DATE = S.DATE
     AND 
         DET.OP_Code = s.BUY_OP_CODE collate Chinese_PRC_CS_AI_WS
     AND 
         UPPER(DET.PLATFORM_TYPE collate Chinese_PRC_CS_AI_WS)=UPPER(S.PLATFORM_TYPE)
   WHERE 
         DET.TIME <= S.TIME AND S.USER_ID IS NOT NULL AND DET.event IN ('viewCommodityDetail') AND page_id IS NOT NULL
       ) b 
ON 
    temp_events.orderid = b.orderid collate Chinese_PRC_CS_AI_WS
AND 
    temp_events.user_id = b.user_id
AND 
    temp_events.DATE = b.DATE
AND 
    temp_events.TIME > isnull(b.start_time, '')
AND 
    temp_events.TIME <= b.end_time
AND 
    temp_events.sessionid = b.sessionid
and 
    temp_events.platform_type=b.PLATFORM_TYPE
WHERE 
    b.sessionid IS NOT NULL
;
end
GO
