/****** Object:  StoredProcedure [ODS_BEA].[SP_Beauty_Send_Timeline_Content_JsonFormat]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_BEA].[SP_Beauty_Send_Timeline_Content_JsonFormat] AS

BEGIN
		IF OBJECT_ID('tempdb..#tempSend_Timline') IS NOT NULL
		DROP TABLE #tempSend_Timline
 
	CREATE TABLE #tempSend_Timline
	(
		[post_id]   NVARCHAR(100) NULL,
		[Content_Json] NVARCHAR(MAX) NULL
	)
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		HEAP
	)

	INSERT INTO #tempSend_Timline
	SELECT post_id,
		   replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace([content],N'\\',N''),N'\n',N'|n'),N'\',N''),N':"{',N':{"'),N'}"',N'}'),N':{""',N':{"'),N'"[{',N'[{'),N'}]"',N'}]'),N'[{levelOneId"',N'[{"levelOneId"'),N'70:',N'"70":'),N'250:',N'"250":'),N'750:',N'"750":'),N'100:',N'"100":'),N'1080:',N'"1080":'),N'360:',N'"360":'),N'眼霜"#',N'眼霜#'),N'双萃" #',N'双萃 #'),N'精华" #',N'精华 #'),N'涂出水"的',N'涂出水”的'),N'面霜"称号',N'面霜“称号'),N'药"的',N'药“的'),N'娇韵诗"超速眼霜',N'娇韵诗“超速眼霜'),N'娇韵诗"黄金双萃',N'娇韵诗“黄金双萃'),N'娇韵诗"王牌精华',N'娇韵诗“王牌精华'),N'护肤"  修复',N'护肤”修复'),N'涂出水"的',N'涂出水”的'),N'裸纱"香水',N'裸纱“香水'),N'绿"丝',N'绿“丝'),N'的"幕后英雄"实质',N'的”幕后英雄“实质'),N'雪水"美白',N'雪水“美白'),N'的"葡萄水"大',N'的”葡萄水“大'),N'葡萄水"大',N' 葡萄水“大'),N'定"情"吻',N'定”情“吻'),N'LAB"的',N' LAB”的'),N'生姜"高光',N'生姜“高光'),N'开挂",兰蔻',N'开挂”,兰蔻'),N'｛武汉加油}',N'｛武汉加油}"'),N'補水王"的',N'補水王“的'),N'会无限回购的！！！""',N'会无限回购的！！！"'),N'正红"＃',N'正红“＃'),N'面膜"选妃"之路',N'面膜“选妃“之路'),N'特产"哈',N'特产“哈'),N'柏林少女"',N'柏林少女“'),N'能量弹"它的',N'能量弹“它的'),N'北坡"）',N'北坡“）'),N'睛"彩无限！',N'睛“彩无限！'),N'菁纯"   还有   "水漾清透防晒" 我',N'菁纯“   还有   ”水漾清透防晒“ 我'),N'推荐""娇润诗家的唇霜"，',N'推荐”“娇润诗家的唇霜”，'),N'普通1号色""  。',N'普通1号色  。'),N'，""菁纯眼霜"，',N'，“”菁纯眼霜“，'),N'雪水"w',N'雪水“w'),N'重头戏"。',N'重头戏”。'),N',"润而不油,吸收的超快",去',N',”润而不油,吸收的超快“,去'),N'亲妈"霜',N'亲妈“霜'),N'破晓之时"#出行',N'破晓之时“#出行'),N'穿"高跟鞋',N'”穿高跟鞋'),N'紧绷"的',N'紧绷“的'),N'斑弹"皮肤',N'斑弹“皮肤'),N'现男友"护眼秘籍',N'现男友”护眼秘籍'),N'明亮|n"r|nt卡卡',N'明亮|n“r|nt卡卡'),N'还是"女主专属"丝芙兰',N'还是”女主专属“丝芙兰'),N'亲妈"雅诗兰黛',N'亲妈“雅诗兰黛'),N'职场"飒"爽风',N'职场”飒“爽风'),N'。"急救利器"皮肤',N'。”急救利器“皮肤'),N'缺哪补哪"（',N'缺哪补哪“（'),N'高光拌饭""💫',N'高光拌饭💫'),N'u0014u0014" 我',N'u0014u0014“ 我'),N'甘露"嘻嘻',N'甘露“嘻嘻'),N'有"残留"像',N'有”残留“像'),N'氧化危肌"。',N'氧化危肌“。'),N'鲨烷"成分',N'鲨烷“成分'),N'微粒"都是',N'微粒“都是'),N'亮肤小油灯"，',N'亮肤小油灯“，'),N'气垫"特别',N'气垫“特别'),N'一样的"零毛',N'一样的“零毛'),N'光谷"这下',N'光谷“这下'),N'舒缓肌肤""',N'舒缓肌肤“"'),N'专利" ，',N'专利“ ，'),N'高光" 在',N'高光“ 在'),N'因为"脏"！',N'因为”脏“！'),N'因为妆"，',N'因为妆“，'),N'I love you"。',N'I love you“。'),N'颜色"，大部分',N'颜色“，大部分'),N'产品！ ""',N'产品！ ”"'),N'开挂",兰蔻196',N'开挂“,兰蔻196'),N'用"挺好用的"来',N'用”挺好用的“来'),N'液体面霜"，水',N'液体面霜“，水'),N'肌肤"大口喝水"；',N'肌肤”大口喝水“；'),N'的"水离子通道"',N'的”水离子通道“'),N'水润特饮"，',N'水润特饮“，'),N'牢 固"？',N'牢 固“？'),N'迪奥的"的',N'迪奥的“的'),N'带它了！""',N'带它了！”"'),N'|nS"100"',N'|nS”100“'),N'保湿饮料"和"滋润甘露 "',N'保湿饮料”和“滋润甘露 “'),N'就柴"了',N'就柴“了'),N'"确认的水"，',N'”确认的水“，'),N'不少呢.""',N'不少呢.“"'),N'～～""',N'～～“"'),N'抗皱系列"，',N'抗皱系列“，'),N'睛"彩复工妆',N'睛“彩复工妆'),N'记忆"弹性',N'记忆“弹性'),N'lab～""',N'lab～“"'),N'七"待已久|n"夕"望',N'七”待已久|n夕“望'),N'正面意义"，这句话',N'正面意义“，这句话'),N'号称"断货王"的',N'号称”断货王“的'),N'"红腰子"',N'”红腰子“'),N'十月"芙"利',N'十月”芙“利'),N'罩"样',N'罩“样'),N'小马达"～',N'小马达“～'),N'本肌"状态',N'本肌“状态'),N'姐妹啦！"",',N'姐妹啦！“",'),N'清爽！""',N'清爽！“"'),N'定格"年轻',N'定格“年轻'),N'"磁性粘土"，',N'”磁性粘土“，'),N'嫁给我吧！"",',N'嫁给我吧！“",'),N'眼霜" #话题',N'眼霜” #话题'),N'桃心"笑靥"#唇势',N'桃心”笑靥“#唇势'),N'晶露"它',N'晶露“它'),N'晚霜"娇韵诗',N'晚霜“娇韵诗'),N'Music Festival"这支',N'Music Festival“这支'),N'职场 "飒"爽风',N'职场 ”飒“爽风'),N'倔强。"的感觉',N'倔强。“的感觉'),N'用的"来',N'用的“来'),N'我的脸 "',N'我的脸 “'),N'效果"1/2',N'效果“1/2'),N'困扰" 看到',N'困扰” 看到'),N'痘胶"卓研',N'痘胶“卓研'),N'肤质呢"",',N'肤质呢”",'),N'嫁给我吧！"",',N'嫁给我吧！“",'),N'定格"年轻',N'定格“年轻'),N'6277"#6277',N'6277“#6277'),N'|n简"’',N'|n简“’'),N'犯错"的',N'犯错“的'),N'r"高效两步 懒人福音" 嗯',N'r”高效两步 懒人福音“ 嗯'),N'Dior7"70":樱桃红',N'Dior7”70“:樱桃红'),N'物资"里的',N'物资“里的'),N'"海藻补水面膜"。',N'”海藻补水面膜“。'),N'干燥Say88"',N'干燥Say88“'),N'黑科技"。',N'黑科技“。'),N'"SOS急救面膜"重磅',N'”SOS急救面膜“重磅'),N'对"世上无难事 只要肯放弃"',N'对”世上无难事 只要肯放弃“'),N'小黄油"名称',N'小黄油“名称'),N'秒变"猪刚鬣"',N'秒变”猪刚鬣“'),N'元气棒"这',N'元气棒“这'),N'有着"熬夜元气棒"著称',N'有着”熬夜元气棒“著称'),N'紫熨斗"致力',N'紫熨斗“致力'),N'总之"哪里',N'总之“哪里'),N'定制"的坑',N'定制“的坑'),N'定制"护肤"深深',N'定制”护肤“深深'),N'这款"智慧"去角质',N'这款”智慧“去角质'),N'是"你',N'是“你'),N'了"hhhhh',N'了“hhhhh'),N'璀璨"的',N'璀璨“的'),N'的"国货之光"相宜	',N'的国货之光相宜'),N'"呼吸""的',N'呼吸”的'),N'""还记得Yang',N'"“还记得Yang'),N'小金甁"r想怎么变，就怎么变！r护肤品里的"巴拉巴拉小魔仙"r',N'小金甁”r想怎么变，就怎么变！r护肤品里的”巴拉巴拉小魔仙“r'),N':"5.20"',N':"5.20“'),N':""丝芙兰大概',N':"丝芙兰大概'),N':""我家T先生',N':"我家T先生'),N':""感谢丝芙兰送来的',N':"感谢丝芙兰送来的'),N':""作为女人',N':"作为女人'),N':""睛“彩',N':"”睛“彩'),N':""藻力美肌"',N':"“藻力美肌“'),N'x" onerror="',N'x” onerror=“'),N')">",',N')”>",'),N'华露"芯肌"小金瓶',N'华露芯肌小金瓶'),N'芯肌"小金瓶',N'芯肌小金瓶'),N'冻龄"秘诀',N'冻龄秘诀'),N'+消du" ",',N'+消du",'),N'黄金双萃" ，',N'黄金双萃 ，'),N':"晴"彩',N':"晴彩'),N'纪梵希"唇',N'纪梵希唇'),N'磁性粘土"，',N'磁性粘土，'),N'一种"姐',N'一种姐'),N'美哒"的',N'美哒的'),N'这只"The',N'这只The'),N'维生素B5"和',N'维生素B5和'),N'图鉴"卡片',N'图鉴卡片'),N'塑料瓶~"",',N'塑料瓶~",'),N'细胞水"-',N'细胞水-'),N'水润屏障。 ​​​​"",',N'水润屏障。 ​​​​",'),N'用心❤️"",',N'用心❤️",'),N'好用~"",',N'好用~",'),N'莲花"，绿茶',N'莲花，绿茶'),N'手撕 "白莲花"",',N'手撕白莲花",'),N':""#踏青出游',N':"#踏青出游'),N'无限美景。""}',N'无限美景。"}') AS [Content1]
	FROM [ODS_BEA].[Beauty_Send_Timeline] WITH(NOLOCK)
	--where post_id='e1d57d20-5244-11ea-9832-cd0a333124fb'
	WHERE isjson(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace([content],N'\\',N''),N'\n',N'|n'),N'\',N''),N':"{',N':{"'),N'}"',N'}'),N':{""',N':{"'),N'"[{',N'[{'),N'}]"',N'}]'),N'[{levelOneId"',N'[{"levelOneId"'),N'70:',N'"70":'),N'250:',N'"250":'),N'750:',N'"750":'),N'100:',N'"100":'),N'1080:',N'"1080":'),N'360:',N'"360":'),N'眼霜"#',N'眼霜#'),N'双萃" #',N'双萃 #'),N'精华" #',N'精华 #'),N'涂出水"的',N'涂出水”的'),N'面霜"称号',N'面霜“称号'),N'药"的',N'药“的'),N'娇韵诗"超速眼霜',N'娇韵诗“超速眼霜'),N'娇韵诗"黄金双萃',N'娇韵诗“黄金双萃'),N'娇韵诗"王牌精华',N'娇韵诗“王牌精华'),N'护肤"  修复',N'护肤”修复'),N'涂出水"的',N'涂出水”的'),N'裸纱"香水',N'裸纱“香水'),N'绿"丝',N'绿“丝'),N'的"幕后英雄"实质',N'的”幕后英雄“实质'),N'雪水"美白',N'雪水“美白'),N'的"葡萄水"大',N'的”葡萄水“大'),N'葡萄水"大',N' 葡萄水“大'),N'定"情"吻',N'定”情“吻'),N'LAB"的',N' LAB”的'),N'生姜"高光',N'生姜“高光'),N'开挂",兰蔻',N'开挂”,兰蔻'),N'｛武汉加油}',N'｛武汉加油}"'),N'補水王"的',N'補水王“的'),N'会无限回购的！！！""',N'会无限回购的！！！"'),N'正红"＃',N'正红“＃'),N'面膜"选妃"之路',N'面膜“选妃“之路'),N'特产"哈',N'特产“哈'),N'柏林少女"',N'柏林少女“'),N'能量弹"它的',N'能量弹“它的'),N'北坡"）',N'北坡“）'),N'睛"彩无限！',N'睛“彩无限！'),N'菁纯"   还有   "水漾清透防晒" 我',N'菁纯“   还有   ”水漾清透防晒“ 我'),N'推荐""娇润诗家的唇霜"，',N'推荐”“娇润诗家的唇霜”，'),N'普通1号色""  。',N'普通1号色  。'),N'，""菁纯眼霜"，',N'，“”菁纯眼霜“，'),N'雪水"w',N'雪水“w'),N'重头戏"。',N'重头戏”。'),N',"润而不油,吸收的超快",去',N',”润而不油,吸收的超快“,去'),N'亲妈"霜',N'亲妈“霜'),N'破晓之时"#出行',N'破晓之时“#出行'),N'穿"高跟鞋',N'”穿高跟鞋'),N'紧绷"的',N'紧绷“的'),N'斑弹"皮肤',N'斑弹“皮肤'),N'现男友"护眼秘籍',N'现男友”护眼秘籍'),N'明亮|n"r|nt卡卡',N'明亮|n“r|nt卡卡'),N'还是"女主专属"丝芙兰',N'还是”女主专属“丝芙兰'),N'亲妈"雅诗兰黛',N'亲妈“雅诗兰黛'),N'职场"飒"爽风',N'职场”飒“爽风'),N'。"急救利器"皮肤',N'。”急救利器“皮肤'),N'缺哪补哪"（',N'缺哪补哪“（'),N'高光拌饭""💫',N'高光拌饭💫'),N'u0014u0014" 我',N'u0014u0014“ 我'),N'甘露"嘻嘻',N'甘露“嘻嘻'),N'有"残留"像',N'有”残留“像'),N'氧化危肌"。',N'氧化危肌“。'),N'鲨烷"成分',N'鲨烷“成分'),N'微粒"都是',N'微粒“都是'),N'亮肤小油灯"，',N'亮肤小油灯“，'),N'气垫"特别',N'气垫“特别'),N'一样的"零毛',N'一样的“零毛'),N'光谷"这下',N'光谷“这下'),N'舒缓肌肤""',N'舒缓肌肤“"'),N'专利" ，',N'专利“ ，'),N'高光" 在',N'高光“ 在'),N'因为"脏"！',N'因为”脏“！'),N'因为妆"，',N'因为妆“，'),N'I love you"。',N'I love you“。'),N'颜色"，大部分',N'颜色“，大部分'),N'产品！ ""',N'产品！ ”"'),N'开挂",兰蔻196',N'开挂“,兰蔻196'),N'用"挺好用的"来',N'用”挺好用的“来'),N'液体面霜"，水',N'液体面霜“，水'),N'肌肤"大口喝水"；',N'肌肤”大口喝水“；'),N'的"水离子通道"',N'的”水离子通道“'),N'水润特饮"，',N'水润特饮“，'),N'牢 固"？',N'牢 固“？'),N'迪奥的"的',N'迪奥的“的'),N'带它了！""',N'带它了！”"'),N'|nS"100"',N'|nS”100“'),N'保湿饮料"和"滋润甘露 "',N'保湿饮料”和“滋润甘露 “'),N'就柴"了',N'就柴“了'),N'"确认的水"，',N'”确认的水“，'),N'不少呢.""',N'不少呢.“"'),N'～～""',N'～～“"'),N'抗皱系列"，',N'抗皱系列“，'),N'睛"彩复工妆',N'睛“彩复工妆'),N'记忆"弹性',N'记忆“弹性'),N'lab～""',N'lab～“"'),N'七"待已久|n"夕"望',N'七”待已久|n夕“望'),N'正面意义"，这句话',N'正面意义“，这句话'),N'号称"断货王"的',N'号称”断货王“的'),N'"红腰子"',N'”红腰子“'),N'十月"芙"利',N'十月”芙“利'),N'罩"样',N'罩“样'),N'小马达"～',N'小马达“～'),N'本肌"状态',N'本肌“状态'),N'姐妹啦！"",',N'姐妹啦！“",'),N'清爽！""',N'清爽！“"'),N'定格"年轻',N'定格“年轻'),N'"磁性粘土"，',N'”磁性粘土“，'),N'嫁给我吧！"",',N'嫁给我吧！“",'),N'眼霜" #话题',N'眼霜” #话题'),N'桃心"笑靥"#唇势',N'桃心”笑靥“#唇势'),N'晶露"它',N'晶露“它'),N'晚霜"娇韵诗',N'晚霜“娇韵诗'),N'Music Festival"这支',N'Music Festival“这支'),N'职场 "飒"爽风',N'职场 ”飒“爽风'),N'倔强。"的感觉',N'倔强。“的感觉'),N'用的"来',N'用的“来'),N'我的脸 "',N'我的脸 “'),N'效果"1/2',N'效果“1/2'),N'困扰" 看到',N'困扰” 看到'),N'痘胶"卓研',N'痘胶“卓研'),N'肤质呢"",',N'肤质呢”",'),N'嫁给我吧！"",',N'嫁给我吧！“",'),N'定格"年轻',N'定格“年轻'),N'6277"#6277',N'6277“#6277'),N'|n简"’',N'|n简“’'),N'犯错"的',N'犯错“的'),N'r"高效两步 懒人福音" 嗯',N'r”高效两步 懒人福音“ 嗯'),N'Dior7"70":樱桃红',N'Dior7”70“:樱桃红'),N'物资"里的',N'物资“里的'),N'"海藻补水面膜"。',N'”海藻补水面膜“。'),N'干燥Say88"',N'干燥Say88“'),N'黑科技"。',N'黑科技“。'),N'"SOS急救面膜"重磅',N'”SOS急救面膜“重磅'),N'对"世上无难事 只要肯放弃"',N'对”世上无难事 只要肯放弃“'),N'小黄油"名称',N'小黄油“名称'),N'秒变"猪刚鬣"',N'秒变”猪刚鬣“'),N'元气棒"这',N'元气棒“这'),N'有着"熬夜元气棒"著称',N'有着”熬夜元气棒“著称'),N'紫熨斗"致力',N'紫熨斗“致力'),N'总之"哪里',N'总之“哪里'),N'定制"的坑',N'定制“的坑'),N'定制"护肤"深深',N'定制”护肤“深深'),N'这款"智慧"去角质',N'这款”智慧“去角质'),N'是"你',N'是“你'),N'了"hhhhh',N'了“hhhhh'),N'璀璨"的',N'璀璨“的'),N'的"国货之光"相宜	',N'的国货之光相宜'),N'"呼吸""的',N'呼吸”的'),N'""还记得Yang',N'"“还记得Yang'),N'小金甁"r想怎么变，就怎么变！r护肤品里的"巴拉巴拉小魔仙"r',N'小金甁”r想怎么变，就怎么变！r护肤品里的”巴拉巴拉小魔仙“r'),N':"5.20"',N':"5.20“'),N':""丝芙兰大概',N':"丝芙兰大概'),N':""我家T先生',N':"我家T先生'),N':""感谢丝芙兰送来的',N':"感谢丝芙兰送来的'),N':""作为女人',N':"作为女人'),N':""睛“彩',N':"”睛“彩'),N':""藻力美肌"',N':"“藻力美肌“'),N'x" onerror="',N'x” onerror=“'),N')">",',N')”>",'),N'华露"芯肌"小金瓶',N'华露芯肌小金瓶'),N'芯肌"小金瓶',N'芯肌小金瓶'),N'冻龄"秘诀',N'冻龄秘诀'),N'+消du" ",',N'+消du",'),N'黄金双萃" ，',N'黄金双萃 ，'),N':"晴"彩',N':"晴彩'),N'纪梵希"唇',N'纪梵希唇'),N'磁性粘土"，',N'磁性粘土，'),N'一种"姐',N'一种姐'),N'美哒"的',N'美哒的'),N'这只"The',N'这只The'),N'维生素B5"和',N'维生素B5和'),N'图鉴"卡片',N'图鉴卡片'),N'塑料瓶~"",',N'塑料瓶~",'),N'细胞水"-',N'细胞水-'),N'水润屏障。 ​​​​"",',N'水润屏障。 ​​​​",'),N'用心❤️"",',N'用心❤️",'),N'好用~"",',N'好用~",'),N'莲花"，绿茶',N'莲花，绿茶'),N'手撕 "白莲花"",',N'手撕白莲花",'),N':""#踏青出游',N':"#踏青出游'),N'无限美景。""}',N'无限美景。"}'))>0

	TRUNCATE TABLE [ODS_BEA].[Beauty_Send_Timeline_Content_JsonFormat]
	
	INSERT INTO [ODS_BEA].[Beauty_Send_Timeline_Content_JsonFormat]
	SELECT [post_id],
		   [Content_Json],
		   JSON_VALUE([Content_Json],N'lax $.mainBody') as mainbody,
		   --JSON_VALUE([Content_Json],N'lax $.templateItems[0].type')as [type],
		   --JSON_VALUE([Content_Json],N'lax $.templateItems[0].extraContent.productId')as productId,
		   --JSON_VALUE([Content_Json],N'lax $.templateItems[0].extraContent.skuId')as skuId,
		   CASE WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[0].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[0].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[0].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[1].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[1].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[1].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[2].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[2].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[2].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[3].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[3].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[3].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[4].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[4].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[4].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[5].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[5].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[5].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[6].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[6].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[6].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[7].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[7].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[7].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[8].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[8].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[8].extraContent.productId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[9].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[9].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[9].extraContent.productId')
		   END AS productId,
		   CASE WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[0].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[0].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[0].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[1].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[1].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[1].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[2].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[2].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[2].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[3].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[3].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[3].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[4].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[4].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[4].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[5].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[5].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[5].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[6].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[6].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[6].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[7].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[7].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[7].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[8].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[8].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[8].extraContent.skuId')
				WHEN JSON_VALUE([Content_Json],N'lax $.templateItems[9].type')=N'SKU' OR JSON_VALUE([Content_Json],N'lax $.templateItems[9].type')=N'PRODUCT' THEN JSON_VALUE([Content_Json],N'lax $.templateItems[9].extraContent.skuId')
		   END AS skuId
	   
	FROM #tempSend_Timline
END
GO
