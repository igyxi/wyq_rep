/****** Object:  StoredProcedure [RPT].[SP_RPT_Member_First_Buy_Date_Bak_20230609]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Member_First_Buy_Date_Bak_20230609] @dt [nvarchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-15       lizeyuan           Initial Version
-- 2023-03-17       houshuangqiang     update logic
-- ========================================================================================
-- truncate table [RPT].[RPT_Member_First_Buy_Date_History]
-- ;

insert into [RPT].[RPT_Member_First_Buy_Date_History]
select  client_id
        ,country
        ,type_card
        ,type_client
        ,first_purchase_date
        ,first_sc_purchase_date
        ,first_retail_purchase_date
        ,first_retail_sc_purchase_date
        ,first_online_purchase_date
        ,first_online_sc_purchase_date
        ,insert_timestamp
from    [RPT].[RPT_Member_First_Buy_Date]
;

truncate table [RPT].[RPT_Member_First_Buy_Date]; 
with so_order as
(
    select
        a.member_card --client_id
--        ,'CN' country --country
        -- ,a.member_card_grade --type_card
        ,sku.eb_category as type_client  --type_client
        ,min(a.payment_date) as first_purchase_date --first_purchase_date
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
        from  DWD.Fact_Sales_Order
        where is_placed = 1
        and   format(payment_time, 'yyyy-MM-dd') = @dt
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
),

first_date as
(
 select 	p.member_card
            ,p.type_client
            ,min(p.first_purchase_date) as first_purchase_date
            ,min(p.first_sc_purchase_date) as first_sc_purchase_date
            ,min(p.first_retail_purchase_date) as first_retail_purchase_date
            ,min(p.first_retail_sc_purchase_date) as first_retail_sc_purchase_date
            ,min(p.first_online_purchase_date) as first_online_purchase_date
            ,min(p.first_online_sc_purchase_date) as first_online_sc_purchase_date
    from
    (
       select  client_id as member_card
                ,type_client
                ,first_purchase_date
                ,first_sc_purchase_date
                ,first_retail_purchase_date
                ,first_retail_sc_purchase_date
                ,first_online_purchase_date
                ,first_online_sc_purchase_date
        from    [RPT].[RPT_Member_First_Buy_Date_History]
        union   all
        select  member_card
                ,type_client
                ,first_purchase_date
                ,first_sc_purchase_date
                ,first_retail_purchase_date
                ,first_retail_sc_purchase_date
                ,first_online_purchase_date
                ,first_online_sc_purchase_date
        from    so_order
    ) p
    group by p.member_card,p.type_client
)

insert into [RPT].[RPT_Member_First_Buy_Date]
select
    member.member_card --client_id
    ,'CN' country --country
    -- ,so_order.member_card_grade --type_card
    ,case when member.card_type = 0 then 'PINK'
          when member.card_type = 1 then 'WHITE'
          when member.card_type = 2 then 'BLACK'
          when member.card_type = 3 then 'GOLD'
    end as member_card_grade
    ,[first].type_client
    ,[first].first_purchase_date
    ,[first].first_sc_purchase_date
    ,[first].first_retail_purchase_date
    ,[first].first_retail_sc_purchase_date
    ,[first].first_online_purchase_date
    ,[first].first_online_sc_purchase_date
    ,current_timestamp as insert_timestamp
from
    DWD.DIM_Member_Info member
left join
    first_date [first]
on  member.member_card = [first].member_card
END
GO
