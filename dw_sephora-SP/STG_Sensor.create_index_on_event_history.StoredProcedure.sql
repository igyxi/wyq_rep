/****** Object:  StoredProcedure [STG_Sensor].[create_index_on_event_history]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Sensor].[create_index_on_event_history] AS 
BEGIN
create NONCLUSTERED INDEX idx_event_history_df on [STG_Sensor].[Events_History]
(
    dt ASC
)
end
GO
