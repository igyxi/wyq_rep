/****** Object:  StoredProcedure [DWD].[SP_Fact_EB_Sales_Order_Bak_20230612]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_EB_Sales_Order_Bak_20230612] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-05       LeoZhai    Initial Version
-- ========================================================================================
truncate table [DWD].[Fact_EB_Sales_Order];
insert into DWD.Fact_EB_Sales_Order
select
    ta.sales_order_number as sales_order_number,
    ta.channel_code,
    ta.channel_name,
    ta.sub_channel_code,
    ta.sub_channel_name,
    td.province as province,
    td.city as city,
    td.district,
    ta.[type] as type_code,
    ta.member_id,
    ta.member_card,
    ta.member_card_grade,
    ta.payment_status as payment_status,
    ta.payed_amount as payment_amount,
    ta.order_internal_status as order_status,
    ta.order_time,
    ta.payment_time,
    ta.is_valid,
    ta.is_placed,
    ta.place_time,
    ta.smartba_flag AS smartba_flag,
    ta.ouid,
    tc.vb_sku as virtual_sku_code,
    tc.vb_quantity as virtual_quantity,
    tc.vb_apportion_amount as virtual_apportion_amount,
    tc.vb_adjustment_amount as virtual_discount_amount,
    CURRENT_TIMESTAMP as insert_timestamp
from
(
    select
        a.sales_order_sys_id,
        a.sales_order_number,
        a.store_id,
        si.channel_id as channel_code,
        si.channel_name,
        case when a.store_id = 'S001' then a.channel_id
            when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006'
            else a.store_id
        end as sub_channel_code,
        case
            when a.store_id = 'S001' then a.channel_id
            when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then N'天猫WEI旗舰店'
            else si.store_name
        end as sub_channel_name,
        si.store_name,
        a.type,
        a.member_id,
        case when si.channel_id = 'JD' and a.member_card like 'JD%' then SUBSTRING(a.member_card, 3, len(a.member_card)-2) else a.member_card end as member_card,
        COALESCE(a.member_card_grade, b.group_name) as member_card_grade,
        a.order_internal_status,
        a.order_time,
        a.payment_status,
        a.payment_time,
        a.payed_amount,
        case 
            when a.basic_status <> 'DELETED' and a.type not in (2, 9) and a.payment_status = 1
            and (a.order_internal_status like '%SIGNED%' or a.order_internal_status like '%SHIPPED%')
            and a.product_total > 1 then 1
            else 0 
        end as is_valid,
        case when a.basic_status <> 'DELETED'
            and a.store_id not in ('TMALL002', 'GWP001')
            and a.type not in (2, 9)
            and ((a.payment_status = 1 and a.payment_time is not null) or a.type = 8)
            and a.product_total > 1 then 1
            else 0
        end as is_placed,
        case when a.type = 8 then a.order_time
            else COALESCE(a.payment_time, a.order_time)
        end as place_time,
        case when a.smartba_flag is not null then a.smartba_flag
             when os.order_id is not null and a.channel_id = 'MINIPROGRAM' then 1
            else 0
        end as smartba_flag,
        a.ouid
    from
        STG_OMS.Sales_Order a
    left join
    (
        select order_id, group_name from STG_Order.Orders where group_name <> 'O2O'
    ) b
    on a.sales_order_number = b.order_id
    left join
        ODS_OMS.OMS_Store_Info si
    on case when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006' else a.store_id end = si.store_id
    left join
    (
        select distinct
            order_id
        from
            STG_Order.Order_Source
        where
            utm_campaign = 'BA'
        and
            utm_medium ='seco'
    ) os
    on  a.sales_order_number = os.order_id
) ta
left join
(
    select
        sales_order_sys_id,
        item_sku as vb_sku,
        sum(item_quantity) as vb_quantity,
        sum(apportion_amount) as vb_apportion_amount,
        sum(item_adjustment_total) as vb_adjustment_amount
    from
        STG_OMS.Sales_Order_item i
    where
        item_sku like 'V%'
    group by
        sales_order_sys_id,
        item_sku
) tc
on ta.sales_order_sys_id = tc.sales_order_sys_id
left join
(
    select
        sales_order_sys_id,
        opcm.crm_province as province,
        opcm.crm_city as city,
        soa.district,
        row_number() over(partition by sales_order_sys_id order by create_time desc) rn
    from
        STG_OMS.Sales_order_Address soa
    left join
        STG_OMS.OMS_Province_City_Mapping opcm
    on soa.province = opcm.oms_province
    and isnull(soa.city, '') = isnull(opcm.oms_city, '')
    where
        soa.is_delete = 0
) td
on ta.sales_order_sys_id = td.sales_order_sys_id
and td.rn = 1

END


GO
