/****** Object:  StoredProcedure [TEMP].[SP_RPT_Events_Page_Value_BAK_20220830_1]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Events_Page_Value_BAK_20220830_1] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-**-01       未知           Initial Version
-- 2022-08-30       hsq            优化关联逻辑，用窗口替换两次关联取count值
-- ========================================================================================
delete from DW_Sensor.RPT_Events_Page_Value_BAK_20220830 where date=@dt;
insert into DW_Sensor.RPT_Events_Page_Value_BAK_20220830
select   p.date
        ,p.user_id
        ,p.platform_type
        ,p.orderid
        ,p.buy_op_code
        ,p.op_code
        ,p.event
        ,p.page_id
        ,p.sessionid
        --,sum(page_value) as page_value
		,sum(p.apportion_amount/ p.session_count / p.group_count / row_count) as page_value
        ,current_timestamp
from 
(
	select   date
			,user_id
			,platform_type
			,orderid
			,buy_op_code
			,op_code
			,event
			,page_id
			,sessionid
			,apportion_amount
			-- 因为不支持开窗函数中使用 distinct, 所有用dense_rank相减（正序-倒序）-- https://www.it1352.com/2018100.html
			,dense_rank() over (partition by orderid,user_id,buy_op_code,date,platform_type,sessionid order by row_num asc) + dense_rank() over (partition by orderid,user_id,buy_op_code,date,platform_type,sessionid order by row_num desc) - 1 as group_count
			,dense_rank() over (partition by orderid,user_id,buy_op_code,date,platform_type order by sessionid asc) + dense_rank() over (partition by orderid,user_id,buy_op_code,date,platform_type order by sessionid desc) - 1 as session_count
			,count(row_num) over( partition by orderid,user_id,buy_op_code,sessionid,date,platform_type,row_num) row_count
			--,count(distinct row_num) over(partition by orderid,user_id,buy_op_code,date,platform_type,sessionid) as group_count
			--,count(distinct sessionid) over(partition by orderid,user_id,buy_op_code,date,platform_type) as session_count
			--,size(collect_set(row_num)) over(partition by orderid,user_id,buy_op_code,date,platform_type,sessionid) as group_count
			--,size(collect_set(sessionid)) over(partition by orderid,user_id,buy_op_code,date,platform_type) as session_count
	from    DW_Sensor.DWS_Events_Page_Value
	where 	date=@dt
) p 
group by p.date,p.user_id,p.platform_type,p.orderid,p.buy_op_code,p.op_code,p.event,p.page_id,p.sessionid
END
;
GO
