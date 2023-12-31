/****** Object:  StoredProcedure [TEST].[SP_TBL_Sales_VS_LY_By_Brand_Type_Category]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_TBL_Sales_VS_LY_By_Brand_Type_Category] @dt [date] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-16     litao        Initial Version
-- ========================================================================================

DECLARE @start_date DATE
DECLARE @end_date DATE
DECLARE @ly_start_date DATE
DECLARE @ly_end_date DATE
DECLARE @bly_start_date DATE
DECLARE @bly_end_date DATE

--DECLARE @dt DATE
--set @dt='2023-04-30';
set @start_date=DATEADD(DAY,1, EOMONTH (DATEADD(MONTH,-1,@dt)));
set @end_date=@dt;
set @ly_start_date=DATEADD(DAY,1, EOMONTH (DATEADD(MONTH,-13,@dt)));
set @ly_end_date=DATEADD(yy,-1,@dt);
set @bly_start_date=DATEADD(DAY,1, EOMONTH (DATEADD(MONTH,-25,@dt)));
set @bly_end_date=DATEADD(yy,-2,@dt);
--select @end_date,@start_date,@ly_start_date,@ly_end_date,@bly_start_date,@bly_end_date;



--truncate table [test].[TBL_Sales_VS_LY_By_Brand_Type_Category];
delete from [test].[TBL_Sales_VS_LY_By_Brand_Type_Category] where dt_day=DATEADD(DAY,1,@end_date);
with sales_detail as
(
select
	cast((cast(a.Date_Key as nvarchar(10))) as date) as datekey,
	a.Date_Key,
	a.Store_Code,
	a.Material_Code,
	a.Transaction_No,
	a.Sales_VAT,
	a.Sales_VAT/1.13 as Sales_Excl_VAT,
	a.Quantity,
	a.COGS,
	case
		when b.e_channel = 'Retail' then 'Retail'
		else 'Web'
	end as e_channel,
	case when c.LocalMarket in ('MASS MARKET','SELECTIVE','STORE SUPPLIES','OTHERS') then 'Selective' 
	     when c.LocalMarket='EXCLUSIVE' then 'Exclusive'
		 when c.LocalMarket='SEPHORA' then 'Sephora'
		 when c.LocalMarket is null or c.LocalMarket='' then 'Selective'
		 else c.LocalMarket end as brand_type,
    --case when c.SalesCategoryName in ('Services','IFLS CODES','Skin Care','PERFUME SAMPLES','PLV') then 'SkinCare'
	--     when c.SalesCategoryName in ('FRAGRANCE ACCESS','HAIR ACCESSORIES','MAKE UP ACCESSORIES','SKINCARE ACCESSORIES') then 'Accessories'
    --     when c.SalesCategoryName in ('MAKE UP') then 'Make Up'
	--	 when c.SalesCategoryName in ('FRAGRANCE') then 'Fragrance'
	--	 when c.SalesCategoryName in ('Bath Care') then 'Bath & Gift'
	--	 when c.SalesCategoryName in ('HAIR') then 'Hair'
	--	 when c.SalesCategoryName in ('WELLNESS') then 'Wellness' 
	--else c.SalesCategoryName end as catygory
    --case when c.Category_Description in ('SERVICES','PERFUME SAMPLES','PLV','SKINCARE','IFLS CODES') then 'Skincare'
	--     when c.Category_Description in ('FRAGRANCE ACCESS','HAIR ACCESSORIES','MAKE UP ACCESSORIES','SKINCARE ACCESSORIES') then 'Accessories'
	--     when c.Category_Description in ('MAKE UP') then 'Make Up'
	--	 when c.Category_Description in ('FRAGRANCE') then 'Fragrance'
	--	 when c.Category_Description in ('BATH & GIFT') then 'Bath & Gift'
	--	 when c.Category_Description in ('HAIR') then 'Hair'
	--	 when c.Category_Description in ('WELLNESS') then 'Wellness'
	--else c.Category_Description
	--end as catygory, 
	case when c.Category_Description in ('SERVICES','PLV','SKINCARE','IFLS CODES','WELLNESS') then 'Skincare'
	     when c.Category_Description in ('FRAGRANCE ACCESS','HAIR ACCESSORIES','MAKE UP ACCESSORIES','SKINCARE ACCESSORIES') then 'Accessories'
	     when c.Category_Description in ('MAKE UP') then 'Make Up'
		 when c.Category_Description in ('FRAGRANCE','PERFUME SAMPLES','FRAGRANCE TESTER') then 'Fragrance' 
		 when c.Category_Description in ('BATH & GIFT') then 'Bath & Gift'
		 when c.Category_Description in ('HAIR') then 'Hair'
		 when c.Category_Description is null then 'Skincare'
	else c.Category_Description
	end as catygory
from
	[DW_SAP].[view_Fact_Sales] a
left join 
    [DW_SAP].[view_Dim_store] b 
on
	a.Store_Code = b.Store_Code
left join 
    [DW_SAP].[view_Dim_Material] c
on
	a.Material_Code = c.Material_Code
where 
  b.Country_Code='CN'
)
,
--act_sales
act_sales as 
(
select 
  DATEADD(DAY,1,@end_date) as dt_day,
  channel,
  'Brand_Type' as flag1,
  brand_type   as flag2,
  act_sales_vat,
  act_sales_vat_lym,
  act_sales_vat_lyym,
  act_sales_excl_vat,
  act_sales_excl_vat_lym,
  act_gross_profit,
  act_gross_profit_lym
from 
(
select
	e_channel as channel,
	brand_type,
	round(sum(case when datekey between @start_date and @end_date then sales_vat else 0 end), 0) as act_sales_vat,
	round(sum(case when datekey between @start_date and @end_date then sales_excl_vat else 0 end), 0) as act_sales_excl_vat,
	round(sum(case when datekey between @start_date and @end_date then cogs else 0 end), 0) as act_cogs,
	round(sum(case when datekey between @start_date and @end_date then sales_excl_vat else 0 end), 0)-round(sum(case when datekey between @start_date and @end_date then cogs else 0 end), 0) as act_gross_profit,
    round(sum(case when datekey between @ly_start_date and @ly_end_date then sales_vat else 0 end), 0) as act_sales_vat_lym,
	round(sum(case when datekey between @ly_start_date and @ly_end_date then sales_excl_vat else 0 end), 0) as act_sales_excl_vat_lym,
	round(sum(case when datekey between @ly_start_date and @ly_end_date then cogs else 0 end), 0) as act_cogs_lym,
	round(sum(case when datekey between @ly_start_date and @ly_end_date then sales_excl_vat else 0 end), 0)-round(sum(case when datekey between @ly_start_date and @ly_end_date then cogs else 0 end), 0) as act_gross_profit_lym,
    round(sum(case when datekey between @bly_start_date and @bly_end_date then sales_vat else 0 end), 0) as act_sales_vat_lyym,
	round(sum(case when datekey between @bly_start_date and @bly_end_date then sales_excl_vat else 0 end), 0) as act_sales_excl_vat_lyym,
	round(sum(case when datekey between @bly_start_date and @bly_end_date then cogs else 0 end), 0) as act_cogs_lyym,
	round(sum(case when datekey between @bly_start_date and @bly_end_date then sales_excl_vat else 0 end), 0)-round(sum(case when datekey between @bly_start_date and @bly_end_date then cogs else 0 end), 0) as act_gross_profit_lyym
from
	sales_detail 
where (datekey between @start_date and @end_date) 
   or (datekey between @ly_start_date and @ly_end_date)
   or (datekey between @bly_start_date and @bly_end_date)
group by
	e_channel,
	brand_type
) t1 
union all
select 
  DATEADD(DAY,1,@end_date) as dt_day,
  channel,
  'Category' as flag1,
  catygory   as flag2,
  act_sales_vat,
  act_sales_vat_lym,
  act_sales_vat_lyym,
  act_sales_excl_vat,
  act_sales_excl_vat_lym,
  act_gross_profit,
  act_gross_profit_lym
from 
(
select
	e_channel as channel,
	catygory,
	round(sum(case when datekey between @start_date and @end_date then sales_vat else 0 end), 0) as act_sales_vat,
	round(sum(case when datekey between @start_date and @end_date then sales_excl_vat else 0 end), 0) as act_sales_excl_vat,
	round(sum(case when datekey between @start_date and @end_date then cogs else 0 end), 0) as act_cogs,
	round(sum(case when datekey between @start_date and @end_date then sales_excl_vat else 0 end), 0)-round(sum(case when datekey between @start_date and @end_date then cogs else 0 end), 0) as act_gross_profit,
    round(sum(case when datekey between @ly_start_date and @ly_end_date then sales_vat else 0 end), 0) as act_sales_vat_lym,
	round(sum(case when datekey between @ly_start_date and @ly_end_date then sales_excl_vat else 0 end), 0) as act_sales_excl_vat_lym,
	round(sum(case when datekey between @ly_start_date and @ly_end_date then cogs else 0 end), 0) as act_cogs_lym,
	round(sum(case when datekey between @ly_start_date and @ly_end_date then sales_excl_vat else 0 end), 0)-round(sum(case when datekey between @ly_start_date and @ly_end_date then cogs else 0 end), 0) as act_gross_profit_lym,
    round(sum(case when datekey between @bly_start_date and @bly_end_date then sales_vat else 0 end), 0) as act_sales_vat_lyym,
	round(sum(case when datekey between @bly_start_date and @bly_end_date then sales_excl_vat else 0 end), 0) as act_sales_excl_vat_lyym,
	round(sum(case when datekey between @bly_start_date and @bly_end_date then cogs else 0 end), 0) as act_cogs_lyym,
	round(sum(case when datekey between @bly_start_date and @bly_end_date then sales_excl_vat else 0 end), 0)-round(sum(case when datekey between @bly_start_date and @bly_end_date then cogs else 0 end), 0) as act_gross_profit_lyym
from
	sales_detail
where (datekey between @start_date and @end_date) 
   or (datekey between @ly_start_date and @ly_end_date)
   or (datekey between @bly_start_date and @bly_end_date)
   
group by
	e_channel,
	catygory
) t1
) 
,
--R1 Sales
r1_sales as 
(
select 
  *
from 
  [test].[TBL_Manual_BUD_R1_Sales]
where group2='R1'
  and date_month=format(@start_date, 'yyyy-MM')
)
,
--BUD Sales
bud_sales as 
(
select 
  *
from 
  [test].[TBL_Manual_BUD_R1_Sales]
where group2='BUD' 
  and date_month=format(@start_date, 'yyyy-MM')
) 


insert into [test].[TBL_Sales_VS_LY_By_Brand_Type_Category]
select
	act.dt_day,
	act.channel,
	act.flag1,
	act.flag2,
	act.act_sales_vat/1000000,
	act.act_sales_vat_lym/1000000,
	act.act_sales_vat_lyym/1000000,
	act.act_sales_excl_vat/1000000,
	act.act_sales_excl_vat_lym/1000000,
	act.act_gross_profit/1000000,
	act.act_gross_profit_lym/1000000,
    round(bud.sales,0)/1000 as bud_sales,
	round(bud.margin,0)/1000 as bud_gross_profit,
	round(r1.sales,0)/1000 as r1_sales,
	round(r1.margin,0)/1000 as r1_gross_profit,
	null as r2_sales ,
	null as r2_gross_profit,
	1.13 as rate,
	concat(@start_date, '~', @end_date) as date_range,
	current_timestamp as insert_timestamp
from
	act_sales act
left join 
   r1_sales r1
on
	act.flag1 = r1.group1
	and act.channel = r1.group3
	and act.flag2 = r1.type1
left join 
   bud_sales bud 
on
	act.flag1 = bud.group1
	and act.channel = bud.group3
	and act.flag2 = bud.type1
;

END
GO
