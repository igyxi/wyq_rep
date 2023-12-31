/****** Object:  StoredProcedure [STG_Sensor].[TRANS_Events_MNP_Issue_Fix]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Sensor].[TRANS_Events_MNP_Issue_Fix] @dt [VARCHAR](10) AS
BEGIN
-- 临时用来修复Sensor前端的platform_type missing问题。
update a
set a.platform_type = 'MiniProgram'
from
    STG_Sensor.Events a
where
dt = @dt
    and event = '$MPViewScreen'
    and isnull(platform_type,'') = ''

END
GO
