local shenxu = fk.CreateSkill {
  name = "haoo__shenxu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["haoo__shenxu"] = "肾虚",
  [":haoo__shenxu"] = "锁定技，你的非锦囊牌视为【顺手牵羊】。",
}

shenxu:addAcquireEffect(function(self, player, is_start)
  player:filterHandcards()
end)

shenxu:addLoseEffect(function(self, player, is_death)
  player:filterHandcards()
end)

shenxu:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, card, player, isJudgeEvent)
    return player:hasSkill(shenxu.name) and card.type ~= Card.TypeTrick and
      (table.contains(player:getCardIds("h"), card.id) or isJudgeEvent)
  end,
  view_as = function(self, player, card)
    local c = Fk:cloneCard("snatch", card.suit, card.number)
    c.skillName = shenxu.name
    return c
  end,
})

return shenxu
