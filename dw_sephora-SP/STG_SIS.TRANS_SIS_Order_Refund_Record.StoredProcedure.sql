/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Order_Refund_Record]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Order_Refund_Record] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Order_Refund_Record;
insert into STG_SIS.SIS_Order_Refund_Record
select 
		id,
		case when trim(order_no) in ('','null') then null else trim(order_no) end as order_no,
		case when trim(refund_id) in ('','null') then null else trim(refund_id) end as refund_id,
		refund_amount,
		case when trim(refund_desc) in ('','null') then null else trim(refund_desc) end as refund_desc,
		case when trim(refund_operator) in ('','null') then null else trim(refund_operator) end as refund_operator,
		case when trim(error_code_desc) in ('','null') then null else trim(error_code_desc) end as error_code_desc,
		status,
		create_time,
		update_time,
		activity_goods_id,
		goods_count,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Order_Refund_Record
) t
where rownum = 1
END
GO
