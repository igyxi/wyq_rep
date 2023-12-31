/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Events_ShoppingCart_Latest_Login]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Events_ShoppingCart_Latest_Login] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-09       wangzhichun        Initial Version
-- ========================================================================================
truncate table [DW_Sensor].[DWS_Events_ShoppingCart_Latest_Login] 
INSERT INTO [DW_Sensor].[DWS_Events_ShoppingCart_Latest_Login]
select
    vip_card,platform_type,Max(date) as latest_login_date
From 
    [DW_Sensor].[DWS_Events_Session_Cutby30m]
where 
    year([date])='2022'----取一年的数据
and [event] in ('AddToShoppingcart','startAddToShoppingcart')----包含加购事件
and vip_card is not null---只要有用户卡号的行为
group by 
    vip_card,
    platform_type;
end 
GO
