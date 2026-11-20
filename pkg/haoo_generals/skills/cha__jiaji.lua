local C = require "packages.haoo_generals.cha"
local skill = fk.CreateSkill{name = "cha__jiaji"}
Fk:loadTranslationTable{
  ["cha__jiaji"] = "假济",
  [":cha__jiaji"] = "每回合限一次，你造成伤害后，可以发动一次“驱虎”（不受出牌阶段及次数限制）。",
  ["#cha__jiaji-choose"] = "假济：选择体力值大于你的一名角色，发动一次“驱虎”",
  ["#cha__jiaji-damage"] = "假济：选择其攻击范围内的一名角色，由其造成1点伤害",
}
skill:addEffect(fk.DamageFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name) and not player.dead and data.from == player
      and data.dealtRecorderId ~= nil and not data.prevented
      and player:getMark("cha__jiaji_used-turn") == 0 and #C.quhuTargets(player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = C.quhuTargets(player), min_num = 1, max_num = 1,
      skill_name = skill.name, prompt = "#cha__jiaji-choose", cancelable = true,
    })
    if #tos > 0 then event:setCostData(self, {tos = tos}); return true end
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "cha__jiaji_used-turn", 1)
    C.quhu(player, event:getCostData(self).tos[1])
  end,
})
return skill
