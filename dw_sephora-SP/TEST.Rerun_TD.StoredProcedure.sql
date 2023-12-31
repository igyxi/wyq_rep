/****** Object:  StoredProcedure [TEST].[Rerun_TD]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[Rerun_TD] AS
BEGIN

declare @begin date, @end date, @date date

set @begin = '2021-08-01'
set @end = '2021-08-10'
set @date = @begin

while @date <= @end
begin
	-- print(@begin)
    EXEC ODS_TD.SP_Android_Report @date
    EXEC ODS_TD.SP_IOS_Report @date
    EXEC ODS_TD.SP_PKG_Report @date
    EXEC ODS_TD.SP_Android_Install_Report @date
    EXEC ODS_TD.SP_IOS_Install_Report @date

    set @date = (select DATEADD(day,1,@date))
    -- set @begin = dateadd(day,1,@begin)
	-- set @end = dateadd(day,1,@begin)
end 


EXEC DW_TD.SP_IOS_ReportComp_New  @begin,@end
EXEC DW_TD.SP_PKG_ReportComp_New @begin,@end
EXEC DW_TD.SP_Android_ReportComp_New @begin,@end
exec [DW_TD].[SP_IOS_Install_ReportComp] @begin,@end
EXEC DW_TD.SP_Android_Install_ReportComp @begin,@end

END

GO
