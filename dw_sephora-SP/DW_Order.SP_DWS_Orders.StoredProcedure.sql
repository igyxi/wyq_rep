/****** Object:  StoredProcedure [DW_Order].[SP_DWS_Orders]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Order].[SP_DWS_Orders] AS
BEGIN
truncate table DW_Order.DWS_Orders;
insert into DW_Order.DWS_Orders
    select 
        a.order_id,
        case when merge_oid is null then a.order_id else b.merge_oid end as merge_oid,
        c.sku_id,
        c.skucode as item_sku_code,
        CURRENT_TIMESTAMP
    from  
        [STG_Order].[Orders] a
    left join
        STG_Order.OrderItems c
    on a.order_id = c.order_id
    left join 
    (
        select distinct oid, merge_oid from STG_Order.Merge_Order where [current] = 1 
    ) b 
    on a.order_id = b.oid
END
GO
