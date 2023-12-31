/****** Object:  StoredProcedure [RPT].[SP_RPT_Order_VB_SO_Level]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Order_VB_SO_Level] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-04       litao           Initial Version
-- 2022-12-07       litao           Modify sku_name,brand_name,brand_type,category
-- 2023-03-16       litao           add super_id Change Region add offline order
-- 2023-03-24       litao           Platform = ‘DOUYIN’ AND member_card is null时，请将super_id修改成‘member_id’+‘province’+’city’，例如：member_id = ‘王先生’，province = ‘江苏’，city=’苏州’，则super_id = ‘王先生江苏苏州’
-- ========================================================================================
truncate table RPT.RPT_Order_VB_SO_Level;
insert into RPT.RPT_Order_VB_SO_Level
select a.sales_order_number       as sales_order_number,
       'EB'                       as business_channel, 
       case when a.channel_code = 'SOA' then 'DRAGON' 
            when a.channel_code = 'DOUYIN' then 'TIKTOK'
       else a.channel_code end as Platform,
       case when a.sub_channel_code in ('JD001','JD002') then 'JD_FSS'
            when a.sub_channel_code = 'JD003' then 'JD_FCS'
            when a.sub_channel_code = 'TMALL001' then 'TMALL_SEPHORA'
            when a.sub_channel_code = 'TMALL004' then 'TMALL_CHALING'
            when a.sub_channel_code = 'TMALL005' then 'TMALL_PTR'
            when a.sub_channel_code = 'TMALL006' then 'TMALL_WEI'
            when a.sub_channel_code = 'DOUYIN001' then 'TIKTOK'
            when a.sub_channel_code like 'APP%' then 'APP'
            when a.sub_channel_code like '%MINIPROGRAM' or a.sub_channel_code = 'WECHAT' then 'MNP/WECHAT'
            when a.sub_channel_code in ('PC','WCS','MOBILE') then 'PC/MOBILE'
       else a.sub_channel_code end as channel,
       null                       as store_code, --暂空
       null                       as store_name, --暂空
       null                       as ba, --暂空
       case when a.Province in (N'香港',N'澳门',N'台湾') then  'South region'
            when a.Province in (N'西藏') then  'West region'
       else c.nso_greatregion end as region,
       a.province                 as province,  --收货地址省
       a.city                     as city,      --收货地址市
       a.district                 as district,  --收货地址区
       a.member_card              as member_card_number,
       coalesce(upper(a.member_card_grade),upper(e.member_card_grade)) as member_card_grade,
       case when d.tmall_sephora_campaign_flag = 1 or d.tmall_wei_campaign_flag = 1 or d.jd_campaign_flag = 1 then 1 else 0 end as Day_type,
       null                       as campaign_description, --暂空
       a.place_date               as transaction_date,
       a.place_time               as transaction_time,
       a.smartba_flag             as is_smartba,
       a.item_sku_code            as SKU_Code,
    --    a.item_main_code           as main_cd,
       case when left(a.item_sku_code,2) = 'vs' then a.item_main_code
            when left(a.item_sku_code,2) <> 'vs' then a.item_sku_code
            end as Main_Code, --修改点
       case when left(a.item_sku_code,2) = 'vs' then a.item_name
            when left(a.item_sku_code,2) <> 'vs' then b.eb_sku_name_cn
            end as sku_name, --修改点
    --    b.eb_sku_name_cn           as sku_name, 
     -- b.eb_brand_name            as brand_name,  
       case when b.eb_brand_name = 'MENARD SP' then 'NIIPON MENARD' else b.eb_brand_name end as Brand_Name,
       b.eb_brand_type            as brand_type, 
       b.eb_category              as category,
       b.range                    as range,
       b.segment                  as segment,
       b.sap_target_description   as target_gender,
       b.first_function           as first_function,
       null                       as promotion_id,
       null                       as promotion_content,
       null                       as promotion_offer,
       null                       as coupon_code, --暂空
       a.item_quantity            as item_quantity,
       a.item_sale_price          as item_price,
       a.item_adjustment_unit     as item_discount,
       a.item_apportion_amount    as item_sales,
       null                       as item_cost, --暂空
       case when a.channel_code = 'DOUYIN' 
             and a.member_card  is null 
             and a.member_id is not null
             and a.province is not null 
             and a.city is not null 
            then concat(a.member_id,a.province,a.city)
         else coalesce(a.member_card,a.member_id)
       end as super_id,--新增super_id
       a.is_placed                as is_placed,
       CURRENT_TIMESTAMP as insert_timestamp
  from 
    rpt.rpt_sales_order_vb_level a
  left join 
    dwd.dim_sku_info b 
  on case when left(a.item_sku_code,2) = 'vs' then a.item_main_code
        when left(a.item_sku_code,2) <> 'vs' then a.item_sku_code
        end = b.sku_code
  left join (
             select distinct nso_province,nso_greatregion
             from dwd.dim_store
             where nso_province is not null 
              and nso_greatregion is not null
            ) c 
  on a.province = c.nso_province
  left join (
             select distinct tmall_sephora_campaign_flag,
                             tmall_wei_campaign_flag,
                             jd_campaign_flag,
                             date_str
             from dwd.dim_calendar
             ) d 
  on a.place_date = d.date_str
  left join (
            select member_card,
                   substring(card_type_name,3,100) as member_card_grade,
                   start_time,
                   end_time 
            from dwd.dim_member_card_grade_scd  --补充缺失的member_card_grade
            ) e 
  on a.member_card = e.member_card 
  and a.place_time >= e.start_time 
  and a.place_time < e.end_time
 where a.is_placed = 1
union all 
select 
    Sales_Order_Number,
    Business_Channel,
    Platform,
    Channel,
    Store_Code,
    Store_Name,
    BA,
    Region,
    Province,
    City,
    District,
    Member_Card_Number,
    Member_Card_Grade,
    Day_Type,
    Campaign_Description,
    Transaction_Date,
    Transaction_Time,
    Is_SmartBA,
    SKU_Code,
    SKU_Code as Main_Code,
    SKU_Name,
    Brand_Name,
    Brand_Type,
    Category,
    Range,
    Segment,
    Target_Gender,
    First_Function,
    Promotion_ID,
    Promotion_Content,
    Promotion_Offer,
    Coupon_Code,
    Item_Quantity,
    Item_Price,
    Item_Discount,
    Item_Sales,
    Item_Cost,
    Super_ID,
    Is_Placed,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    [RPT].[RPT_Order_SKU_PO_Level]
WHERE 
    Business_Channel IN ('Offline','O2O')
;
END

GO
