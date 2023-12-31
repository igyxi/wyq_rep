/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_MNP_APP_Buyers_With_Card_Grade_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_MNP_APP_Buyers_With_Card_Grade_Monthly] @dt [VARCHAR](10) AS 
begin
----用户交叉渠道不同卡别下单人数
delete from [DW_OMS].[RPT_MNP_APP_Buyers_With_Card_Grade_Monthly] where statics_month>=cast(cast(dateadd(month,-1,@dt) as date) as varchar(7));
insert into [DW_OMS].[RPT_MNP_APP_Buyers_With_Card_Grade_Monthly]
select 
    statics_month,
    count(distinct cross_card_no) as cross_buyers,
    card_grade as card_grade,
    current_timestamp as insert_timestamp
from DW_OMS.RPT_MNP_APP_Buyer_Monthly
where statics_month>=cast(cast(dateadd(month,-1,@dt) as date) as varchar(7))
group by 
    statics_month,
    card_grade;
UPDATE STATISTICS DW_OMS.RPT_MNP_APP_Buyers_With_Card_Grade_Monthly;
end 
GO
