/****** Object:  StoredProcedure [DWD].[SP_DIM_OneID_Tags]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_OneID_Tags] @filename [nvarchar](20) AS
BEGIN

--TRUNCATE TABLE DWD.DIM_OneID_Tags;

DELETE FROM DWD.DIM_OneID_Tags WHERE [filename]=@filename;

INSERT INTO DWD.DIM_OneID_Tags
SELECT 
	oneid,
	identity_info,
	profile_info,
	tag_info,
	valuetag_info,
	@filename AS [filename],
	dateadd(hour,8,getdate()) as insert_time
FROM
	ODS_CDP.DIM_OneID_Tags
;
END
GO
