/****** Object:  StoredProcedure [ODS_Sensor].[Delete_events_more]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Sensor].[Delete_events_more] AS
BEGIN
delete from ODS_Sensor.events where date = '2021-03-17' and dt > '2021-03-17';
delete from ODS_Sensor.events where date = '2021-03-18' and dt > '2021-03-18';
delete from ODS_Sensor.events where date = '2021-03-19' and dt > '2021-03-19';
delete from ODS_Sensor.events where date = '2021-03-20' and dt > '2021-03-20';
delete from ODS_Sensor.events where date = '2021-03-21' and dt > '2021-03-21';
delete from ODS_Sensor.events where date = '2021-03-22' and dt > '2021-03-22';
delete from ODS_Sensor.events where date = '2021-03-23' and dt > '2021-03-23';
delete from ODS_Sensor.events where date = '2021-03-24' and dt > '2021-03-24';
delete from ODS_Sensor.events where date = '2021-03-25' and dt > '2021-03-25';
delete from ODS_Sensor.events where date = '2021-03-26' and dt > '2021-03-26';
delete from ODS_Sensor.events where date = '2021-03-27' and dt > '2021-03-27';
delete from ODS_Sensor.events where date = '2021-03-28' and dt > '2021-03-28';
delete from ODS_Sensor.events where date = '2021-03-29' and dt > '2021-03-29';
delete from ODS_Sensor.events where date = '2021-03-30' and dt > '2021-03-30';
delete from ODS_Sensor.events where date = '2021-03-31' and dt > '2021-03-31';
delete from ODS_Sensor.events where date = '2021-04-01' and dt > '2021-04-01';
delete from ODS_Sensor.events where date = '2021-04-02' and dt > '2021-04-02';
delete from ODS_Sensor.events where date = '2021-04-03' and dt > '2021-04-03';
delete from ODS_Sensor.events where date = '2021-04-04' and dt > '2021-04-04';
delete from ODS_Sensor.events where date = '2021-04-05' and dt > '2021-04-05';
delete from ODS_Sensor.events where date = '2021-04-06' and dt > '2021-04-06';
delete from ODS_Sensor.events where date = '2021-04-07' and dt > '2021-04-07';
delete from ODS_Sensor.events where date = '2021-04-08' and dt > '2021-04-08';
delete from ODS_Sensor.events where date = '2021-04-09' and dt > '2021-04-09';
delete from ODS_Sensor.events where date = '2021-04-10' and dt > '2021-04-10';
delete from ODS_Sensor.events where date = '2021-04-11' and dt > '2021-04-11';
end
GO
