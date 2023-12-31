/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Events_Page_Value]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Events_Page_Value] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-05-31       wangzhichun    Initial Version
-- 2022-11-09       wangzhichun    update PLATFORM_TYPE
-- ========================================================================================
delete from  [DW_Sensor].[RPT_Events_Page_Value] where [DATE]=@dt
INSERT INTO [DW_Sensor].[RPT_Events_Page_Value]
select 
    temp.DATE
    ,temp.USER_ID
	,case when upper(temp.platform_type) = 'MINIPROGRAM' then 'MNP'
       else upper(temp.platform_Type)
       end as PLATFORM_TYPE
	,temp.orderid
	,temp.BUY_OP_CODE
	,temp.OP_CODE
	,temp.EVENT
	,temp.PAGE_ID
	,temp.sessionid
	,sum(page_value) as page_value
    ,getdate()
from 
(
    SELECT 
        temp2.orderid
		,temp2.EVENT
		,temp2.USER_ID
		,temp2.BUY_OP_CODE
		,temp2.OP_CODE
		,temp2.PAGE_ID
		,temp2.sessionid
		,temp2.DATE
		,temp2.PLATFORM_TYPE
		--,temp2.apportion_amount 
		,temp2.apportion_amount/[session].session_count /[group].group_count/count(temp2.row_num) over( PARTITION BY temp2.orderid,temp2.USER_ID,temp2.BUY_OP_CODE,temp2.sessionid,temp2.DATE,temp2.PLATFORM_TYPE,temp2.row_num) as Page_value
		--,temp2.ROW_NUM
		--,[session].session_count as session_count
		--,[group].group_count as group_count
		--,count(temp2.row_num) over( PARTITION BY temp2.orderid,temp2.USER_ID,temp2.BUY_OP_CODE,temp2.sessionid,temp2.DATE,temp2.PLATFORM_TYPE,temp2.row_num) as sub_group_count
	FROM 
        [DW_Sensor].[DWS_Events_Page_Value_Step2] temp2
    join 
    (
		select 
            orderID,
            user_id,
            buy_op_code,
            date,
            platform_type,
            sessionid,
            count(distinct row_num) as  group_count
		from 
            [DW_Sensor].[DWS_Events_Page_Value_Step2]
		--where  user_id='8579400379959340853'
		group by 
            orderID,
            user_id,
            buy_op_code,
            date,
            platform_type,
            sessionid
    ) [group]  
	on temp2.orderID=[group].orderid
	and temp2.user_id=[group].user_id
	and temp2.buy_op_code=[group].buy_op_code
	and temp2.date=[group].date
	and temp2.platform_type=[group].platform_type
	and temp2.sessionid=[group].sessionid
	join 
    (
		select 
            orderID,
            user_id,
            buy_op_code,
            date,
            platform_type,
            count(distinct sessionid) as  session_count
		from 
            [DW_Sensor].[DWS_Events_Page_Value_Step2]
		--where  user_id='8579400379959340853'
		group by 
            orderID,
            user_id,
            buy_op_code,
            date,
            platform_type
    ) [session]
	on temp2.orderID=[session].orderid
	and temp2.user_id=[session].user_id
	and temp2.buy_op_code=[session].buy_op_code
	and temp2.date=[session].date
	and temp2.platform_type=[session].platform_type
    where temp2.[DATE]=@dt
)temp
group by 
temp.DATE
,temp.USER_ID
,case when upper(temp.platform_type) = 'MINIPROGRAM' then 'MNP'
    else upper(temp.platform_Type)
    end
,temp.orderid
,temp.BUY_OP_CODE
,temp.OP_CODE
,temp.EVENT
,temp.PAGE_ID
,temp.sessionid
;
END

GO
