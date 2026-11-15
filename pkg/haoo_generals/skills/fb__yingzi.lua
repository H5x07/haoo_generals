local F = require "packages.haoo_generals.fuban"
local skill = fk.CreateSkill { name = "fb__yingzi" }

skill:addEffect(fk.DrawNCards, {
  global = true,
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and F.count(player) > 0
  end,
  trigger_times = function(self, event, target, player, data) return F.count(player) end,
  on_use = function(self, event, target, player, data) data.n = data.n + 1 end,
})

Fk:loadTranslationTable {
  ["fb__yingzi"] = "英姿",
  [":fb__yingzi"] = "摸牌阶段，你可以多摸一张牌。每件祜服防具分别提供一次发动机会，与原有英姿叠加；防具移走后不再提供此效果。",
}

return skill
