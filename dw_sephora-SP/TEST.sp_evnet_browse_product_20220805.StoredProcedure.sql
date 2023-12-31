/****** Object:  StoredProcedure [TEST].[sp_evnet_browse_product_20220805]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_evnet_browse_product_20220805] @dt [varchar](10) AS
begin
--  浏览指定页面的数据
delete from test.evnet_browse_product_20220805 where dt = @dt;

insert  into test.evnet_browse_product_20220805
-- 通过op_code 提取 lauder 和 kiehls 浏览和搜索记录，搜索最终可能还是在要用like 来取数，这里只是先把数据提取出来。
select 	t.vip_card
		,t.event
		,t.platform_type
		,t.banner_belong_area
		,'' banner_belong
		,p.product_id
		,p.name_cn
		,p.name_en
		,p.brand
		,p.sku_code
		,t.date
from 	test.product_sku_20220805 p
inner 	join
(
	select 	vip_card
			,event
			,platform_type
			,date
			,try_cast(op_code as int) op_code
			,banner_belong_area
	from 	STG_Sensor.Events
	where 	dt = @dt
	and 	coalesce(op_code,'') <> ''
	and 	(event = '$pageview'
	or 		(event in ('clickBanner_App_Mob','clickBanner_MP')
	and     banner_belong_area = 'searchview')) -- 搜索
	group 	by vip_card,event,platform_type,date,op_code,banner_belong_area
) t
on 		p.sku_code = t.op_code
where   p.sku_code is not null
group 	by t.vip_card,t.event,t.platform_type,t.date,t.op_code,p.product_id,p.name_cn,p.name_en,p.brand,p.sku_code,t.banner_belong_area
-- 搜索数据
union   all
select 	vip_card
		,event
		,platform_type
		,banner_belong_area
		,N'科颜氏' banner_belong
		,null product_id
		,null name_cn
		,null name_en
		,null brand
		,op_code as sku_code
		,date
from  	STG_Sensor.Events
where   date = @dt
--and     a.platform_type in ('app','MiniProgram')  -- 这里需要区分平台吗？
--and     p.platform_type in('mobile','web','wechat','MiniProgram','Mini Program','app','APP')
and     event in ('clickBanner_App_Mob','clickBanner_MP')
and     banner_belong_area in ('searchview') -- 搜索
and     banner_content like N'%科颜氏%'
group   by vip_card,event,platform_type,date,banner_belong_area,op_code
union   all
select 	vip_card
		,event
		,platform_type
		,banner_belong_area
		,N'科颜氏' banner_belong
		,null product_id
		,null name_cn
		,null name_en
		,null brand
		,op_code as sku_code
		,date
from  	STG_Sensor.Events
where   date = @dt
--and     a.platform_type in ('app','MiniProgram')  -- 这里需要区分平台吗？
--and     p.platform_type in('mobile','web','wechat','MiniProgram','Mini Program','app','APP')
and     event in ('clickBanner_App_Mob','clickBanner_MP')
and     banner_belong_area in ('searchview') -- 搜索
and     banner_content like N'%雅诗兰黛%'
group   by vip_card,event,platform_type,date,banner_belong_area,op_code
;
end
GO
