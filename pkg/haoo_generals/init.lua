local extension = Package:new("haoo_generals")
extension.extensionName = "haoo_generals"

extension:loadSkillSkelsByPath("./packages/haoo_generals/pkg/haoo_generals/skills")

Fk:loadTranslationTable {
  ["haoo_generals"] = "铁群新设",
  ["haoo"] = "铁",
  ["zheng"] = "蒸",
  ["hg_tie"] = "铁",
  ["hg"] = "洪轨",
  ["lz"] = "浪子",

  ["haoo__hongkainan"] = "洪凯南",
  ["#haoo__hongkainan"] = "那个男人入",
  ["designer:haoo__hongkainan"] = "日理万机",
  ["illustrator:haoo__hongkainan"] = "KayaK&Haoo",
  ["~haoo__hongkainan"] = "……",

  ["haoo__wanglei"] = "王累",
  ["#haoo__wanglei"] = "拼将一死",
  ["designer:haoo__wanglei"] = "Haoo",
  ["~haoo__wanglei"] = "如谏不从，自隔断其绳索，撞死于此地！",

  ["haoo__chenjinkun"] = "沈金坤",
  ["#haoo__chenjinkun"] = "空军司令",
  ["designer:haoo__chenjinkun"] = "Haoo&卝二",
  ["~haoo__chenjinkun"] = "小撸怡情，大撸伤身，强撸灰飞烟灭！",

  ["haoo__hongkainan2"] = "洪楷南",
  ["#haoo__hongkainan2"] = "南樂一覺",
  ["designer:haoo__hongkainan2"] = "Haoo",
  ["illustrator:haoo__hongkainan2"] = "KayaK&Haoo",
  ["~haoo__hongkainan2"] = "年愁今夜未到乡，卧思可哀晓南梁",

  ["hg__tao"] = "涛",
  ["#hg__tao"] = "洪轨",
  ["designer:hg__tao"] = "用户自制",
  ["cv:hg__tao"] = "暂无",
  ["illustrator:hg__tao"] = "暂无",
  ["~hg__tao"] = "",

  ["lz__nanmingbi"] = "南明毕",
  ["#lz__nanmingbi"] = "浪子",
  ["designer:lz__nanmingbi"] = "用户自制",
  ["cv:lz__nanmingbi"] = "暂无",
  ["illustrator:lz__nanmingbi"] = "用户提供",
  ["~lz__nanmingbi"] = "",

  ["sha__guozhou"] = "殺郭周",
  ["#sha__guozhou"] = "阖智议魏",
  ["designer:sha__guozhou"] = "用户自制",
  ["cv:sha__guozhou"] = "暂无",
  ["illustrator:sha__guozhou"] = "暂无",
  ["~sha__guozhou"] = "",

  ["bo__wushilin"] = "吾是琳",
  ["#bo__wushilin"] = "搏",
  ["designer:bo__wushilin"] = "用户自制",
  ["cv:bo__wushilin"] = "暂无",
  ["illustrator:bo__wushilin"] = "暂无",
  ["~bo__wushilin"] = "",

  ["fb__fuban"] = "副班",
  ["#fb__fuban"] = "里织帛柟",
  ["designer:fb__fuban"] = "用户自制",
  ["cv:fb__fuban"] = "暂无",
  ["illustrator:fb__fuban"] = "ShapBy三眼皮猴的万宝路&AI",
  ["~fb__fuban"] = "",

  ["azk__aizhake"] = "艾扎客",
  ["#azk__aizhake"] = "执杖曾翻嵘",
  ["designer:azk__aizhake"] = "用户自制",
  ["cv:azk__aizhake"] = "暂无",
  ["illustrator:azk__aizhake"] = "暂无",
  ["~azk__aizhake"] = "",

  ["bo__zengyixiong"] = "曾奕雄",
  ["#bo__zengyixiong"] = "一世之雄",
  ["designer:bo__zengyixiong"] = "Haoo",
  ["cv:bo__zengyixiong"] = "暂无",
  ["illustrator:bo__zengyixiong"] = "铭zmy",
  ["~bo__zengyixiong"] = "",

  ["ts__yuji"] = "于吉",
  ["#ts__yuji"] = "惑乱人心",
  ["designer:ts__yuji"] = "自制",
  ["cv:ts__yuji"] = "自制",
  ["illustrator:ts__yuji"] = "自制",
  ["~ts__yuji"] = "道法自然，生死无常……",

  ["ts__jiekang"] = "嵇康",
  ["#ts__jiekang"] = "竹林名士",
  ["designer:ts__jiekang"] = "自制",
  ["cv:ts__jiekang"] = "自制",
  ["illustrator:ts__jiekang"] = "自制",
  ["~ts__jiekang"] = "广陵散，终有绝响……",

  ["ts__lin"] = "霖",
  ["#ts__lin"] = "周好",
  ["designer:ts__lin"] = "自制",
  ["cv:ts__lin"] = "自制",
  ["illustrator:ts__lin"] = "自制",
  ["~ts__lin"] = "技多不压身，可惜我只有这一招……",

  ["ts__lin_sp"] = "SP 琳",
  ["#ts__lin_sp"] = "狂赌之渊",
  ["designer:ts__lin_sp"] = "自制",
  ["cv:ts__lin_sp"] = "待定",
  ["illustrator:ts__lin_sp"] = "待定",
  ["~ts__lin_sp"] = "这一次，连命运也输掉了……",
  ["ts__duidu"] = "对赌",
  [":ts__duidu"] = "出牌阶段，你可选择一名其他角色并声明X（X为不小于1的整数，且不大于你与其各自按此方式能支付的数量；牌为手牌与装备区的牌数，对方的体力上限可支付数为空余的勾玉数，即其体力上限与体力值之差），然后选择一项：1.弃置X张牌；2.失去X点体力；3.减X点体力上限（以此法减体力上限时，最少保留1点）?其选择是否接受。若其不接受，你已支付的内容不返还；若其接受，其支付等量的牌、体力或体力上限，然后你与其依次亮出牌堆顶的一张牌并置入弃牌堆，点数相同则重复此流程，直至点数不同。点数较大者获得本次双方以此法弃置且仍在弃牌堆的牌，或回复2X点体力，或加2X点体力上限。你每声明一次赌注，即计为发动一次〖对赌〗。",
  ["ts__tianming"] = "天命",
  [":ts__tianming"] = "出牌阶段，每项限一次，你可声明X（X为1至5的整数），选择一项：1.摸X张牌；2.回复X点体力；3.加X点体力上限。然后你本回合接下来的X次〖对赌〗不能被拒绝（多份承诺并存时，取剩余次数最多的一份）。若你于此回合内发动〖对赌〗的次数达到X，则你于下一个出牌阶段开始时，弃置2X张手牌、失去2X点体力或减2X点体力上限（对应你此前选择的项）；若未达到，则于此回合结束时立即执行，且不再于下个出牌阶段开始时执行。各项分别记账。",
  ["ts__sheyi"] = "奢易",
  [":ts__sheyi"] = "其他角色的出牌阶段开始时，其可获得你任意张手牌或装备区的牌。若如此做，其本回合对你造成的伤害被防止，且其此后获得的牌须交给你，直到累计交给你本次获得牌数两倍的牌（多笔债务先借先还）。其他角色进入濒死状态时，若你的体力值大于0，其可回复1点体力，然后你失去1点体力（每名角色每回合限一次）。若如此做，其本回合对你造成的伤害被防止，且你于回合开始时回复2点体力，然后其失去2点体力。当你进入濒死状态时，所有欠你体力债的角色立即交给你相应的体力。",
  ["ts__bet_cards"] = "牌",
  ["ts__bet_hp"] = "体力值",
  ["ts__bet_maxhp"] = "体力上限",
  ["@ts__tianming_forced-turn"] = "对赌任务",
  ["@ts__tianming_debt_cards"] = "牌债",
  ["@ts__tianming_debt_hp"] = "体力债",
  ["@ts__tianming_debt_maxhp"] = "上限债",
  ["#ts__duidu-active"] = "对赌：选择支付类型、另一名角色与赌注",
  ["#ts__duidu-kind"] = "对赌：选择支付类型",
  ["#ts__duidu-target"] = "对赌：选择一名其他角色",
  ["#ts__duidu-number"] = "对赌：声明赌注（1至%arg）",
  ["#ts__duidu-pay"] = "对赌：弃置%arg张手牌或装备区的牌",
  ["#ts__duidu-accept"] = "对赌：对方已支付，你是否接受数值为%arg的赌注？",
  ["#ts__tianming-active"] = "天命：选择本阶段未用过的选项并声明X",
  ["#ts__tianming-kind"] = "天命：选择获得牌、回复体力或增加体力上限",
  ["#ts__tianming-number"] = "天命：自行声明X（1至5）",
  ["#ts__tianming-pay"] = "天命：债务到期，弃置%arg张手牌（不足则全弃）",
  ["#ts__sheyi-take"] = "奢易：是否获得该角色的牌，并承担双倍还牌债务？",
  ["#ts__sheyi-cards"] = "奢易：选择要获得的手牌或装备区的牌（至少一张）",
  ["#ts__sheyi-dying"] = "奢易：是否回复1点体力，令其失去1点体力，并承担2点体力债务？",
}

Fk:loadTranslationTable {
  ["@ts__sheyi_card_debt"] = "奢易牌债",
  ["@ts__sheyi_hp_debt"] = "奢易体力债",
}

General:new(extension, "haoo__hongkainan", "zheng", 4):addSkills { "haoo__jiangli" }
General:new(extension, "haoo__hongkainan2", "zheng", 4):addSkills { "haoo__tongnan" }
General:new(extension, "haoo__wanglei", "zheng", 3):addSkills { "haoo__xuanjian", "haoo__shijie" }
General:new(extension, "haoo__chenjinkun", "zheng", 4):addSkills {
  "haoo__shenkun", "haoo__yangjing", "haoo__xianzhe", "haoo__wuyi",
}
General:new(extension, "hg__tao", "hg_tie", 4, 4):addSkills {
  "hg__yuanqi", "hg__dongshen", "hg__chaowei",
}
General:new(extension, "lz__nanmingbi", "hg_tie", 4, 4):addSkills {
  "lz__jiangli", "lz__luguan",
}
local guozhou = General:new(extension, "sha__guozhou", "hg_tie", 4, 4, General.Male)
-- 殺郭周 is the full name; 殺 is not an edition prefix.
guozhou.prefix = nil
guozhou:addSkills {
  "sha__jimi", "sha__manbo", "sha__jiahao",
}
local wushilin = General:new(extension, "bo__wushilin", "hg_tie", 4, 4)
wushilin.prefix = nil
wushilin:addSkills { "bo__jige", "bo__dansi" }
wushilin:addRelatedSkills { "jiang", "jiyuan", "shenji", "quanji", "wusheng" }
local aizhake = General:new(extension, "azk__aizhake", "hg_tie", 4, 4)
aizhake.prefix = nil
aizhake:addSkills { "azk__xingye", "azk__mangren" }
aizhake:addRelatedSkills { "azk__qixing" }
local zengyixiong = General:new(extension, "bo__zengyixiong", "wei", 4, 4)
zengyixiong.prefix = nil
zengyixiong:addSkills { "bo__xiongbian", "bo__xiongqi" }
zengyixiong:addRelatedSkills { "paoxiao", "benxi", "zhuhai" }

General:new(extension, "ts__lin", "haoo", 3):addSkills { "ts__jiba", "ts__pojie" }
General:new(extension, "ts__yuji", "qun", 3):addSkills { "ts__nanbian", "ts__shifei", "ts__mengyan" }
General:new(extension, "ts__jiekang", "wei", 3):addSkills { "ts__zuilin", "ts__feihua", "ts__shiwai" }
General:new(extension, "ts__lin_sp", "haoo", 3):addSkills { "ts__duidu", "ts__tianming", "ts__sheyi" }

local fuban = General:new(extension, "fb__fuban", "god", 3, 3, General.Male)
fuban.subkingdom = "hg_tie"
fuban.prefix = nil
fuban:addSkills { "fb__hufu", "fb__bangban" }
fuban:addRelatedSkills { "fb__yingzi" }

return extension
