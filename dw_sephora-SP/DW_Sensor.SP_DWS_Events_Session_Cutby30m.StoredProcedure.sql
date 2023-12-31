/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Events_Session_Cutby30m]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Events_Session_Cutby30m] @dt [VARCHAR](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-18       wangzhichun        Initial Version
-- 2022-08-10       wangzhichun        格式调整
-- ========================================================================================
delete  from [DW_Sensor].[DWS_Events_Session_Cutby30m] where dt=@dt
Insert into  [DW_Sensor].[DWS_Events_Session_Cutby30m]
select
       date,
       time,
       event,
       ss_app_version,
       ss_lib_version,
       user_id,
       distinct_id,
       row_num,
       sum(case
             when Session_length>=30
               then 1 else 0
           end) over(partition by user_id,platform_type,system_type order by row_num ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) +1 AS sessionid,
       Session_length,
       op_code,
       page_id,
       pageid_wo_prefix,
       action_id,
       ss_url,
       H5_page_id,
       platform_type,
       ss_screen_name,
       ss_url_path,
       page_type_detail,
       page_type,
       system_type,
       vip_card,
       vip_card_type,
       ss_is_first_day,
       if_success,
       ss_latest_utm_source,
       ss_latest_utm_medium,
       ss_latest_utm_campaign,
       ss_latest_utm_content,
       ss_utm_content,
       page_detail,
       segment_id,
       current_timestamp as insert_timestamp,
       dt
  from
      (
       select
              row_number() over (partition by platform_type,system_type,user_id order by time)  as row_num,
              date,
              time,
              event,
              ss_app_version,
              ss_lib_version,
              user_id,
              distinct_id,
              ss_url,
              case
                when ss_url like 'https://%.sephora.cn/campaign/%/%'
                  then substring(ss_url,charindex('/',ss_url,PATINDEX('%campaign/%/%',ss_url))+1,charindex('/',ss_url,PATINDEX('%campaign/%/%',ss_url)+9)-charindex('/',ss_url,PATINDEX('%campaign/%/%',ss_url))-1 )
              end as H5_page_id,         --第一个参数是campaign后面第一个'/'的位置，第二个参数是campaign后面两个'/'之间长度
              case
                when platform_type like 'Mini%Program%'
                  then 'MINIPROGRAM'
                when platform_type in ('app','APP')
                  then 'APP'
                when platform_type in ('web')
                  then 'PC'
				when platform_type is null and ss_Lib='MiniProgram'
				  then 'MINIPROGRAM'
                else upper(platform_type)
              end as platform_type,
              ss_screen_name,
              ss_url_path,
              page_type_detail,
              page_type,
              system_type,
              page_id,
              case
                when CHARINDEX('_',page_id)=0             --Page ID 本身没有前缀后缀
                  then page_id
                when CHARINDEX('[',page_id)>0 and CHARINDEX(']',page_id)>0          --AEM Page ID，带有[]
                  then substring(page_id,CHARINDEX('[',page_id)+1,CHARINDEX(']',page_id)-CHARINDEX('[',page_id)-1)
                when len(page_id)-PATINDEX('%[^0-9]%',reverse( page_id))-PATINDEX('%[0-9]%', page_id)<1                --Page ID 只有前缀没有后缀
                  then substring(page_id,PATINDEX('%[0-9]%', page_id), PATINDEX('%[^0-9]%',reverse( page_id))-1)
                when len(page_id)-PATINDEX('%[^0-9]%',reverse( page_id))-PATINDEX('%[0-9]%', page_id)>1
                  then substring(page_id,PATINDEX('%[0-9]%', page_id),len(page_id)-PATINDEX('%[^0-9]%',reverse( page_id))-PATINDEX('%[0-9]%', page_id)+1)
                else page_id
              end as pageid_wo_prefix,
              action_id,
              vip_card,
              vip_card_type,
              ss_is_first_day,
              if_success,
              ss_latest_utm_source,
              ss_latest_utm_medium,
              ss_latest_utm_campaign,
              ss_latest_utm_content,
              op_code,
              ss_utm_content,
              page_detail,
              segment_id,
              insert_timestamp,
              dt,
              CASE
                WHEN datediff(mi,lag(time,1) over(partition by platform_type,system_type,user_id order by time),time) is null
                  then 0
                ELSE datediff(mi,lag(time,1) over(partition by platform_type,user_id,system_type order by time),time)
              END AS Session_length
         from
              STG_Sensor.Events
        where
              dt=@dt
       ) TEMP
 GROUP BY
       date,
       time,
       event,
       ss_app_version,
       ss_lib_version,
       user_id,
       distinct_id,
       row_num,
       Session_length,
       op_code,
       page_id,
       pageid_wo_prefix,
       H5_page_id,
       action_id,
       ss_url,
       platform_type,
       ss_screen_name,
       ss_url_path,
       page_type_detail,
       page_type,
       system_type,
       vip_card,
       vip_card_type,
       ss_is_first_day,
       if_success,
       ss_latest_utm_source,
       ss_latest_utm_medium,
       ss_latest_utm_campaign,
       ss_latest_utm_content,
       ss_utm_content,
       page_detail,
       segment_id,
       insert_timestamp,
       dt
End
GO
