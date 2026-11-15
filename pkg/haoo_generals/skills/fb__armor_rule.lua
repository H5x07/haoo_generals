local F = require "packages.haoo_generals.fuban"
local skill = fk.CreateSkill { name = "#fb__armor_rule", tags = { Skill.Compulsory } }

-- Physical card marks are synchronized to clients and reconnects. Native
-- -inarea cleanup removes the attachment when the card leaves Equip/Processing.
skill:addEffect("filter", {
  global = true,
  skill_filter = function(self, player)
    return F.count(player) > 0 and { "fb__yingzi" } or {}
  end,
  equip_skill_filter = function(self, equip_skill, player)
    if equip_skill:getSkeleton().name == "fb__yingzi" and F.count(player) > 0 then return "fb__hufu" end
  end,
})

skill:addEffect(fk.AfterCardsMove, {
  global = true,
  can_refresh = function(self, event, target, player, data) return player:getMark(F.count_mark) ~= F.count(player) end,
  on_refresh = function(self, event, target, player, data) player.room:setPlayerMark(player, F.count_mark, F.count(player)) end,
})

Fk:loadTranslationTable {
  ["#fb__armor_rule"] = "祜服·防具英姿",
  ["@fb__yingzi"] = "防具英姿",
}

return skill
