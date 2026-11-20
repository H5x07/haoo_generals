local C = require "packages.haoo_generals.cha"
local skill = fk.CreateSkill{name = "cha__beizhi"}
Fk:loadTranslationTable{
  ["cha__beizhi"] = "北智",
  [":cha__beizhi"] = "当你受到伤害后，你可〖奇策〗，并于本回合获得〖竞哗〗。",
}
skill:addEffect(fk.DamageFinished, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and player:hasSkill(skill.name)
      and data.dealtRecorderId ~= nil and not data.prevented and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local ok, choice = player.room:askToUseActiveSkill(player, {
      skill_name = "cha__qice", prompt = "#cha__qice", cancelable = true, skip = true,
    })
    if ok then event:setCostData(self, choice); return true end
  end,
  on_use = function(self, event, target, player, data)
    local choice = event:getCostData(self)
    if player.dead or player:isKongcheng() or
      not table.contains(Fk:getAllCardNames("t"), choice.interaction) then return end
    local card = Fk:cloneCard(choice.interaction)
    card:addSubcards(player:getCardIds("h"))
    card.skillName = "cha__qice"
    if not player:canUse(card) then return end
    local cs, selected = card:getSkill(player), {}
    for _, p in ipairs(choice.targets) do
      if p.dead or not cs:targetFilter(player, p, selected, {}, card) then return end
      table.insert(selected, p)
    end
    if not cs:feasible(player, selected, {card.id}, card) then return end
    -- UseCard:main has no success return in 0.5.25. Observe actual declaration
    -- instead, so a PreCardUse cancellation cannot grant Jinghua.
    local extra = {cha__beizhi_pending = true}
    player.room:useCard{from = player, tos = selected, card = card, extra_data = extra}
    if extra.cha__beizhi_used then
      C.grantJinghua(player)
    end
  end,
})
skill:addEffect(fk.AfterCardUseDeclared, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.cha__beizhi_pending
  end,
  on_refresh = function(self, event, target, player, data)
    data.extra_data.cha__beizhi_used = true
  end,
})
return skill
