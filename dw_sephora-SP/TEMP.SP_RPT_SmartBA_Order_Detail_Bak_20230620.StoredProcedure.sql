/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_Order_Detail_Bak_20230620]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_Order_Detail_Bak_20230620] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       mac                delete 'COLLATE Chinese_PRC_CS_AI_WS'
-- 2022-09-26       wubin              update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2023-03-22       litao              update store_name, store_region, store_great_region, store_city
-- 2023-03-22       wangzhichun        update source
-- ========================================================================================
truncate table [DW_SmartBA].[RPT_SmartBA_Order_Detail];
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

insert into [DW_SmartBA].[RPT_SmartBA_Order_Detail]
select
    a.order_id,
    case when b.channel_code='SOA' THEN 'S001' ELSE b.sub_channel_code  end store_cd,
    case when b.sub_channel_code='TMALL006' then 'TMALL_WEI'
        when b.sub_channel_code='TMALL004' then 'TMALL_CHALING'
        when b.sub_channel_code='TMALL005' then 'TMALL_PTR'
        when b.sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
        when b.sub_channel_code='DOUYIN001' then 'DOUYIN'
        when b.sub_channel_code='REDBOOK001' then 'REDBOOK'
        when b.sub_channel_code='JD003' then 'JD_FCS'
        when b.sub_channel_code in ('JD001','JD002') then 'JD'
        when b.sub_channel_code='GWP001' then 'OFF_LINE'
        else b.sub_channel_code 
        end as channel_cd,
    b.province,
    b.city,
    b.order_time,
    b.payment_time,
    b.order_type as type_cd,
    b.item_sku_code as item_sku_cd,
    b.item_main_code as item_main_cd,
    b.item_name,
    b.item_quantity,
    b.item_apportion_amount,
    b.item_brand_name,
    b.item_brand_type,
    b.item_category,
    c.EB_segment as segment,
    case when CHARINDEX('VB',b.item_sku_code)=1 or CHARINDEX('VS',b.item_sku_code)=1 then 'Y' else 'N' end as vb_flag,
    b.member_card,
    b.member_card_grade,
    case when b.all_order_placed_seq = 1 and b.member_card_grade = 'PINK' then 'Brand New'
         when b.all_order_placed_seq = 1 and b.member_card_grade <> 'PINK' then 'Convert New'
         else 'Return'
    end as new_to_eb_cd,
    case when b.channel_order_placed_seq = 1 then 'New' else 'Return' end as new_to_mnp_cd,
    case when e.userid is not null and e.bindingtime <= b.order_time then 1 else 0 end as is_checked_unionid,
    a.utm_term,
    a.utm_content,
    case when a.utm_content='0000' then N'XZS'
         when a.utm_content='1110' then N'测试门店'
         when a.utm_content='2222' then N'OBA'
         when a.utm_content='3333' then N'企微任务测试门店' 
         else  d.store_name 
    end as store_name,
    case when a.utm_content='0000' then N'XZS'
         when a.utm_content='1110' then N'测试门店'
         when a.utm_content='2222' then N'OBA'
         when a.utm_content='3333' then N'企微任务测试门店' 
         when a.utm_content='6507' then N'West region'
         when a.utm_content='6488' then N'Great East Region'
         when a.utm_content='6494' then N'Great North Region'
         when a.utm_content='6496' then N'Great East Region' 
         when a.utm_content='6493' then N'Great North Region' 
         when a.utm_content in ('6474','6485','6495') then N'South Region'
         else d.region
    end as store_great_region,
    case when a.utm_content='0000' then N'XZS'
         when a.utm_content='1110' then N'测试门店'
         when a.utm_content='2222' then N'OBA'
         when a.utm_content='3333' then N'企微任务测试门店' 
         when a.utm_content='6488' then N'Shanghai'
         when a.utm_content='6494' then N'Capital'
         when a.utm_content='6496' then N'Jiangsu' 
         when a.utm_content='6493' then N'North' 
         when a.utm_content in ('6474','6485','6495') then N'Guangdong Bay'
         else d.subregion
    end as store_region,
    d.district ,
    case when a.utm_content='0000' then N'XZS'
         when a.utm_content='1110' then N'测试门店'
         when a.utm_content='2222' then N'OBA'
         when a.utm_content='3333' then N'企微任务测试门店' 
         else d.city
    end as city,
    current_timestamp as insert_timestamp
from
(
    select
        *
    from
        [STG_Order].[Order_Source]
    where 
        utm_campaign = 'BA' 
    and 
        utm_medium ='seco'
)a
inner join 
    (select * from [RPT].[RPT_Sales_Order_VB_Level] where is_placed=1) b
on 
    a.order_id = b.sales_order_number
left join
    (select distinct sku_code,EB_segment from dwd.DIM_SKU_Info) c
on 
    b.item_sku_code = c.sku_code
left join
    [ODS_CRM].[DimStore] d
on 
    a.utm_content = d.store_code 
left join
    employee_info e
on
    b.sephora_user_id = e.userid
and 
    a.utm_term = e.employeecode
and 
    e.rn=1
;
end

GO
