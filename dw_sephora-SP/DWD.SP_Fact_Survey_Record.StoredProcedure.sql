/****** Object:  StoredProcedure [DWD].[SP_Fact_Survey_Record]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Survey_Record] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-08       wangziming  Initial Version
-- 2023-05-15       wangziming  Add field
-- ========================================================================================
truncate table [DWD].[Fact_Survey_Record];
insert into [DWD].[Fact_Survey_Record]
select 
    a.id as [survey_record_id], 
    a.sid as [survey_id],
    s.name as [survey_name],
    case when c.type = 0 then N'已购物短卷'
    when c.type= 1  then N'未购物问卷'
    when c.type= 2 then N'已购物长卷'
    else null end as [survey_question_type],
    a.store_id as [store_code],
	a.store_name as [store_name], --
	a.store_address as [store_address], --
	a.channel as [channel_id] , --
	a.status as [status] , --
	a.invoiceid as [invoice_id],--
    c.id as [question_id],
    b.aid as [answer_option_id],
    c.question as [question_desc],
    d.[label] as [answer_desc],
    a.member_card as [member_card],
    a.answered_at as [answered_time],
	CURRENT_TIMESTAMP as insert_timestamp
	from [ODS_LoveMeter].[survey_answer_record] a
    left join [ODS_LoveMeter].[survey_activity] s
    ON a.sid = s.id
    left join [ODS_LoveMeter].[survey_answer_detail] b on b.record_id = a.id 
    -- and b.qid = 588
    left join [ODS_LoveMeter].[survey_question] c on c.id = b.qid
    left join [ODS_LoveMeter].[survey_question_option] d on d.id = b.aid
END
GO
