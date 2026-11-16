local F = require "packages.haoo_generals.fuban"
local skill = fk.CreateSkill { name = "fb__bangban" }

-- Intercept before the original phase starts, so its start/proceed/end skills
-- do not execute. Run a complete native Draw phase in the same turn.
skill:addEffect(fk.EventPhaseChanging, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= nil and target ~= player and player:hasSkill(skill.name) and not data.skipped and
      not data.fb__bangban and (data.phase == Player.Draw or data.phase == Player.Discard) and #F.movable(player, target) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local ids = F.movable(player, target)
    if #ids == 0 then return false end
    local cards = player.room:askToCards(player, {
      min_num = 1, max_num = 1, include_equip = true, cancelable = true,
      skill_name = skill.name, pattern = tostring(Exppattern{ id = ids }),
      prompt = "#fb__bangban::" .. target.id .. ":" .. Util.PhaseStrMapper(data.phase),
    })
    if #cards == 1 then
      event:setCostData(self, { cards = cards, tos = { target } })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local id = event:getCostData(self).cards[1]
    if not table.contains(F.movable(player, target), id) or data.skipped or data.fb__bangban then return end
    local room = player.room
    room:moveCardIntoEquip(target, F.armor(player, id), skill.name, false, player)
    if room:getCardOwner(id) ~= target or room:getCardArea(id) ~= Card.PlayerEquip then return end
    data.fb__bangban, data.skipped = player.id, true
    if not player.dead then player:gainAnExtraPhase(Player.Draw, skill.name, false) end
  end,
})

Fk:loadTranslationTable {
  ["fb__bangban"] = "帮扮",
  [":fb__bangban"] = "其他角色摸牌/弃牌阶段开始时，你可移动你装备区一张防具至其装备区然后本回合此阶段改为你的摸牌阶段。",
  ["#fb__bangban"] = "帮扮：你可将一张防具移至 %dest 的空置防具栏，跳过其%arg并进行你的摸牌阶段",
}

return skill
