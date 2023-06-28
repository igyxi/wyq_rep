/****** Object:  StoredProcedure [DWD].[SP_Fact_ASOTF_Event]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_ASOTF_Event] @dt [varchar](10) AS 
begin
    -- ========================================================================================
    -- --------------------------------- Change Log -------------------------------------------
    -- Date Generated   Updated By     Description
    -- ----------------------------------------------------------------------------------------
    -- 2023-05-04       weichen        Initial Version
    -- 2023-05-08		weichen		   update  storecode  to store_code  
    -- 2023-05-17       Joey           add PDP Navigation
    -- ========================================================================================
    DELETE FROM DWD.Fact_ASOTF_Event where dt = @dt;

    insert into DWD.Fact_ASOTF_Event

                    SELECT
            [event],
            [date],
            [time],
            user_id as sensor_user_id,
            [vip_card] as member_card,
            [vip_card_type] as member_card_grade,
            [store_code] as store_code,
            [commodity_sku] as eb_sku_id,
            [sku_code],
            [source_op_code] as product_id,
            [page_id],
            [action_id],
            N'Care Table 智能推介 Lift and Learn' as [touchpoint_name],
            CURRENT_TIMESTAMP as [insert_timestamp],
            @dt as [dt]
        FROM STG_Sensor.Events
        WHERE [date] = @dt
            AND [ss_app_id] = 'cn.sephora.caretable.prod'

    UNION ALL

        SELECT
            [event],
            [date],
            [time],
            user_id as sensor_user_id,
            [vip_card] as member_card,
            [vip_card_type] as member_card_grade,
            [store_code] as store_code,
            [commodity_sku] as eb_sku_id,
            [sku_code],
            [source_op_code] as product_id,
            [page_id],
            [action_id],
            N'Store Navigation 智美探店' as [touchpoint_name],
            CURRENT_TIMESTAMP as [insert_timestamp],
            @dt as [dt]
        FROM STG_Sensor.Events
        WHERE [date] = @dt
            and [page_id] = 'StorePortal_30000001'

    UNION ALL

        SELECT
            [event],
            [date],
            [time],
            user_id as sensor_user_id,
            [vip_card] as member_card,
            [vip_card_type] as member_card_grade,
            [store_code] as store_code,
            [commodity_sku] as eb_sku_id,
            [skucode] collate SQL_Latin1_General_CP1_CI_AS as sku_code,
            [source_op_code] as product_id,
            [page_id],
            [action_id],
            N'PDP Navigation 智美探店' as [touchpoint_name],
            CURRENT_TIMESTAMP as [insert_timestamp],
            @dt as [dt]
        FROM STG_Sensor.Events
        WHERE [date] = @dt
            and [page_id] = 'EN_PDP_20000001'

    UNION ALL

        SELECT
            [event],
            [date],
            [time],
            user_id as sensor_user_id,
            ISNULL([vip_card], distinct_id) as member_card,
            [vip_card_type] as member_card_grade,
            [store_code] as store_code,
            [commodity_sku] as eb_sku_id,
            [sku_code],
            [source_op_code] as product_id,
            [page_id],
            [action_id],
            N'Play Table 美力玩妆 Trendy Now' as [touchpoint_name],
            CURRENT_TIMESTAMP as [insert_timestamp],
            @dt as [dt]
        FROM STG_Sensor.Events
        WHERE [date] = @dt
            and [ss_app_id] = 'cn.sephora.playtable.prod';

END
GO
