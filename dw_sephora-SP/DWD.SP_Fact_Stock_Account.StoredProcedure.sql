/****** Object:  StoredProcedure [DWD].[SP_Fact_Stock_Account]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Stock_Account] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-15       lizeyuan           Initial Version
-- ========================================================================================
truncate table DWD.Fact_Stock_Account;
insert into DWD.Fact_Stock_Account
select 
    account.id
    ,warehouse.code warehouse_code
    ,warehouse.name warehouse_name
    ,waretype.code wharetype_code
    ,waretype.name wharetype_name
    ,spu.code product_id
    ,spu.englishname product_name
    ,spu.name product_name_cn
    ,sku.code sku_code
    ,sku.name sku_name
	,account.qty 
	,account.qty_lock
	,account.qty_tran
	,account.qty_hold
	,account.qty_hold_flag
	,account.qty_loss
    ,account.create_time
	,current_timestamp as insert_timestamp
from
	[ODS_IMS].[STK_Stock_Account] account
left join
(
    select 
        id,code,name 
    from
	    [ODS_IMS].[Bas_Warehouse] 
        group by id,code,name
)warehouse
on account.warehouse_id = warehouse.id
left join
(
    select 
        id,code,name 
    from
	    [ODS_IMS].[BAS_Storehouse]
    group by id,code,name
)waretype
on account.wharetype_id = waretype.id
left join 
(
    select 
        id,code,name,englishname 
    from
	    [ODS_IMS].[GDS_Btgoods] 
    group by id,code,name,englishname
)spu
on account.goods_id = spu.id
left join 
(
    select 
        id,code,name 
    from
	    [ODS_IMS].[GDS_Btsinglprodu]
    where status = '09'
    group by id,code,name
) sku
on account.singleproduct_id = sku.id
END
GO
