/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_Order_Deatil_BK_20220823]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_Order_Deatil_BK_20220823] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       mac             delete 'COLLATE Chinese_PRC_CS_AI_WS'
-- ========================================================================================
truncate table [DW_SmartBA].[RPT_SmartBA_Order_Deatil_new];
with employee_info as
(
    select 
        c.userid,
        a.employeecode,
        a.bindingtime, 
        row_number() over(partition by c.userid, a.employeecode order by a.bindingtime) rn
    from
    (
        select distinct unionid,employeecode,bindingtime from [DW_SmartBA].[DWS_BA_Customer_REL]
    ) a
    left join 
    (
        select distinct unionid, openid from [STG_WechatCenter].[Wechat_Register_Info]
    ) b
    on a.unionid = b.unionid
    left join
    (
        select distinct openid, userid from [STG_WechatCenter].[Wechat_Bind_Mobile_List]
    )c
    on b.openid = c.openid
    where c.userid is not null
) 

insert into  [DW_SmartBA].[RPT_SmartBA_Order_Deatil_new]
select
    a.sales_order_number,
    a.utm_content,
    'MINIPROGRAM' as channel_cd,
    b.province,
    b.city,
    a.order_time,
    a.payment_time,
    b.type_cd,
    a.item_sku_cd,
    coalesce(c.main_cd, c2.main_cd) as item_main_cd,
    c.sku_name_cn  as item_name,
    a.item_quantity,
    a.item_apportion_amount,    
	coalesce(trim(c.brand_name), c2.brand) as item_brand_name,
    coalesce(c.brand_type, c2.brand_type) item_brand_type,
    coalesce(c.category, c2.category) item_category,
    c.segment,
    case when CHARINDEX('VB',a.item_sku_cd)=1 or CHARINDEX('VS',a.item_sku_cd)=1 then 'Y' else 'N' end as vb_flag,
    a.member_card,
    a.member_card_grade,
    case when b.all_order_placed_seq = 1 and b.member_card_grade = 'PINK' then 'Brand New'
         when b.all_order_placed_seq = 1 and b.member_card_grade <> 'PINK' then 'Convert New'
         else 'Return'
    end as new_to_eb_cd,
    case when b.channel_order_placed_seq = 1 then 'New' else 'Return' end as new_to_mnp_cd,
    case when e.userid is not null and e.bindingtime <= a.order_time then 1 else 0 end as is_checked_unionid,
    a.utm_term,
    a.utm_content,
    d.store_name ,
    d.region ,
    d.subregion ,
    d.district ,
    d.city ,
    current_timestamp as insert_timestamp
from
(
    select
        *
    from
        [DW_SmartBA].[RPT_SmartBA_Orders_VB_Level]
)a
inner join 
    (select * from [DW_OMS].[RPT_Sales_Order_VB_Level] where is_placed_flag=1) b
on 
    a.sales_order_number = b.sales_order_number
	and a.item_sku_cd=b.item_sku_cd
left join
  [DW_Product].[DWS_SKU_Profile] c
on 
    a.item_sku_cd = c.sku_cd
left join
        STG_Product.SKU_Mapping c2
on 
    a.item_sku_cd = c2.sku_cd
left join
    [ODS_CRM].[DimStore] d
on 
    a.utm_content = d.store_code 
left join
    employee_info e
on
    a.member_id = e.userid
and 
    a.utm_term = e.employeecode
and 
    e.rn=1
;
end
GO
