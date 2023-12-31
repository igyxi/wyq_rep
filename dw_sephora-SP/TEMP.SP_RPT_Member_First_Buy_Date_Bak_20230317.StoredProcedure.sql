/****** Object:  StoredProcedure [TEMP].[SP_RPT_Member_First_Buy_Date_Bak_20230317]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Member_First_Buy_Date_Bak_20230317] @dt [nvarchar](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-15       lizeyuan           Initial Version
-- ========================================================================================
with so_order as
(
    select
        a.member_card --client_id
        ,'CN' country --country
        -- ,a.member_card_grade --type_card
        ,sku.eb_category  --type_client
        ,min(a.payment_date) as first_purchase_date--first_purchase_date
        ,min(case when sku.eb_brand_name = 'SEPHORA' then a.payment_date else null end) as first_sc_purchase_date  --first_sc_purchase_date
        ,min(case when a.source = 'POS' then a.payment_date else null end) as first_retail_purchase_date  --first_retail_purchase_date
        ,min(case when a.source = 'POS' and sku.eb_brand_name = 'SEPHORA' then a.payment_date else null end) as first_retail_sc_purchase_date  --first_retail_sc_purchase_date
        ,min(case when a.source = 'OMS' then a.payment_date else null end) as first_online_purchase_date  --first_online_purchase_date
        ,min(case when a.source = 'OMS' and sku.eb_brand_name = 'SEPHORA' then a.payment_date else null end) as first_online_sc_purchase_date --first_online_sc_purchase_date\
        ,current_timestamp as insert_timestamp
    from
    (
        select
            member_card
            -- ,member_card_grade
            ,item_sku_code
            ,min(cast(payment_time as date)) as payment_date
            ,source
        from
        DWD.Fact_Sales_Order
        where is_placed = 1
        group by
            member_card
            -- ,member_card_grade
            ,item_sku_code
            ,source
    )a
    left join
    (
        select
            eb_category
            ,sku_code
            ,eb_brand_name
        from
            dwd.DIM_SKU_INFO
        group by eb_category,sku_code,eb_brand_name
    ) sku
    on a.item_sku_code = sku.sku_code
    group by
        a.member_card --client_id
        -- ,a.member_card_grade --type_card
        ,sku.eb_category  --type_client
)
insert into [RPT].[RPT_Member_First_Buy_Date]
select
    member.member_card --client_id
    ,'CN' country --country
    -- ,so_order.member_card_grade --type_card
    ,case when member.card_type = 0 then 'PINK'
          when member.card_type = 1 then 'WHITE'
          when member.card_type = 1 then 'BLACK'
          when member.card_type = 1 then 'GOLD'
    end as member_card_grade
    ,so_order.eb_category  --type_client
    ,so_order.first_purchase_date --first_purchase_date
    ,so_order.first_sc_purchase_date  --first_sc_purchase_date
    ,so_order.first_retail_purchase_date  --first_retail_purchase_date
    ,so_order.first_retail_sc_purchase_date  --first_retail_sc_purchase_date
    ,so_order.first_online_purchase_date  --first_online_purchase_date
    ,so_order.first_online_sc_purchase_date --first_online_sc_purchase_date\
    ,current_timestamp as insert_timestamp
from  
    DWD.DIM_Member_Info member
left join 
    so_order 
on member.member_card = so_order.member_card
END
GO
