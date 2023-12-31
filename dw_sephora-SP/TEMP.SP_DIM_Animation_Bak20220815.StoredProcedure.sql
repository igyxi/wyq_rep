/****** Object:  StoredProcedure [TEMP].[SP_DIM_Animation_Bak20220815]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Animation_Bak20220815] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-01       Tali           Initial Version
-- 2022-06-07       Tali           fix next_start_date is null
-- ========================================================================================
truncate table DWD.Dim_Animation;
insert into DWD.Dim_Animation
select
    Animation_ID,
    animation_name,
    Material_Code as sku_code,
    Start_Date,
    End_Date,
    CreateTime,
    LastUpdateTime,
    CURRENT_TIMESTAMP
from
(
    select 
        Animation_ID,
        animation_name,
        Material_Code, 
        Start_Date, 
        End_Date,
        CreateTime,
        LastUpdateTime ,
        lead([Start_Date]) over(partition by Material_Code order by start_Date) as next_start_date 
    from
    (
        select *, row_number() over(partition by Material_Code, animation_name order by animation_id desc) rownum from DW_Common.Dim_Animation_Retail
        where Material_Code is not null
    ) a
    where a.rownum = 1
)t
where End_Date < next_start_date or next_start_date is null;
end

GO
