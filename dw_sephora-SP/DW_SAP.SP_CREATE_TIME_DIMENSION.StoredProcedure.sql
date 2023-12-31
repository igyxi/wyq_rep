/****** Object:  StoredProcedure [DW_SAP].[SP_CREATE_TIME_DIMENSION]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SAP].[SP_CREATE_TIME_DIMENSION] AS
/*
SP_CREATE_TIME_DIMENSION: 生成时间维数据
begin_date: 起始时间
end_date:结束时间
*/
 declare @begin_date nvarchar(50)='2017-12-01';
 declare  @end_date nvarchar(50)='2023-12-31';
select @begin_date=isnull(max([Date]),'2017-12-01') from dbo.Dim_date;
set @end_date=convert(date,convert(nvarchar(50),year(getdate())+1)+'-12-31');
declare
@Date date=convert(date,@begin_date),
@v_the_date date,
@Date_key nvarchar(255),
@Year nvarchar(255),
@Quarter nvarchar(255),
@Month nvarchar(255),
@Day nvarchar(255),
@week nvarchar(255),
@weekday nvarchar(255),
@adddays int=1;
WHILE (@Date<=convert(date,@end_date) and not exists(select 1 from dbo.DIm_date where date=@Date))
begin
set @v_the_date=convert(date,@Date);--key值
set @Date_key=convert(nvarchar(20),@v_the_date,112);
set @Year=Year(@v_the_date);
set @Quarter='Q'+convert(nvarchar(255),datepart(quarter,@v_the_date));
set @Month=right('0'+convert(nvarchar(255),month(@v_the_date)),2)+'-'+format(@v_the_date,'MMMM');
set @Day='D'+right('0'+convert(nvarchar(255),day(@v_the_date)),2);
set @week='W'+right('0'+convert(nvarchar(255),datepart(week,@v_the_date)),2);
set @weekday=convert(nvarchar(255),datepart(weekday,@v_the_date))+'-'+datename(weekday,@v_the_date);
insert into dbo.Dim_Date(
[Date_key]
,[Date]
,[Year]
,[Quarter]
,[Month] 
,[Day]
,[week]
,[weekday]
)
values
(
@Date_key,
@v_the_date,
 @Year,
@Quarter,
@Month,
@Day,
@week,
@weekday
);
set @Date=dateadd(day,1,@Date);
--continue;
--if @Date=dateadd(day,-1,convert(date,@end_date))
--break
end

-------- 更新去年同期
update [dbo].[DIM_Date] set lastYear_date_key=[Date_Key]-10000
where date>@begin_date
;

WITH CTE AS (
SELECT * FROM (
SELECT *,ROW_NUMBER()OVER(PARTITION BY [Year] ORDER BY [Date_Key]) AS Num
FROM [dbo].[DIM_Date] 
WHERE week<='week02'  and  date>dateadd(year,-1,@begin_date)
) A WHERE Num<8
) 

--SELECT A.*,B.Date_Key 
UPDATE A SET LastYear_Date_Key=B.Date_Key
FROM [dbo].[DIM_Date] A
LEFT JOIN CTE B ON A.Year-1=B.Year AND A.WeekDay=B.WeekDay
WHERE RIGHT( A.[Date_Key],4)='0101'  and a.date>@begin_date

UPDATE A SET A.LastYear_Date_Key=B.LastYear_Date_Key
FROM [dbo].[DIM_Date] A 
LEFT JOIN (
SELECT [Date_Key],[Year],[LastYear_Date_Key]
FROM [dbo].[DIM_Date] WHERE [Year]>2015 AND RIGHT([Date_Key],4)='0101'
) B ON A.[Year]=B.[Year] and a.date>@begin_date

UPDATE B SET [LastYear_Date_Key]=CONVERT(NVARCHAR(8),DATEADD(DD,Num,CONVERT(DATE,CAST(A.[LastYear_Date_Key] AS NVARCHAR(20)) )) ,112)
FROM [dbo].[DIM_Date] B
LEFT JOIN
(
SELECT [Date_Key],[LastYear_Date_Key]
      ,[Year] ,ROW_NUMBER()OVER(PARTITION BY [Year] ORDER BY [Date_Key])-1 AS Num 
FROM [dbo].[DIM_Date] 
) A
ON A.Date_Key=B.Date_Key
where b.date>@begin_date

UPDATE [dbo].[DIM_Date] SET [LastYear_Date_Key]=NULL
WHERE [Year]>=2010 AND LEFT([LastYear_Date_Key],4)<>[Year]-1 
and date>@begin_date

update [dbo].[DIM_Date] set [LastYear_Date_Key]=date_key-10000
where right(date_key,4)>=1229 and [LastYear_Date_Key] is null
and date>@begin_date

GO
