/****** Object:  StoredProcedure [ODS_SAP].[Correct_transfer_order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SAP].[Correct_transfer_order] AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here

select * into STG.[PO_Transfer_Order_V2] from (select 
*,
RANK() over(partition by order_Number order by filedatekey desc) as rn
from ODS.[PO_Transfer_Order](nolock)) as CTE where rn=1

END
GO
