/****** Object:  StoredProcedure [TEMP].[SP_DWS_Douyin_Sales_Order_With_VB_Bak20230227]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Douyin_Sales_Order_With_VB_Bak20230227] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-24       litao           Initial Version
-- ========================================================================================

truncate table DW_OMS.DWS_Douyin_Sales_Order_With_VB; 

--抖音退款订单
with refund_order as
(select
           a.oms_order_sys_id,
           b.aftersale_id,
           b.shop_order_id,
           b.related_id,
           cast(b.refund_amount as decimal(20,5))/100 as refund_amount
       from
          (
          select
              oms_order_sys_id,
              third_refund_id,
              row_number() over(partition by third_refund_id order by create_time desc) as row_rank
          from stg_oms.oms_order_refund
          where refund_status = 'REFUNDED'
            and store_id = 'DOUYIN001'
          ) a
       inner join stg_oms.dy_aftersale_info b
       on a.third_refund_id = b.aftersale_id
       where a.row_rank=1
)

insert into DW_OMS.DWS_Douyin_Sales_Order_With_VB
select 
        t.sales_order_number,--SALES订单号
        t.sales_order_sys_id,--主键自增
        format(t.order_time,'yyyy-MM-dd') as order_date,
        t.order_time,--订单时间
        t.order_internal_status,--订单状态
        t.payment_status,--支付状态
        t.basic_status,--基本状态
        COALESCE(t1.author_name, N'Unknown') as author_name,
        t1.item_sku, --SKU CODE（VB粒度）
        trim(t1.item_name) as item_name, --商品名称（取订单item表字段）
        COALESCE(t2.eb_category, N'OTHERS') as category, --Category
        COALESCE(t2.eb_brand_type, N'OTHERS') as brand_type, --Brand Type
        COALESCE(trim(t2.eb_brand_name_cn), N'OTHERS') as brand_name,--Brand
        t1.item_quantity,--商品数量 
        t1.apportion_amount, --实付总价 
        t1.third_server_rate, --第三方服务费率
        t1.third_server_amount, --第三方服务费额
        t1.author_id,
        t1.video_id,
        t1.room_id,
        case when video_id is not null and video_id <> '0' then N'短视频' 
                  when room_id is not null and room_id <> '0' then N'直播间'
                  when author_id <> '0' and author_id is not null then N'橱窗-有推荐来源'
             else N'橱窗-无推荐来源' end as order_source,
        t.is_placed,
        t3.refund_amount,--退款金额
        t3.related_id,--关联的订单ID
        t1.douyin_oid,--抖音oid
        t3.aftersale_id,
        CURRENT_TIMESTAMP as insert_timestamp
    from 
    (select
        sales_order_number,
        order_time,
        order_internal_status,
        payment_status,
        basic_status, 
        sales_order_sys_id,
        case when basic_status <> 'DELETED'
              and store_id not in ('TMALL002', 'GWP001') 
              and type not in (2, 9)
              and ((payment_status = 1 and payment_time is not null) or type = 8)
              and  product_total > 1 then 1
              else 0
        end as is_placed --现有RPT_Sales_Order_VB_Level表is_placed字段逻辑
      from 
        stg_oms.sales_order 
      where channel_id='DOUYIN'
     ) t
    inner join
        stg_oms.sales_order_item t1
    on t.sales_order_sys_id = t1.sales_order_sys_id
    left join 
        dwd.dim_sku_info t2
    on t1.item_sku = t2.sku_code 
    left join refund_order t3 
    on t.sales_order_number=t3.shop_order_id
    and t1.douyin_oid=t3.related_id
END
GO
