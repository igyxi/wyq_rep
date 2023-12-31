/****** Object:  StoredProcedure [DWD].[SP_DIM_Animation]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Animation] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-01       Tali           Initial Version
-- 2022-06-07       Tali           fix next_start_date is null
-- 2022-08-15       Tali           change source to DIM_Animation_BI
-- ========================================================================================
truncate table DWD.Dim_Animation;
insert into DWD.Dim_Animation
select
    Animation_ID,
    animation,
    Material as sku_code,
    [From Date] as Start_Date,
    [Till Date] as End_Date,
    CURRENT_TIMESTAMP CreateTime,
    CURRENT_TIMESTAMP LastUpdateTime,
    CURRENT_TIMESTAMP
from
(
    select
        b.Animation_ID,
        a.animation,
        a.Material, 
        a.[From Date], 
        a.[Till Date]
    from
    (
        select *, row_number() over(partition by animation, Material order by [From Date], [Till Date]) rownum from DW_Common.DIM_Animation_BI 
    ) a
    join
    (
        select 
            *, row_number() over(order by [From Date]) as Animation_ID
        from 
        (
            select distinct Animation, [From Date] from DW_Common.DIM_Animation_BI
        )t
    ) b
    on a.Animation = b.Animation
    and a.[From Date] = b.[From Date]
    where 
        a.rownum = 1
)t
end
GO
