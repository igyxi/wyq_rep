/****** Object:  StoredProcedure [DW_OMS].[SP_DW_Sales_Order_With_SKU_His]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DW_Sales_Order_With_SKU_His] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-14       tali           Initial Version
-- 2022-03-18       tali           change the member_card logic for jd
-- 2022-03-21       tali           change the logic for item_sku_name
-- 2022-03-21       tali           filter dupilcate in purchase_to_sap
-- 2022-03-30       tali           add province city mapping
-- 2022-04-18       tali           replace char(160) for sku_code
-- 2022-05-19       tali           add district
-- 2022-05-30       wangzhichun    add smartba_flag
-- 2022-07-14       tali           change logic
-- 2022-07-25       tali           fix purchase_order_item
-- 2022-08-18       tali           fix vb_sku_rel
-- 2022-09-08       tali           delete bind_quantity
-- 2022-09-20       tali           add trp001 as shipping sku
-- 2022-09-29       tali           update smartba_flag
-- 2022-12-10       tali           update the OMS_Province_City_Mapping
-- 2023-02-20       houshuangqiang add sales_order_sys_id/basic_status/merge_flag
-- 2023-02-21       houshuangqiang add payment_amount/logistics_company/logistics_number & filter basic_status <> 'DELETED'
-- 2023-03-14       houshuangqiang 取消so单中basic_status <> 'DELETED'的限制，因为ps两张报表数据切换数据源时，影响到这边的数据了
-- 2023-05-06       zhailonglong   add sys_create_time & add sys_update_time
-- 2023-05-10       houshuangqiang 与new oms 对数的逻辑。add stg_oms.oms_to_oims_sync_fail_log
-- ========================================================================================
DECLARE @start_time datetime = null;
DECLARE @end_time datetime = null;
select
    -- get max timestamp of the day before
    @start_time = start_time,
    @end_time = end_time
from
(
   select top 1 start_time, end_time from [DW_OMS_Order].[DW_Datetime_Config] where is_delete = '0'  order by start_time desc
) t
;

truncate table DW_OMS.DW_Sales_Order_With_SKU_His;
insert into DW_OMS.DW_Sales_Order_With_SKU_His
select p.*
from   DW_OMS.DW_Sales_Order_With_SKU p 
inner join stg_oms.oms_to_oims_sync_fail_log fail 
on    p.sales_order_number = fail.sales_order_number
and fail.sync_status = 1
and fail.update_time >= @start_time
and fail.update_time <= @end_time

END
GO
