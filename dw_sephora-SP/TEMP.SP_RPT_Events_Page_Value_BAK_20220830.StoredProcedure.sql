/****** Object:  StoredProcedure [TEMP].[SP_RPT_Events_Page_Value_BAK_20220830]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Events_Page_Value_BAK_20220830] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-**-01       未知           Initial Version
-- 2022-08-10       hsq            优化关联逻辑，用窗口替换两次关联取count值
-- ========================================================================================
delete from DW_Sensor.RPT_Events_Page_Value_BAK where date=@dt;
insert into DW_Sensor.RPT_Events_Page_Value_BAK
select   t.date
        ,t.user_id
        ,t.platform_type
        ,t.orderid
        ,t.buy_op_code
        ,t.op_code
        ,t.event
        ,t.page_id
        ,t.sessionid
		,sum(t.apportion_amount/ t.session_count / t.group_count / t.row_count) as page_value
        ,current_timestamp as insert_timestamp
from 
(
	select  p.date
			,p.user_id
			,p.platform_type
			,p.orderid
			,p.buy_op_code
			,p.op_code
			,p.event
			,p.page_id
			,p.sessionid
			,p.apportion_amount
			,max(sessionid_dense_rank) over(partition by p.orderid,p.user_id,p.buy_op_code,p.date,p.platform_type) as session_count
			,max(row_dense_rank) over(partition by p.orderid,p.user_id,p.buy_op_code,p.date,p.platform_type,p.sessionid) as group_count
			,p.row_count
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
				,dense_rank() over (partition by orderid,user_id,buy_op_code,date,platform_type order by sessionid asc) sessionid_dense_rank				
				,dense_rank() over (partition by orderid,user_id,buy_op_code,date,platform_type,sessionid order by row_num asc) row_dense_rank
				,count(row_num) over( partition by orderid,user_id,buy_op_code,sessionid,date,platform_type,row_num) row_count
				-- 开窗函数不支持distinct , 功能实现，参考：https://www.cnblogs.com/jenrrychen/p/5131410.html， 先对需要去重的字段进行分组排序dense_rank，排序之后，取最大的值，就是和count(distinct) over(partition by )的值相同
				--,count(distinct row_num) over(partition by orderid,user_id,buy_op_code,date,platform_type,sessionid) as group_count 
				--,count(distinct sessionid) over(partition by orderid,user_id,buy_op_code,date,platform_type) as session_count
		from 	DW_Sensor.DWS_Events_Page_Value
		where 	date=@dt
	) p 
) t 
group by t.date,t.user_id,t.platform_type,t.orderid,t.buy_op_code,t.op_code,t.event,t.page_id,t.sessionid
end 
;
GO
