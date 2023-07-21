SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ODS_CRM].[account_test111111111]
(
	[account_id] [int] NULL,
	 
	[timestamp] [binary] NULL 
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO


insert into [ODS_CRM].[account_test111111111]  
select 11,1;
 



insert into [ODS_CRM].[account_test111111111]  
select account_id,233 as TIMESTAMP from 
[ODS_CRM].[account_test111111111]  
;

select account_id,  TIMESTAMP ,cast(TIMESTAMP as bigint)  from 
[ODS_CRM].[account_test111111111]  