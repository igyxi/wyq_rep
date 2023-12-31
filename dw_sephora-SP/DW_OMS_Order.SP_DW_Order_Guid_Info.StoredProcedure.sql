/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_Order_Guid_Info]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_Order_Guid_Info] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-26       houshuangqiang     从老OMS中切换至new oms中数据(老逻辑为：STG_OMS.TRANS_Order_Guid_Info)
-- ----------------------------------------------------------------------------------------
truncate table DW_OMS_Order.DW_Order_Guid_Info;
insert into DW_OMS_Order.DW_Order_Guid_Info
select distinct
    a.sales_order_number,
    b.mobile_id as mobile_guid,
    current_timestamp as insert_timestamp
from
(
    select
        tid as sales_order_number,
        case when receiver_mobile <> '37A6259CC0C1DAE299A7866489DFF0BD' then receiver_mobile
             when receiver_phone <> '37A6259CC0C1DAE299A7866489DFF0BD' then receiver_phone
             else null
        end as mobile_md5,
        row_number() over(partition by tid order by dt desc) rownum
    from    ODS_OMS_Order.OMS_STD_Trade
)a
join DW_OMS_Order.DW_Mobile_Mapping b
on   a.mobile_md5 = b.mobile_md5
where a.rownum = 1
END
GO
