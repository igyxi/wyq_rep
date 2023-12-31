/****** Object:  StoredProcedure [TEMP].[SP_Fact_Cart_Flow_Bak_20230324]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Cart_Flow_Bak_20230324] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       wangzhichun        Initial Version
-- 2022-01-12       tali           update delete
-- 2022-02-25       tali           add member_card
-- ========================================================================================
delete from DWD.Fact_Cart_Flow where format(create_time, 'yyyy-MM-dd') = @dt;
insert into DWD.Fact_Cart_Flow
select 
    sc.id,
	sc.user_id,
	M.member_card,
	sc.sku_id,
	sp.sku_code,
	sc.change_num,
	sc.channel as change_channel,
	sc.type as change_type,
	sc.store as store_code,
	sc.cart_type,
	sc.create_time,
	sc.update_time,
    sc.is_delete,
    'OMS' as source,
    current_timestamp as insert_timestamp
from 
    [STG_ShopCart].[Cart_Flow] sc
left join
    [STG_Product].[PROD_SKU] sp
on sc.sku_id=sp.sku_id
left join
	DWD.DIM_Member_Info M
on sc.user_id = M.eb_user_id
where
	format(sc.create_time, 'yyyy-MM-dd') = @dt
END


GO
