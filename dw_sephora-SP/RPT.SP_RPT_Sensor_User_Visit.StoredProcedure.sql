/****** Object:  StoredProcedure [RPT].[SP_RPT_Sensor_User_Visit]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sensor_User_Visit] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-15       lizeyuan           Initial Version
-- ========================================================================================
delete from [RPT].[RPT_Sensor_User_Visit] where dt = @dt;
insert into [RPT].[RPT_Sensor_User_Visit]
select 
	a.time_id
	,a.client_id
	,1 nb_visit
	,max(case when sku.eb_brand_name = 'SEPHORA' then 1 else 0 end) as sc_hit_page
	,a.dt dt
	,current_timestamp as insert_timestamp
from 
(
	select 
		cast(time as date) as time_id
		--,cast(user_id as nvarchar) as user_id
		,vip_card as client_id
		,op_code
		,dt
	from 
	    [DW_Sensor].[DWS_Events_Session_Cutby30m] 
		where dt = @dt
		and vip_card is not null 
	group by 
		cast(time as date)
		--,cast(user_id as nvarchar)
		,vip_card
		,op_code
		,dt
)a
left join 
(
    select 
        eb_product_id
        ,eb_brand_name
    from
        DWD.DIM_SKU_Info sku
    group by 
        eb_product_id
        ,eb_brand_name
) sku
on a.op_code = cast(sku.eb_product_id as nvarchar)
group by
    a.time_id
	,a.client_id 
    ,a.dt
END

GO
