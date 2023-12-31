/****** Object:  StoredProcedure [STG_CMS].[TRANS_DP_IQ_FD_Record]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_CMS].[TRANS_DP_IQ_FD_Record] AS
BEGIN
truncate table STG_CMS.DP_IQ_FD_Record;
insert into STG_CMS.DP_IQ_FD_Record
select
	id,
    case when trim(cardno) in ('','null') then null else trim(cardno) end as cardno,
    case when trim(coverage) in ('','null') then null else trim(coverage) end as coverage,
    case when trim(benefit) in ('','null') then null else trim(benefit) end as benefit,
    case when trim(finish) in ('','null') then null else trim(finish) end as finish,
    case when trim(format) in ('','null') then null else trim(format) end as format,
    case when trim(sunprotection) in ('','null') then null else trim(sunprotection) end as sunprotection,
    case when trim(source) in ('','null') then null else trim(source) end as source,
    case when trim(skucode1) in ('','null') then null else trim(skucode1) end as skucode1,
    case when trim(skucode2) in ('','null') then null else trim(skucode2) end as skucode2,
    case when trim(skucode3) in ('','null') then null else trim(skucode3) end as skucode3,
    question_time,
    current_timestamp insert_timestamp
from 
(
     select *, row_number() over(partition by id order by dt desc) rownum from ODS_CMS.DP_IQ_FD_Record 
)t
where rownum = 1;
END
GO
