/****** Object:  StoredProcedure [TEMP].[SP_DW_Data_Masking_Bak_20230620]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_Data_Masking_Bak_20230620] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-01       LeoZhai        Initial Version
-- ========================================================================================

update ODS_User.[User]
set email = null, mobile = null
where dt = @dt;

update ODS_User.[User_Profile]
set mobile = null, email = null, address = null
where dt = @dt;

update ODS_User.[User_Third_Party_Store]
set email = null, mobile = null
where dt = @dt;

END


GO
