/****** Object:  StoredProcedure [TEST].[create_item_table]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[create_item_table] AS
BEGIN 
create table [ODS_OMS].[Sales_Order_Item] 
with (
    DISTRIBUTION = hash(sales_order_sys_id),	
	CLUSTERED COLUMNSTORE INDEX
) as
select * from [ODS_OMS].[Sales_Order_Item_bk]
end
GO
