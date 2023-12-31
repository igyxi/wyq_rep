/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_Chatgroup_Sales_Order_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_Chatgroup_Sales_Order_Detail] @dt [varchar](10) AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-09-26       wubin              update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2023-02-21       wangzhichun        update source table
-- ========================================================================================
delete from DW_SmartBA.RPT_Chatgroup_Sales_Order_Detail where dt = @dt;
insert into DW_SmartBA.RPT_Chatgroup_Sales_Order_Detail
select 
    a.chat_name, --新增字段
    a.chat_type, --新增字段
    a.channel_name, --新增字段
    a.store_code as wxchat_store_code, --新增字段
    c.sales_order_number,
    c.item_sku_cd,
    c.store_cd,
    c.channel_cd,
    c.province,
    c.city,
    c.order_date,
    c.order_time,
    c.payment_date,
    c.payment_time,
    c.place_date, --新增字段
    c.payed_amount, --新增字段
    c.item_type_cd,
    c.item_main_cd,
    c.item_name,
    c.item_quantity,
    c.item_apportion_amount,
    c.item_brand_name,
    c.item_brand_type,
    c.item_category,
    c.item_segment,
    c.vb_flag,
    c.member_card,
    a.join_time,
    a.join_date,
    c.member_card_grade,
    c.member_new_status as member_new_status,
    c.member_mnp_new_status,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select 
        cast(a.join_time as date) as join_date, 
        a.join_time, 
        a.chat_type, --新增字段 
        a.chat_name, --新增字段
        a.channel_name, --新增字段
        a.store_code, --新增字段
        b.user_id as user_id
    from 
        DWD.Fact_Member_Wechat_Group_Join a 
    left join 
        [DW_WechatCenter].[DWS_Wechat_User_Info] b
    on 
        a.unionid = b.union_id
) a
inner join
(
    select
        a.sephora_user_id,
        a.place_time,
        a.place_date, -- 新增字段
        a.payed_amount, --新增字段
        a.sales_order_number,
        a.item_sku_code as item_sku_cd,
        'S001' as store_cd,
        a.sub_channel_code as channel_cd,
        a.province,
        a.city,
        cast(a.order_time as date) as order_date,
        a.order_time,
        cast(a.payment_time as date) as payment_date,
        a.payment_time,
        a.item_type as item_type_cd,
        b.eb_main_sku_code as item_main_cd,
        a.item_name,
        a.item_quantity,
        a.item_apportion_amount,
        a.item_brand_name,
        a.item_brand_type,
        a.item_category,
        b.EB_segment as item_segment,
        case when a.item_sku_code like 'V%' then 1 else 0 end as vb_flag,
        a.member_card,
        a.member_card_grade,
        a.member_new_status as member_new_status,
        case when a.channel_order_placed_seq = 1 and a.sub_channel_code in ('ANNYMINIPROGRAM','MINIPROGRAM','BENEFITMINIPROGRAM') then 'NEW'
             when a.sub_channel_code in ('ANNYMINIPROGRAM','MINIPROGRAM','BENEFITMINIPROGRAM') and a.channel_order_placed_seq > 1 then 'RETURN'
        else 'NO DETAIL' end as member_mnp_new_status
    from         
        RPT.RPT_Sales_Order_VB_Level a
    left join 
        dwd.dim_sku_info b
    on  
        a.item_sku_code = b.sku_code
    where
        a.channel_code = 'SOA'
        and a.is_placed = 1
        and a.place_date = @dt
) c
on a.user_id = c.sephora_user_id
and a.join_time < c.place_time;
END
GO
