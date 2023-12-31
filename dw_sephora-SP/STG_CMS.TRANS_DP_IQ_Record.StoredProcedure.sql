/****** Object:  StoredProcedure [STG_CMS].[TRANS_DP_IQ_Record]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_CMS].[TRANS_DP_IQ_Record] AS
BEGIN
truncate table STG_CMS.DP_IQ_Record;
insert into STG_CMS.DP_IQ_Record
select
	id,
    case when trim(cardno) in ('','null') then null else trim(cardno) end as cardno,
    case when trim(level) in ('','null') then null else trim(level) end as level,
    case when trim(nickname) in ('','null') then null else trim(nickname) end as nickname,
    case when trim(channel) in ('','null') then null else trim(channel) end as channel,
    case when trim(gender) in ('','null') then null else trim(gender) end as gender,
    case when trim(family) in ('','null') then null else trim(family) end as family,
    case when trim(intensity) in ('','null') then null else trim(intensity) end as intensity,
    case when trim(impression) in ('','null') then null else trim(impression) end as impression,
    case when trim(product_type) in ('','null') then null else trim(product_type) end as product_type,
    case when trim(sample_sku_code) in ('','null') then null else trim(sample_sku_code) end as sample_sku_code,
    question_time,
    get_coupon_time,
    case when trim(source) in ('','null') then null else trim(sample_sku_code) end as sample_sku_code,
    case when trim(skucode1) in ('','null') then null else trim(skucode1) end as skucode1,
    case when trim(skucode2) in ('','null') then null else trim(skucode2) end as skucode2,
    case when trim(skucode3) in ('','null') then null else trim(skucode3) end as skucode3,
    current_timestamp insert_timestamp

from 
(
     select *, row_number() over(partition by id order by dt desc) rownum from ODS_CMS.DP_IQ_Record
)t
where rownum = 1;
END
GO
