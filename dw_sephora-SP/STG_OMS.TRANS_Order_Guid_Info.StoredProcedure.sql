/****** Object:  StoredProcedure [STG_OMS].[TRANS_Order_Guid_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Order_Guid_Info] AS
BEGIN
truncate table STG_OMS.Order_Guid_Info;
insert into STG_OMS.Order_Guid_Info
select distinct 
    a.sales_order_sys_id,
    b.mobile_id as mobile_guid,
    current_timestamp as insert_timestamp
from
(
    select
        sales_order_sys_id,
    --  if(mobile='37a6259cc0c1dae299a7866489dff0bd',if(pohone='37a6259cc0c1dae299a7866489dff0bd',null,pohone),mobile) as mobile_md5
        case when mobile <> '37A6259CC0C1DAE299A7866489DFF0BD' then mobile 
             when pohone <> '37A6259CC0C1DAE299A7866489DFF0BD' then pohone 
             else null
        end as mobile_md5,
        row_number() over(partition by sales_order_sys_id order by dt desc) rownum
    from
        ODS_OMS.sales_order_address 
    where 
        is_delete = 0
)a
join
    [ODS_OMS].mobile_mapping b
on
    a.mobile_md5 = b.mobile_md5
where a.rownum = 1
END



GO
