/****** Object:  StoredProcedure [RPT].[SP_RPT_Private_Domain_User_Purcharse_Monthly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Private_Domain_User_Purcharse_Monthly] @dt [VARCHAR](10) AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       fenglu        Initial Version
-- 2022-11-10       fenglu        Change Table DWD.Fact_Member_MNP_Register of unionid and member_card is One-To-Mach
-- 2022-12-09       litao         ADD store_code not in ('DV','EB','GE','GN','HR','IT','OMR','RO','RS','South','SU','SU - HQ','West') and member_card not like 'e%'
-- ========================================================================================

DELETE FROM RPT.RPT_Private_Domain_User_Purcharse_Monthly WHERE Month_date = cast(cast(@dt as date) as varchar(7));

WITH stat_data as (
	SELECT month_,unionid
	       ,COUNT(DISTINCT channel) as cnt
	       ,STRING_AGG(CONVERT(NVARCHAR(max), channel), ',') AS channel
	FROM (
		SELECT DISTINCT 'SmartBA' as channel 
		        ,format(bind_time, 'yyyy-MM') as month_
		        ,unionid
		FROM (
			SELECT bind_time
			       ,unionid
			       ,ba_staff_no
			       ,status
			       ,row_number() over (partition by unionid, ba_staff_no order by bind_time desc) as ro     
			FROM DWD.Fact_Member_BA_Bind
			WHERE bind_time IS NOT NULL AND unionid IS NOT NULL 
			and store_code not in ('DV','EB','GE','GN','HR','IT','OMR','RO','RS','South','SU','SU - HQ','West')
		) a
		WHERE ro = 1 AND status = 0 AND bind_time >= '2022-01-01'
		UNION ALL 
		SELECT DISTINCT N'社群' as channel 
		        ,format(join_time, 'yyyy-MM') as month_
		        ,unionid
		FROM DWD.Fact_Member_Wechat_Group_Join
		WHERE unionid IS NOT NULL AND join_time >= '2022-01-01'
	) a 
	GROUP BY month_,unionid
)
-- 取每个月最后一次的会员卡等级
, month_member_card_grade_data as (
	SELECT member_card,member_card_grade,month_
	FROM (
		SELECT member_card,SUBSTRING(card_type_name,3,100) as member_card_grade 
		       ,format(start_time, 'yyyy-MM') as month_
		       ,ROW_NUMBER () OVER (PARTITION BY member_card,format(start_time, 'yyyy-MM') ORDER BY end_time DESC) as rnt
		FROM DWD.DIM_Member_Card_Grade_SCD
	) a 
	WHERE rnt = 1
)
-- 订单的每个月最后一次的卡别 R12 全渠道销售情况
, sales_order_buyer as (
	SELECT t1.place_month as start_month
	         ,t1.member_card
	         ,t2.card_type_name
	         ,SUM(t1.sales_amount) AS r12_amount
	         ,COUNT(DISTINCT t1.sales_order_number) as r12_order
	FROM (
		 SELECT sales_order_number
				  ,member_card
				  ,place_time
				  ,CONVERT(varchar(7),place_time,121) as place_month
				  ,item_apportion_amount as sales_amount
		 FROM DWD.Fact_Sales_Order a
		 WHERE is_placed = 1 
              AND CONVERT(varchar(7),place_time,121) = cast(cast(@dt as date) as varchar(7))
         and coalesce(member_card,'999') not like 'e%'
	) t1
	LEFT JOIN (
		 SELECT *
		 FROM (
			  SELECT CONVERT(varchar(7),start_time,121) as start_month
			          ,CONVERT(varchar(7),end_time,121) as end_month
					  ,member_card
	                  ,SUBSTRING(card_type_name,3,100) as card_type_name
					  ,ROW_NUMBER() over(PARTITION by member_card,CONVERT(varchar(7),start_time,121) order by end_time desc) as rk
			  FROM DWD.DIM_Member_Card_Grade_SCD
			  WHERE card_type_name is not null 
		 ) t1
		 WHERE rk = 1
	) t2 ON t1.member_card = t2.member_card AND t1.place_month >= t2.start_month AND t1.place_month <= t2.end_month
	WHERE t1.place_month >= cast(cast(dateadd(month,-11,@dt) as date) as varchar(7))
	       AND t1.place_month <= cast(cast(@dt as date) as varchar(7))
	GROUP BY t1.place_month ,t1.member_card ,t2.card_type_name
) 
, all_data11 as (
	SELECT b.channel 
	        ,b.month_
	        ,b.unionid
	        ,c.member_card
	        ,b.cnt
	FROM stat_data b
	LEFT JOIN (
		SELECT unionid,member_card
		FROM (
			SELECT unionid,member_card,ROW_NUMBER () OVER (PARTITION BY unionid ORDER BY mnp_bind_mobile_time DESC) AS rnt
		 	FROM DWD.Fact_Member_MNP_Register
	 	) a 
	 	WHERE rnt = 1
	) c ON b.unionid = c.unionid
)
, all_data as (
	SELECT b.channel 
	        ,b.month_
	        ,b.unionid
	        ,b.member_card
	        ,d.member_card_grade
	        ,b.cnt
	FROM all_data11 b
	LEFT JOIN month_member_card_grade_data d ON b.month_ = d.month_ AND b.member_card = d.member_card
	WHERE b.month_ = cast(cast(@dt as date) as varchar(7))
)

INSERT INTO RPT.RPT_Private_Domain_User_Purcharse_Monthly
SELECT a.month_ as Month_date
        ,'SmartBA' as channel
        ,COALESCE(a.member_card_grade,N'未知') as card_type
        ,COUNT(DISTINCT COALESCE(a.member_card,a.unionid)) as t_num
        ,SUM(COALESCE(e.r12_amount,0)) as r12_amount
        ,SUM(COALESCE(e.r12_order,0)) as r12_order_cnt
        ,COUNT(DISTINCT e.member_card) as R12_Buyer_cnt
        ,CURRENT_TIMESTAMP as insert_timestamp
FROM all_data a
LEFT JOIN sales_order_buyer e ON a.member_card = e.member_card AND a.month_ = e.start_month
WHERE a.channel LIKE '%SmartBA%' 
GROUP BY a.month_,COALESCE(a.member_card_grade,N'未知')
UNION ALL 
SELECT a.month_ as Month_date
        ,N'社群' as channel
        ,COALESCE(a.member_card_grade,N'未知') as card_type
        ,COUNT(DISTINCT COALESCE(a.member_card,a.unionid)) as t_num
        ,SUM(COALESCE(e.r12_amount,0)) as r12_amount
        ,SUM(COALESCE(e.r12_order,0)) as r12_order_cnt
        ,COUNT(DISTINCT e.member_card) as R12_Buyer_cnt
        ,CURRENT_TIMESTAMP as insert_timestamp
FROM all_data a
LEFT JOIN sales_order_buyer e ON a.member_card = e.member_card AND a.month_ = e.start_month
WHERE a.channel LIKE N'%社群%' 
GROUP BY a.month_,COALESCE(a.member_card_grade,N'未知')
UNION ALL 
SELECT a.month_ as Month_date
        ,'Only SmartBA' as channel
        ,COALESCE(a.member_card_grade,N'未知') as card_type
        ,COUNT(DISTINCT COALESCE(a.member_card,a.unionid)) as t_num
        ,SUM(COALESCE(e.r12_amount,0)) as r12_amount
        ,SUM(COALESCE(e.r12_order,0)) as r12_order_cnt
        ,COUNT(DISTINCT e.member_card) as R12_Buyer_cnt
        ,CURRENT_TIMESTAMP as insert_timestamp
FROM all_data a
LEFT JOIN sales_order_buyer e ON a.member_card = e.member_card AND a.month_ = e.start_month
WHERE a.cnt = 1 AND a.channel = 'SmartBA' 
GROUP BY a.month_,COALESCE(a.member_card_grade,N'未知')
UNION ALL 
SELECT a.month_ as Month_date
        ,N'Only 社群' as channel
        ,COALESCE(a.member_card_grade,N'未知') as card_type
        ,COUNT(DISTINCT COALESCE(a.member_card,a.unionid)) as t_num
        ,SUM(COALESCE(e.r12_amount,0)) as r12_amount
        ,SUM(COALESCE(e.r12_order,0)) as r12_order_cnt
        ,COUNT(DISTINCT e.member_card) as R12_Buyer_cnt
        ,CURRENT_TIMESTAMP as insert_timestamp
FROM all_data a
LEFT JOIN sales_order_buyer e ON a.member_card = e.member_card AND a.month_ = e.start_month
WHERE a.cnt = 1 AND a.channel = N'社群' 
GROUP BY a.month_,COALESCE(a.member_card_grade,N'未知')
UNION ALL 
SELECT a.month_ as Month_date
        ,'Both' as channel
        ,COALESCE(a.member_card_grade,N'未知') as card_type
        ,COUNT(DISTINCT COALESCE(a.member_card,a.unionid)) as t_num
        ,SUM(COALESCE(e.r12_amount,0)) as r12_amount
        ,SUM(COALESCE(e.r12_order,0)) as r12_order_cnt
        ,COUNT(DISTINCT e.member_card) as R12_Buyer_cnt
        ,CURRENT_TIMESTAMP as insert_timestamp
FROM all_data a
LEFT JOIN sales_order_buyer e ON a.member_card = e.member_card AND a.month_ = e.start_month
WHERE a.cnt = 2 
GROUP BY a.month_,COALESCE(a.member_card_grade,N'未知')
UNION ALL 
SELECT start_month as Month_date
        ,N'全公司' as channel
        ,COALESCE(card_type_name,N'未知') as card_type
        ,COUNT(DISTINCT member_card) as t_num
        ,SUM(COALESCE(r12_amount,0)) as r12_amount
        ,SUM(COALESCE(r12_order,0)) as r12_order_cnt
        ,COUNT(DISTINCT member_card) as R12_Buyer_cnt
        ,CURRENT_TIMESTAMP as insert_timestamp
FROM sales_order_buyer
GROUP BY start_month,COALESCE(card_type_name,N'未知')

END 
GO
