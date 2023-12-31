/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_MNP_APP_Buyers_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_MNP_APP_Buyers_Monthly] @dt [VARCHAR](10) AS 
begin
--用户各渠道下下单人数以及交叉下单人数
delete from [DW_OMS].[RPT_MNP_APP_Buyers_Monthly] where statics_month>=cast(cast(dateadd(month,-1,@dt) as date) as varchar(7));
insert into [DW_OMS].[RPT_MNP_APP_Buyers_Monthly]
select 
    statics_month,
    count(distinct cross_card_no) as cross_buyers,
    count(distinct mnp_card_no) as cross_buyers,
    count(distinct app_card_no) as cross_buyers,
    current_timestamp as insert_timestamp
from DW_OMS.RPT_MNP_APP_Buyer_Monthly
where statics_month>=cast(cast(dateadd(month,-1,@dt) as date) as varchar(7))
group by 
    statics_month;
UPDATE STATISTICS DW_OMS.RPT_MNP_APP_Buyers_Monthly;
end

GO
