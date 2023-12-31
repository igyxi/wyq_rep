/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Order_OMS_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Order_OMS_Mapping] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Order_OMS_Mapping;
insert into STG_SIS.SIS_Order_OMS_Mapping
select 
		id,
		case when trim(order_no) in ('','null') then null else trim(order_no) end as order_no,
		case when trim(new_order_no) in ('','null') then null else trim(new_order_no) end as new_order_no,
		create_time,
		update_time,
		case when trim(purchase_order_number) in ('','null') then null else trim(purchase_order_number) end as purchase_order_number,
		case when trim(purchase_order_number_history) in ('','null') then null else trim(purchase_order_number_history) end as purchase_order_number_history,
		send_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Order_OMS_Mapping
) t
where rownum = 1
END
GO
