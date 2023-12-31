/****** Object:  StoredProcedure [RPT].[SP_RPT_Order_SKU_PO_Level]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Order_SKU_PO_Level] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-20       fenglu           Initial Version
-- 2022-10-27       fenglu           Add Field
-- 2022-11-08       fenglu           Change Region Field
-- 2022-11-08       litao            Add super_id
-- 2023-03-16       litao            Change super_id,Region
-- 2023-03-24       litao           Platform = ‘DOUYIN’ AND member_card is null时，请将super_id修改成‘member_id’+‘province’+’city’，例如：member_id = ‘王先生’，province = ‘江苏’，city=’苏州’，则super_id = ‘王先生江苏苏州’
-- ========================================================================================
truncate table RPT.RPT_Order_SKU_PO_Level;
insert into RPT.RPT_Order_SKU_PO_Level
SELECT DISTINCT
        po.sales_order_number 
        ,po.purchase_order_number
        ,case when po.source in ('POS','CRM') then 'Offline' 
              when po.source = 'HUB' then 'O2O'
              when po.source = 'OMS' then 'EB'
          else po.source end as Business_channel
        ,case when po.channel_code = 'SOA' then 'DRAGON' 
              when po.channel_code = 'DOUYIN' then 'TIKTOK'
         else po.channel_code end as Platform
        ,case when po.sub_channel_code in ('JD001','JD002') then 'JD_FSS'
              when po.sub_channel_code = 'JD003' then 'JD_FCS'
              when po.sub_channel_code = 'TMALL001' then 'TMALL_SEPHORA'
              when po.sub_channel_code = 'TMALL004' then 'TMALL_CHALING'
              when po.sub_channel_code = 'TMALL005' then 'TMALL_PTR'
              when po.sub_channel_code = 'TMALL006' then 'TMALL_WEI'
              when po.sub_channel_code = 'DOUYIN001' then 'TIKTOK'
              when po.sub_channel_code like 'APP%' then 'APP'
              when po.sub_channel_code like '%MINIPROGRAM' or po.sub_channel_code = 'WECHAT' then 'MNP/WECHAT'
              when po.sub_channel_code in ('PC','WCS','MOBILE') then 'PC/MOBILE'
         else po.sub_channel_code end as Channel
        ,po.store_code
        ,b.nso_store_name as store_name
        ,'' as BA 
        ,po.order_status
        ,case  
              when po.source in ('POS','HUB','CRM') then b.nso_greatregion
              when po.source = 'OMS' and po.Province in (N'香港',N'澳门',N'台湾') then  'South region'
              when po.source = 'OMS' and  po.Province in (N'西藏') then  'West region'
         else b1.nso_greatregion end as Region --修改Business_Channel = 'Offline', 根据店铺判定四大区，Business_Channel = 'EB'，根据province判定四大区
        ,po.province 
        ,po.city 
        ,po.district 
        ,po.member_card as Member_card_number
        ,COALESCE(upper(po.member_card_grade),upper(e.member_card_grade)) as member_card_grade
        ,case when d.tmall_sephora_campaign_flag = 1 or d.tmall_wei_campaign_flag = 1 or d.jd_campaign_flag = 1 then 1 else 0 end as Day_type
        ,'' as Campaign_description
        ,po.place_date as Transaction_date
        ,po.place_time as Transaction_time
        ,po.is_smartba
        ,po.virtual_sku_code as VB_Code
        ,po.item_sku_code as SKU_Code
        ,po.item_sku_name as SKU_name
        --,c.sap_brand_name as Brand_name
        ,case when c.sap_brand_name = 'MENARD SP' then 'NIIPON MENARD' else c.sap_brand_name end as Brand_Name
        ,c.sap_market_description as Brand_type
        ,c.sap_category_description as Category
        ,c.range
        ,c.segment
        ,c.sap_target_description as Target_gender
        ,c.first_function
        ,'' as Promotion_id
        ,'' as Promotion_content
        ,'' as Promotion_offer
        ,'' as Coupon_code
        ,po.item_quantity 
        ,po.item_sale_price
        ,po.item_discount_amount as Item_discount
        ,po.item_apportion_amount as Item_sales
        ,NULL as Item_cost  -- Moving Price
        ,case when po.channel_code = 'DOUYIN' 
               and po.member_card is null 
               and f.member_id is not null
               and po.province is not null 
               and po.city is not null 
            then concat(f.member_id,po.province,po.city)
         else coalesce(po.member_card,f.member_id)--新增super_id
         end as super_id
        ,po.is_placed 
        ,CURRENT_TIMESTAMP as insert_timestamp
FROM (
    select sales_order_number 
            ,purchase_order_number
            ,channel_code
            ,sub_channel_code
            ,store_code
            ,order_status
            ,province 
            ,city 
            ,district 
            ,member_card
            ,member_card_grade
            ,place_time
            ,format(place_time, 'yyyy-MM-dd') as place_date
            ,is_smartba
            ,virtual_sku_code
            ,item_sku_code
            ,item_sku_name
            ,item_quantity 
            ,item_apportion_amount
            ,item_sale_price
            ,item_discount_amount
            ,is_placed
            ,source
    from DWD.Fact_Sales_Order
    where is_placed = 1
) po 
left join DWD.Dim_Store b on po.store_code = b.store_code 
left join (
    select distinct nso_province,nso_greatregion
    from DWD.DIM_Store
    where nso_province is not null and nso_greatregion is not null
) b1 on po.province = b1.nso_province
left join DWD.DIM_SKU_Info c on po.item_sku_code = c.sku_code
left join DWD.DIM_Calendar d on po.place_date = d.date_str
left join (
    select member_card
            ,SUBSTRING(card_type_name,3,100) as member_card_grade
            ,start_time
            ,end_time 
    from DWD.DIM_Member_Card_Grade_SCD
) e on po.member_card = e.member_card and po.place_time >= e.start_time and po.place_time < e.end_time
left join (
         select 
            distinct sales_order_number,member_id
          from RPT.RPT_Sales_Order_Basic_Level --新增super_id字段
          ) f 
on po.sales_order_number=f.sales_order_number
END
GO
