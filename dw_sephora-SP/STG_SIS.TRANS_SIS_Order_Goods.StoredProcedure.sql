/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Order_Goods]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Order_Goods] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Order_Goods;
insert into STG_SIS.SIS_Order_Goods
select 
		id,
		order_id,
		activity_goods_id,
		goods_count,
		goods_price,
		case when trim(del_flag) in ('','null') then null else trim(del_flag) end as del_flag,
		create_time,
		update_time,
		origin_goods_count,
		is_show,
		sap_quantity,
		out_of_stock_amount,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Order_Goods
) t
where rownum = 1
END
GO
