/****** Object:  StoredProcedure [DW_CRM].[SP_DIM_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_CRM].[SP_DIM_SKU] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-21       tali           Initial Version
-- 2022-05-12       tali	       update is_offer
-- ========================================================================================
truncate table DW_CRM.DIM_SKU;
insert into DW_CRM.DIM_SKU
select 
    p.crm_product_id as sku_id,
    p.sku sku_code,
    replace(p.product_name,' ','') as sku_name,
	p.product_name_en as sku_name_en,
	s.Market as brand_type,
    pb.brand_code,
	s.Brand,
	s.Category,
	s.Target,
	s.[Range],
	s.[Segment],
	s.skincare_function,
	s.product_line,
	p.cost price,
    -- s.rsp,
	case when s.Target='MEN' and s.Category in ('FRAGRANCE','SKINCARE') then 1 else 0 end is_men,
    case when f.sku is not null then 1 else 0 end is_offer,
    current_timestamp  as insert_timestamp
from 
	ODS_CRM.crm_product p
left join
    ODS_CRM.product_brand pb 
on p.product_brand_id = pb.product_brand_id
left join
(
    select distinct sku from ODS_CRM.offer where source_offer_id is null
)f
on p.sku = f.sku
left join
(
	select
        sku,
		Market,
		Brand,
		Category,
		[Target],
		[Range],
		[Segment],
		[Skincare - Function] as skincare_function,
		[Product - Line] as product_line,
        RSP,
        row_number() over(partition by sku order by Brand desc, Market desc, category desc) as rownum
	from 
        ODS_CRM.spss_sku
) s
on p.sku=s.sku
and s.rownum = 1
;
end

GO
