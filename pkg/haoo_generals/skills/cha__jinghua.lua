local C = require "packages.haoo_generals.cha"
local skill = fk.CreateSkill{name = "cha__jinghua", tags = {Skill.Compulsory}}
Fk:loadTranslationTable{
  ["cha__jinghua"] = "竞哗",
  [":cha__jinghua"] = "锁定技，当其他角色使用牌指定你为目标时，你与其拼点并令此牌对你无效。",
}
skill:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and C.canPindian(player, data.from)
  end,
  on_use = function(self, event, target, player, data)
    if not C.canPindian(player, data.from) then return end
    local pd = player:pindian({data.from}, skill.name)
    local result = pd.results[data.from]
    if pd.fromCard and result and result.toCard then data.nullified = true end
  end,
})
return skill
