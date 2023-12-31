/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Events_Page_Value_Step1]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Events_Page_Value_Step1] @dt [VARCHAR](10) AS
begin
delete from [DW_Sensor].[DWS_Events_Page_Value_Step1] where [DATE]=@dt
INSERT INTO [DW_Sensor].[DWS_Events_Page_Value_Step1]
SELECT DISTINCT 
     S.ORDERID
    ,DET.EVENT
    ,DET.USER_ID
    ,S.BUY_OP_CODE
    ,DET.OP_CODE
    ,DET.pageid_wo_prefix
    ,DET.sessionid
    ,DET.DATE
    ,DET.TIME
    ,DET.PLATFORM_TYPE
    ,c.apportion_amount
    ,current_timestamp AS insert_timestamp
FROM 
    [DW_Sensor].[DWS_Events_Session_Cutby30m] DET
INNER JOIN 
   (
    SELECT 
        EVENT
       ,USER_ID
       ,ORDERID
       ,DATE
       ,MAX(TIME) AS TIME
       ,OP_CODE AS BUY_OP_CODE
       ,PLATFORM_TYPE --,SYSTEM_TYPE
    FROM 
        [STG_Sensor].[Events]
    WHERE 
        DATE = @dt 
    AND 
        EVENT = 'submitOrderBySku'
    and 
        user_id is not null 
    group by 
        event
       ,user_id
       ,orderid
       ,date
       ,op_code
       ,platform_type
   ) s 
ON 
    DET.USER_ID = S.USER_ID 
AND 
    DET.DATE = S.DATE 
and 
    UPPER(DET.PLATFORM_TYPE collate Chinese_PRC_CS_AI_WS)=UPPER(S.PLATFORM_TYPE)
INNER JOIN 
   (
    select 
          sales_order_number
         ,sku.eb_product_id
         ,sum(item_apportion_amount) as apportion_amount
    from 
         dwd.fact_sales_order so 
    left join 
         dwd.dim_sku_info sku 
    on 
         so.item_sku_code=sku.sku_code
    where 
         is_placed=1
    group by 
         sales_order_number,sku.eb_product_id
    ) c 
ON 
    s.orderid collate Chinese_PRC_CS_AI_WS = c.sales_order_number
AND 
    s.BUY_OP_CODE collate Chinese_PRC_CS_AI_WS = CAST(c.eb_product_id AS NVARCHAR) collate Chinese_PRC_CS_AI_WS
left join
    [DW_Sensor].[DIM_Events_Page_Value_Page] p 
on 
    right(det.page_id, 7) = p.page_id
WHERE 
    DET.date = @dt
AND 
    DET.TIME <= S.TIME
AND 
    DET.event IN ('$AppViewScreen','$pageview','$MPViewScreen')
AND
    p.page_id is null
;
end
GO
