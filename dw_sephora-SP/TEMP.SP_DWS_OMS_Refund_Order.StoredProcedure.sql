/****** Object:  StoredProcedure [TEMP].[SP_DWS_OMS_Refund_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_OMS_Refund_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       houshuangqiang     Initial Version
-- ========================================================================================
truncate table DW_New_OMS.DWS_OMS_Refund_Order;
insert into DW_New_OMS.DWS_OMS_Refund_Order                                                                                
select  [return].bill_no as refund_no                                                                                      
--        ,[return].platform_id                                                                                            
        ,case when channel.code = 'jingdong' then 'JD'
              when channel.code = 'douyinxiaodian' then 'DOUYIN'
              when channel.code = 'taobao' then 'TMALL'  -- 字典表，是不是需要重新名称，丝芙兰在淘宝上没有店铺吧？
              else upper(channel.code)
        end as channel_code                                                                                              
        ,[return].shop_code as sub_channel_code                                                                            
--        ,store.code                                                                                                      
--        ,store.name as sub_channel_name                                                                                  
        ,[return].return_amount_status as refund_status                                                                    
        ,[return].return_order_type as refund_type -- 退单类型1退货2追件3拒收                                                        
        ,[return].return_reason as refund_reason                                                                           
        ,[return].apply_time                                                                                               
        ,[return].complete_date as refund_time                                                                             
        ,[return].returned_amount as refund_amount                                                                         
        ,[return].total_amount as product_amount                                                                           
        ,[return].shipping_fee as delivery_amount                                                                          
        ,[return].desensitization_receiver_tel as refund_mobile                                                            
        ,[return].remark as refund_comments 
		,null return_pos_flag -- 缺字段
        ,[return].deal_code as sales_order_number                                                                          
        ,[return].relate_order_bill_no as purchase_order_number                                                            
        ,[return].vip_card_no as member_card_no                                                                            
        ,sku.code as item_sku_code                                                                                         
        ,sku.name as item_sku_name                                                                                         
        ,detail.return_qty as item_quantity                                                                                
        ,coalesce(detail.payed_amount, 0) + coalesce(detail.discount_fee, 0) as item_total_amount                          
        ,detail.payed_amount as item_apportion_amount                                                                      
        ,detail.discount_fee as item_discount_amount                                                                       
        ,'' as sync_type                                                                                                   
        ,'' as sync_status                                                                                                 
        ,null as sync_time                                                                                                   
        ,'' as invoice_id                                                                                                  
        ,[return].create_date as create_time                                                                               
--       ,[return].data_update_time as update_time
	    ,null as update_time																			 
--        ,case when [return].return_amount_status =  退款状态 0-退款中，1-退款成功，2-退款失败 3-等待退款 4-无需退款                               
		,0 as is_delete
		,current_timestamp as insert_timestamp
from    STG_New_OMS.ord_retail_return_bill [return]                                                                        
left    join STG_New_OMS.ord_retail_return_gds_de detail                                                                   
on      [return].id = detail.return_bill_id                                                                                
left    join STG_IMS.Gds_Btsinglprodu sku                                                                                  
on      detail.single_product_id = sku.id                                                                                  
left    join STG_IMS.SYS_Dict_Detail_STG channel                                                                           
on      [return].platform_id = channel.id                                                                                  
where   [return].return_amount_status = 1                                                                                  
--left    join STG_IMS.Bas_Channel_stg store                                                                               
--on 		[return].shop_id = store.id                                                                                    
;      
END                                                                                                                    
                                         


GO
