/****** Object:  StoredProcedure [TEMP].[SP_DWS_Events_Page_Value_Step1_Bak_20220728]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Events_Page_Value_Step1_Bak_20220728] @dt [VARCHAR](10) AS
begin
delete from [DW_Sensor].[DWS_Events_Page_Value_Step1_Bak_20220728] where [DATE]=@dt
INSERT INTO [DW_Sensor].[DWS_Events_Page_Value_Step1_Bak_20220728]
SELECT 
     distinct s.orderid
	,det.event
	,det.user_id
	,s.buy_op_code
	,det.op_code
	,det.pageid_wo_prefix
	,det.sessionid
	,det.date
	,det.time
	,det.platform_type
	,c.apportion_amount
	,getdate() as insert_timestamp
FROM [DW_Sensor].[DWS_Events_Session_Cutby30m] DET
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
	WHERE DATE = @dt
    AND EVENT = 'submitOrderBySku'
	GROUP BY 
        EVENT
		,USER_ID
		,ORDERID
		,DATE
		,OP_CODE
		,PLATFORM_TYPE
) s 
ON DET.USER_ID = S.USER_ID 
AND DET.DATE = S.DATE 
and UPPER(DET.PLATFORM_TYPE collate Chinese_PRC_CS_AI_WS)=UPPER(S.PLATFORM_TYPE)
INNER JOIN 
(
	select 	sales_order_number
			,sku.eb_product_id
			,sum(item_apportion_amount) as apportion_amount
	from 	dwd.fact_sales_order so 
	left 	join dwd.dim_sku_info sku 
	on 		so.item_sku_code=sku.sku_code
	where 	1=1
	and		is_placed=1
	group 	by sales_order_number,sku.eb_product_id
) c 
ON 		s.orderid collate Chinese_PRC_CS_AI_WS = c.sales_order_number
AND 	s.BUY_OP_CODE collate Chinese_PRC_CS_AI_WS = CAST(c.eb_product_id AS NVARCHAR) collate Chinese_PRC_CS_AI_WS
WHERE 	DET.DATE = @dt
AND   	DET.TIME <= S.TIME
AND 	S.USER_ID IS NOT NULL
AND 	DET.event IN ('$AppViewScreen','$pageview','$MPViewScreen')
AND 	page_id IS NOT NULL
AND 	right(page_id, 7) NOT IN (
    '1000411'
    ,'1000101'
    ,'1000621'
    ,'1000602'
    ,'1000601'
    ,'1000611'
    ,'1000631'
    ,'1000161'
    ,'1000162'
    ,'1000141'
    ,'1000643'
    ,'1000634'
    ,'1000636'
    ,'1000638'
    ,'1000647'
    ,'1000612'
    ,'1000644'
    ,'1000641'
    ,'1000613'
    ,'1000632'
    ,'1000645'
    ,'1000646'
    ,'1000642'
    ,'1000635'
    ,'1000633'
    ,'1000637'
    ,'1000639'
    ,'1000163'
    ,'1000164'
    ,'1000145'
    ,'1000143'
    ,'1000144'
    ,'1000142'
    ,'1000146'
    ,'1000011'
    ,'1000117'
    ,'1000012'
    ,'1000015'
    ,'1000014'
    ,'1000112'
    ,'1000115'
    ,'1000111'
    ,'1000013'
    ,'1000113'
    ,'1000114'
    ,'1000116'
    ,'1000428'
    ,'1000401'
    ,'1000424'
    ,'1000423'
    ,'1000425'
    ,'1000430'
    ,'1000422'
    ,'1000429'
    ,'1000402'
    ,'1000421'
    ,'1000701'
    ,'1000704'
    ,'1000703'
    ,'1000707'
    ,'1000705'
    ,'1000706'
    ,'1000702'
    ,'1000708'
    ,'1000415'
    ,'1000419'
    ,'1000412'
    ,'1000418'
    ,'1000417'
    ,'1000416'
    ,'1000427'
    ,'1000420'
    ,'1000413'
    ,'1000414'
    ,'1000426'
)
;
end
GO
