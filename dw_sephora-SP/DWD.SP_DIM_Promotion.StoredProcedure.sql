/****** Object:  StoredProcedure [DWD].[SP_DIM_Promotion]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Promotion] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-06       Eric               Change Sourse
-- 2022-02-23       Tali               add status/order_type/use_type
-- 2023-04-17       wangzhichun    	   Change Sourse
-- 2023-04-21       wangzhichun    	   update json field 
-- ========================================================================================
truncate table DWD.DIM_Promotion;
insert into DWD.DIM_Promotion
select
	a.promotion_sys_id as promotion_id
	,a.promotion_name
	,a.promotion_type
	,a.status
    ,convert(varchar(4000),a.channel_id,0) as channel_id
    ,convert(varchar(4000),a.customer_group,0) as customer_group
	,a.order_type
	,a.use_type
	,case when b.promotion_id is not null then 1 else 0 end as crm_flag
	,a.create_time
	,a.start_time
	,a.end_time
	,'OMS' as source
	,current_timestamp as insert_timestamp
from 
    [ODS_Promotion].[Promotion] a
left join
	(select distinct promotion_id from ODS_Promotion.CRM_EB_REL) b
on a.promotion_sys_id = b.promotion_id
;
END


GO
