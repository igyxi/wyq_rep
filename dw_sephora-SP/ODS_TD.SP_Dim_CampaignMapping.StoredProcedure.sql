/****** Object:  StoredProcedure [ODS_TD].[SP_Dim_CampaignMapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_Dim_CampaignMapping] AS

truncate table DW_TD.Tb_Dim_CampaignMapping

select id,cn_name,en_name
into #channel
from ODS_TD.Tb_Dim_Channels

if (select count(*) from ODS_TD.Tb_Dim_Channels where id in ('45108'
-- , '47465'抖音
))=0
begin
	insert into #channel
	select '45108' id,N'语斐' cn_name,N'Yufei' en_name
-- 	union all
-- 	select '47465' id,N'抖音' cn_name,N'Douyin' en_name(20220222注释，已从adf插入到ODS_TD.Tb_Dim_Channels表中)
end

insert into DW_TD.Tb_Dim_CampaignMapping
select
    a.appkey,
    a.campaign_id CampaignId,
    descript CampaignName,
    b.groupid CampaignGroupId,
    c.[name] CampaignGroupName,
    a.channelid ChannelId,
    case when a.channelid=533 then N'Google Adwords' else d.cn_name end ChannelName
from ODS_TD.Tb_Dim_Campaign a
left join ODS_TD.Tb_Dim_CampaignAndGroup b on a.campaign_id=b.campaignid
left join ODS_TD.Tb_Dim_CampaignGroup c on b.groupid=c.id
left join #channel d on a.channelid=d.id

drop table #channel


GO
