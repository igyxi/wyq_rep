/****** Object:  StoredProcedure [STG_TD].[SP_Pipeline_RunLog]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TD].[SP_Pipeline_RunLog] @OS [NVARCHAR](64),@PipelineName [NVARCHAR](255),@FromTable [NVARCHAR](255),@ToTable [NVARCHAR](255),@DataDate [DATE],@Status [NVARCHAR](64) AS

insert into STG_TD.Tb_Pipeline_RunLog
select getdate(),@OS,@PipelineName,@FromTable,@ToTable,@DataDate,@Status
GO
