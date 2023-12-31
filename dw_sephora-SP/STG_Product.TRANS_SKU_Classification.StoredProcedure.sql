/****** Object:  StoredProcedure [STG_Product].[TRANS_SKU_Classification]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_SKU_Classification] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-22       tali           Initial Version
-- 2022-09-05       tali           fix duplicate sku_code for skincare and hair
-- ========================================================================================
truncate table STG_Product.SKU_Classification;
insert into STG_Product.SKU_Classification
select 
    sku_code,
    trim(sku_name),
    trim(brand),
    category,
    trim(Franchise),
    trim([Range]),
    trim(Segment),
    trim(Sub_Segment),
    trim(First_Function),
    trim(Second_Function),
    CURRENT_TIMESTAMP 
from
(
    select 
        [mat.] as sku_code, 
        [Description] as sku_name, 
        [Brand description] as brand, 
        'HAIR' as category,
        Franchise, 
        [Range], 
        Segment, 
        [Sub Segment] as Sub_Segment, 
        [First Function] as First_Function, 
        [Second Function (Option Item)] as Second_Function 
    from 
        Manual_SAP.Hair_Classification 
    where 
        [mat.] is not null
    union all
    select 
        [mat.] as sku_code, 
        [Description] as sku_name, 
        [Brand description] as brand,
        'FRAGRANCE' as category,
        Franchise, 
        [Range], 
        Segment, 
        [Sub Segment] as Sub_Segment, 
        null as First_Function, 
        null as Second_Function 
    from 
        Manual_SAP.Fragrance_Classification 
    where 
        [mat.] is not null
    union all 
    select 
        [mat.] as sku_code, 
        [Description] as sku_name, 
        [Brand description] as brand,
        'MAKEUP' as category,
        Franchise, 
        Range2, 
        Segment2, 
        null as Sub_Segment, 
        null as First_Function, 
        null as Second_Function 
    from 
        Manual_SAP.Makeup_Classification 
    where 
        [mat.] is not null
    union all
    select 
        a.[mat.] as sku_code, 
        a.[Description] as sku_name, 
        a.[Brand description] as brand, 
        'SKINCARE' as category,
        a.Franchise, 
        a.[Range], 
        a.Segment, 
        a.[Sub Segment] as Sub_Segment, 
        a.[First Function] as First_Function, 
        a.[Second Function (Option Item)] as Second_Function 
    from 
        Manual_SAP.Skin_Care_Classification a
    left join
        Manual_SAP.Hair_Classification b
    on a.[mat.] = b.[mat.]
    where 
        a.[mat.] is not null 
    and b.[Mat.] is null
) t
END

GO
