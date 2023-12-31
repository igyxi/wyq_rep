/****** Object:  StoredProcedure [TEMP].[SP_RPT_Dragon_Late_Delivery_PO_PrivateSales_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Dragon_Late_Delivery_PO_PrivateSales_Bak_20230413] @dt [VARCHAR](10),@delivery_pending_days [int] AS BEGIN

    --DECLARE @dt date,
    --@delivery_pending_days int
    --set
    --    @dt = '2021-09-03'
    --set
    --    @delivery_pending_days = 1
    --EXECUTE [DW_OMS].[SP_RPT_Dragon_Late_Delivery_PO_PrivateSales] '2021-09-03', 3

    --新档期大促清空 前一天
    if ((select format(getdate(),'yyyy-MM-dd')) = '2022-10-24' and (@delivery_pending_days = 5))
    begin
        delete from [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales]
        where report_pending_days = 5
    end

    if ((select format(getdate(),'yyyy-MM-dd')) = '2022-10-26' and (@delivery_pending_days = 7))
    begin
        delete from [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales]
        where report_pending_days = 7
    end

    DELETE FROM [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales] WHERE [dt] = @dt AND [report_pending_days] = @delivery_pending_days;

    INSERT INTO [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales]
    SELECT
        a.[sales_order_number],
        a.member_id,
        a.[place_time],
        a.[actual_pending_days],
        @delivery_pending_days as [report_pending_days],
        @dt as [dt]
    FROM (
        SELECT
            a.[sales_order_number],
            a.member_id,
            b.[place_time],
            --全额预售用计划发货时间计算delay时间
            DATEDIFF(DAY,CASE WHEN a.[merge_flag] in (2,3) then ISNULL([shipping_time],b.[place_date]) else b.[place_time] end,cast(ISNULL(a.[logistics_shipping_time], dateadd(day,1,@dt)) as date)) as [actual_pending_days],
            ROW_NUMBER() OVER(PARTITION BY a.member_id ORDER BY CASE WHEN a.[merge_flag] in (2,3) then ISNULL([shipping_time],b.[place_date]) else b.[place_time] end) as [Seq]
        FROM [DW_OMS].[DWS_Purchase_Order] a
        join [DW_OMS].[RPT_Sales_Order_Basic_Level] b on a.[sales_order_sys_id] = b.[sales_order_sys_id]
        WHERE
            CASE WHEN a.[merge_flag] in (2,3) then ISNULL([shipping_time],b.[place_date]) else b.[place_time] end >= '2021-11-09 20:00:00.000'
            and a.store_cd = 'S001'
            and b.[place_date] >= dateadd(day, @delivery_pending_days*(-1), @dt)
            and a.internal_status <> 'CANCELLED'
            and b.[place_date] < @dt
            and a.split_type <> 'SPLIT_ORIGIN'
            and DATEDIFF(DAY,CASE WHEN a.[merge_flag] in (2,3) then ISNULL([shipping_time],b.[place_date]) else b.[place_time] end,cast(ISNULL(a.[logistics_shipping_time], dateadd(day,1,@dt)) as date)) > @delivery_pending_days
    ) a
    LEFT JOIN (
        select *
        from [DW_OMS].[RPT_Dragon_Late_Delivery_PO_PrivateSales]
        where dt <= dateadd(day,-1,@dt) 
    ) b ON a.member_id = b.member_id and b.[report_pending_days] = @delivery_pending_days
    WHERE a.Seq = 1 AND b.[dt] IS NULL
END

GO
