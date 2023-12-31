/****** Object:  StoredProcedure [TEMP].[SP_DIM_Promotion_Bak_20230414]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Promotion_Bak_20230414] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-06       Eric               Change Sourse
-- 2022-02-23       Tali               add status/order_type/use_type
--									   Change Sourse
-- ========================================================================================
truncate table DWD.DIM_Promotion;
insert into DWD.DIM_Promotion
select
	a.promotion_sys_id as promotion_id
	,a.promotion_name
	,a.promotion_type
	,a.status
    ,a.channel_id
    ,a.customer_group
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
