/****** Object:  StoredProcedure [Management].[SP_Suspend_Check]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Management].[SP_Suspend_Check] @threshold [INT] AS
BEGIN

    DECLARE @suspend_session_count INT

    SET @suspend_session_count = 
(
SELECT COUNT(DISTINCT waits.session_id)
    FROM sys.dm_pdw_waits waits
        JOIN sys.dm_pdw_exec_requests requests
        ON waits.request_id=requests.request_id --WHERE waits.request_id = 'QID####'
        JOIN sys.dm_pdw_exec_sessions sessions
        ON waits.session_id = sessions.session_id
            AND requests.[status] = 'Suspended'
)

-- For Test
-- SET @suspend_session_count = 10

IF @suspend_session_count > @threshold
    BEGIN
    RAISERROR('Suspened session reached threhold, please check the root cause and fix ASAP.',16,1)
    END

END
GO
