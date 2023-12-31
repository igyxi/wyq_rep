/****** Object:  StoredProcedure [promo_analysis].[sp_dim_pos_discount_calendar]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [promo_analysis].[sp_dim_pos_discount_calendar] AS 
begin 
truncate table promo_analysis.dim_pos_discount_calendar;
insert into promo_analysis.dim_pos_discount_calendar
select 
distinct szDiscountID,szDiscDesc,szDiscValueType,dDiscValue,start_date,end_date
from (
select lDiscListType,szDiscountType,szDiscValueType,szDiscDesc,dDiscValue,szDiscountID,start_date,end_date,order_count,row_number() over(partition by szDiscountID order by start_date,end_date,order_count desc)  as rn
from (
select   lDiscListType,szDiscountType,szDiscValueType,szDiscDesc,dDiscValue,szDiscountID,min(Hdr_szTaCreatedDate) start_date,max(Hdr_szTaCreatedDate) end_date,count(distinct szBarcodeComplete) order_count
from [ODS_POS].[TLOG_DISC_INFO]
where Hdr_szTaCreatedDate>='20200101'and szArtDptNmbr is not null
and szDiscountID is not null 
--and szDiscountID='201903011123'
group by  lDiscListType,szDiscountType,szDiscValueType,szDiscDesc,dDiscValue,szDiscountID
) a
) temp
where rn=1
end
GO
