/****** Object:  StoredProcedure [TEMP].[SP_DW_Sales_Order_Bak_20230626]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_Sales_Order_Bak_20230626] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-09       LeoZhai           Initial Version
-- 2023-06-19       Leozhai           change order source to ODS
-- ========================================================================================
truncate table [DW_OMS].[DW_Sales_Order];
insert into DW_OMS.DW_Sales_Order
select
    a.sales_order_sys_id,
    a.sales_order_number,
    a.store_id,
    td.province,
    td.city,
    td.district,
    case when a.channel_id = 'TMALL' and a.shop_id = 'TM2' then 'TMALL_WEI' 
        when a.channel_id = 'TMALL' and a.store_id = 'TMALL004' then 'TMALL_CHALING' 
        when a.channel_id = 'TMALL' and a.store_id = 'TMALL005' then 'TMALL_PTR'
        when a.channel_id = 'TMALL' and a.store_id = 'TMALL006' then 'TMALL_WEI'
        when a.channel_id = 'JD' and a.store_id = 'JD003' then 'JD_FCS'
    else a.channel_id end channel_id,
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
    case when a.store_id = 'S001' and a.channel_id = 'O2O' then substring(a.buyer_memo,1,4) else null end as o2o_shop_cd,
    a.type,
    a.member_id,
    a.open_id,
    case when si.channel_id = 'JD' and a.member_card like 'JD%' then SUBSTRING(a.member_card, 3, len(a.member_card)-2) else a.member_card end as member_card,
    COALESCE(a.member_card_grade, b.group_name) as member_card_grade,
    case 
        when COALESCE(a.member_card_grade,b.group_name) = 'PINK'  then 1
        when COALESCE(a.member_card_grade,b.group_name) = 'NEW' then 2
        when COALESCE(a.member_card_grade,b.group_name) = 'WHITE' then 3
        when COALESCE(a.member_card_grade,b.group_name) = 'BLACK' then 4
        when COALESCE(a.member_card_grade,b.group_name) = 'GOLD' then 5
        else 0
    end as member_card_level,
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
    cast(
        case when a.type = 8 then a.order_time 
            else COALESCE(a.payment_time, a.order_time)
        end as date
    ) as place_date,
    case when a.smartba_flag is not null then a.smartba_flag
         when os.order_id is not null and a.channel_id = 'MINIPROGRAM' then 1
        else 0
    end as smartba_flag,
    a.create_time,
    cast(a.create_time as date) as create_date,
    a.update_time,
    cast(a.update_time as date) as update_date,
    a.end_time,
    cast(a.end_time as date) as end_date,
    a.version,
    a.is_delete,
    a.ouid,
    a.shipping_type,
    a.shipping_total,
    a.shop_pick,
    a.order_expected_ware_house,
    a.related_order_number,
    a.times_flag,
    a.cancel_type,
    a.super_order_id,
    a.food_order_flag,
    a.payable_amount,
    a.coupon_amount,
    a.deal_type as so_deal_type,
    a.deposit_flag,
    a.merge_flag,
    a.split_flag,
    case 
        when a.store_id = 'S001' then  COALESCE(a.member_card, a.member_id)
        when a.store_id='DOUYIN001' then  concat(a.member_id,td.province,td.city,td.district)
        else a.member_id
    end as super_id,
    gi.mobile_guid,
    CURRENT_TIMESTAMP as insert_timestamp
from
    STG_OMS.Sales_Order a
left join
(
    select order_id, group_name from ODS_Order.Orders where group_name <> 'O2O'
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
        ODS_Order.Order_Source
    where
        utm_campaign = 'BA'
    and
        utm_medium ='seco'
) os
on  a.sales_order_number = os.order_id
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
on a.sales_order_sys_id = td.sales_order_sys_id
and td.rn = 1
left join 
(
    select sales_order_sys_id,cast(mobile_guid as varchar) as mobile_guid from STG_OMS.Order_Guid_Info
) gi
on a.sales_order_sys_id = gi.sales_order_sys_id;

END


GO
